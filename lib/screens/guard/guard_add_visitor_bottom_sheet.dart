import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:mygate_coepd/repositories/guard_repository.dart';

enum FieldType { name, phone, purpose }

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final FieldType type;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.type,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  String? validateField(FieldType type, String? value) {
    final v = value?.trim() ?? '';

    switch (type) {
      case FieldType.name:
        if (v.isEmpty) return 'Please enter name';
        if (v.length < 2) return 'Name is too short';
        return null;

      case FieldType.phone:
        if (v.isEmpty) return 'Please enter phone number';
        if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v)) {
          return 'Enter valid 10-15 digit number';
        }
        return null;

      case FieldType.purpose:
        if (v.isEmpty) return 'Please enter purpose';
        if (v.length < 3) return 'Too short';
        return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: Icon(widget.icon, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (v) => validateField(widget.type, v),
      ),
    );
  }
}

class GuardAddVisitorBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? prefill;

  const GuardAddVisitorBottomSheet({super.key, this.prefill});

  @override
  State<GuardAddVisitorBottomSheet> createState() =>
      _GuardAddVisitorBottomSheetState();
}

class _GuardAddVisitorBottomSheetState
    extends State<GuardAddVisitorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _purposeController;
  final TextEditingController _residentSearchController =
      TextEditingController();

  XFile? _capturedImage;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedVisitorType = 'guest';
  int? _selectedResidentId;

  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;
  String? _uploadedPhotoUrl;
  bool _uploadFailed = false;

  final GuardRepository _guardRepository = GuardRepository();
  final _s3 = S3UploadService();

  List<Map<String, dynamic>> _residents = [];
  bool _isLoadingResidents = true;

  static const List<Map<String, String>> _visitorTypes = [
    {'value': 'guest', 'label': 'Guest', 'icon': '👤'},
    {'value': 'delivery', 'label': 'Delivery', 'icon': '📦'},
    {'value': 'service', 'label': 'Service', 'icon': '🔧'},
    {'value': 'other', 'label': 'Other', 'icon': '📋'},
  ];

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.prefill?['name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.prefill?['phone'] ?? '',
    );
    _purposeController = TextEditingController(
      text: widget.prefill?['purpose'] ?? '',
    );

    _initializeCamera();
    _fetchResidents();
  }

  Future<void> _fetchResidents() async {
    try {
      final list = await _guardRepository.getResidents(limit: 1000);
      if (mounted) {
        setState(() {
          _residents = list;
          _isLoadingResidents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingResidents = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
    _residentSearchController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {}

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {}
      }

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      // Continue without camera
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      await _uploadFile(photo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture photo')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;
      await _uploadFile(image);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  Future<void> _uploadFile(XFile image) async {
    setState(() {
      _capturedImage = image;
      _uploadedPhotoUrl = null;
      _uploadFailed = false;
      _isUploadingPhoto = true;
    });

    try {
      final url = await _s3.uploadImage(
        File(image.path),
        folder: S3UploadService.folderVisitors,
      );
      if (mounted) {
        setState(() {
          _uploadedPhotoUrl = url;
          _uploadFailed = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadFailed = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Photo upload failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _uploadFile(image),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedResidentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a resident'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_isSubmitting) return;
    if (_isUploadingPhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, photo is still uploading...'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? visitDate;
      String? visitTime;
      if (_selectedDate != null) {
        visitDate =
            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      }
      if (_selectedTime != null) {
        visitTime =
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
      }

      final result = await _guardRepository.addVisitor(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        purpose: _purposeController.text.trim(),
        visitDate: visitDate,
        visitTime: visitTime,
        visitorType: _selectedVisitorType,
        imageUrl: _uploadedPhotoUrl,
        residentId: _selectedResidentId,
      );

      final createdVisitor = {
        'id': result['visitor_id'],
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'purpose': _purposeController.text.trim(),
        'visitor_type': _selectedVisitorType,
        'visit_date': visitDate,
        'visit_time': visitTime,
        'status': 'pending',
        'image_url': _uploadedPhotoUrl,
        'resident_id': _selectedResidentId,
      };

      if (mounted) {
        Navigator.of(context).pop(createdVisitor);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 36.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Add New Visitor',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Camera/Photo Section
              Container(
                height: 240.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: _capturedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(
                              File(_capturedImage!.path),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_isUploadingPhoto)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Uploading...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_uploadFailed && !_isUploadingPhoto)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.cloud_off,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Upload failed',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _uploadFile(_capturedImage!),
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 16,
                                        ),
                                        label: const Text('Retry'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (!_isUploadingPhoto)
                            Positioned(
                              top: 2.w,
                              right: 2.w,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: colorScheme.onError,
                                    size: 18.sp,
                                  ),
                                ),
                                onPressed: () => setState(() {
                                  _capturedImage = null;
                                  _uploadedPhotoUrl = null;
                                  _uploadFailed = false;
                                }),
                              ),
                            ),
                          if (_uploadedPhotoUrl != null &&
                              !_isUploadingPhoto &&
                              !_uploadFailed)
                            Positioned(
                              bottom: 8.h,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.cloud_done,
                                        color: Colors.white,
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Uploaded ✓',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : _isCameraInitialized && _cameraController != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CameraPreview(_cameraController!),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 48.sp,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Camera not available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              SizedBox(height: 16.h),
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _capturePhoto,
                      icon: Icon(
                        Icons.camera_alt,
                        color: colorScheme.onPrimary,
                        size: 20.sp,
                      ),
                      label: const Text('Capture'),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: Icon(
                        Icons.photo_library,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // RESIDENT SELECTION
              if (_isLoadingResidents)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Autocomplete<Map<String, dynamic>>(
                  displayStringForOption: (option) =>
                      '${option['name']} - ${option['flat_number'] ?? 'No flat'}',
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return _residents.take(10);
                    }
                    return _residents.where((resident) {
                      final name = resident['name'].toString().toLowerCase();
                      final flat = (resident['flat_number'] ?? '')
                          .toString()
                          .toLowerCase();
                      final query = textEditingValue.text.toLowerCase();
                      return name.contains(query) || flat.contains(query);
                    });
                  },
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      _selectedResidentId = int.tryParse(
                        selection['id'].toString(),
                      );
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              if (focusNode.hasFocus)
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Select Resident *',
                              hintText: 'Search by name or flat',
                              prefixIcon: const Icon(
                                Icons.person_search,
                                size: 18,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: _selectedResidentId != null
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    )
                                  : null,
                            ),
                            validator: (v) {
                              if (_selectedResidentId == null ||
                                  v == null ||
                                  v.isEmpty) {
                                return 'Please search and select a resident from the list';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              if (_selectedResidentId != null) {
                                setState(() {
                                  _selectedResidentId = null;
                                });
                              }
                            },
                          ),
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32.w,
                          constraints: BoxConstraints(maxHeight: 200.h),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16.r,
                                  backgroundImage:
                                      option['profile_image'] != null
                                      ? NetworkImage(option['profile_image'])
                                      : null,
                                  child: option['profile_image'] == null
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                                ),
                                title: Text('${option['name']}'),
                                subtitle: Text(
                                  'Flat: ${option['flat_number'] ?? 'N/A'}',
                                ),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 12.h),

              AppTextField(
                controller: _nameController,
                label: 'Visitor Name',
                hint: 'Enter full name',
                icon: Icons.person_outline,
                type: FieldType.name,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter 10-digit number',
                icon: Icons.phone_outlined,
                type: FieldType.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _purposeController,
                label: 'Purpose of Visit',
                hint: 'Why are you visiting?',
                icon: Icons.work_outline,
                type: FieldType.purpose,
              ),
              SizedBox(height: 12.h),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Visitor Type',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: _visitorTypes.map((type) {
                  final isSelected = _selectedVisitorType == type['value'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedVisitorType = type['value']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type['icon']!,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            type['label']!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12.h),
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: Icon(
                        Icons.calendar_today,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      label: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select Date',
                      ),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: Icon(
                        Icons.access_time,
                        color: colorScheme.primary,
                        size: 20.sp,
                      ),
                      label: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select Time',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text(
                          'Add Visitor',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
