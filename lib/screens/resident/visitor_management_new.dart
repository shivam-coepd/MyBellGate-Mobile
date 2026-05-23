import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

enum FieldType { name, phone, purpose }

/// Visitor Management Screen for handling visitor pre-approvals and real-time entry management
class VisitorManagementScreenNew extends StatefulWidget {
  const VisitorManagementScreenNew({super.key});

  @override
  State<VisitorManagementScreenNew> createState() =>
      _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreenNew> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Today';
  bool _isBulkMode = false;
  final Set<int> _selectedVisitors = {};
  Map<String, dynamic>? _activeNotification;

  // Mock visitor data
  final List<Map<String, dynamic>> _allVisitors = [
    {
      'id': 1,
      'name': 'Rajesh Kumar',
      'phone': '+91 98765 43210',
      'purpose': 'Delivery - Amazon Package',
      'photo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1236e79c3-1763294023133.png',
      'photoSemanticLabel':
          'Indian man with short black hair and mustache wearing blue shirt',
      'expectedTime': '22/12/2025 02:30 PM',
      'status': 'Pending',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'phone': '+91 87654 32109',
      'purpose': 'Guest Visit',
      'photo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1dc96d634-1763295460493.png',
      'photoSemanticLabel':
          'Indian woman with long black hair wearing traditional saree',
      'expectedTime': '22/12/2025 04:00 PM',
      'status': 'Approved',
    },
    {
      'id': 3,
      'name': 'Amit Patel',
      'phone': '+91 76543 21098',
      'purpose': 'Maintenance Work',
      'photo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_15e90c3d0-1763293909345.png',
      'photoSemanticLabel':
          'Indian man with glasses and short hair wearing work uniform',
      'expectedTime': '22/12/2025 10:00 AM',
      'status': 'Approved',
    },
    {
      'id': 4,
      'name': 'Sneha Reddy',
      'phone': '+91 65432 10987',
      'purpose': 'Food Delivery - Swiggy',
      'photo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1ec6b40c2-1763294215713.png',
      'photoSemanticLabel':
          'Young Indian woman with ponytail wearing delivery uniform',
      'expectedTime': '22/12/2025 01:15 PM',
      'status': 'Rejected',
    },
    {
      'id': 5,
      'name': 'Vikram Singh',
      'phone': '+91 54321 09876',
      'purpose': 'Courier - BlueDart',
      'photo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_10525d709-1763292629057.png',
      'photoSemanticLabel':
          'Indian man with beard wearing courier company uniform',
      'expectedTime': '22/12/2025 11:30 AM',
      'status': 'Pending',
    },
  ];

  List<Map<String, dynamic>> _filteredVisitors = [];

  @override
  void initState() {
    super.initState();
    _filteredVisitors = List.from(_allVisitors);
    _simulateVisitorArrival();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _simulateVisitorArrival() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _allVisitors.isNotEmpty) {
        setState(() {
          _activeNotification = _allVisitors.first;
        });
      }
    });
  }

  void _filterVisitors() {
    setState(() {
      _filteredVisitors = _allVisitors.where((visitor) {
        final matchesSearch = visitor['name'].toString().toLowerCase().contains(
          _searchController.text.toLowerCase(),
        );

        final matchesFilter =
            _selectedFilter == 'Today' ||
            visitor['status'].toString().toLowerCase() ==
                _selectedFilter.toLowerCase();

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showSuccessMessage(String message) {
    HapticFeedback.lightImpact();
    Flushbar(
      message: message,
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
      margin: EdgeInsets.all(4.w),
      icon: Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 24,
      ),
    ).show(context);
  }

  void _approveVisitor(int visitorId) {
    setState(() {
      final index = _allVisitors.indexWhere((v) => v['id'] == visitorId);
      if (index != -1) {
        _allVisitors[index]['status'] = 'Approved';
        _filterVisitors();
      }
    });
    _showSuccessMessage('Visitor approved successfully');
  }

  void _rejectVisitor(int visitorId) {
    setState(() {
      final index = _allVisitors.indexWhere((v) => v['id'] == visitorId);
      if (index != -1) {
        _allVisitors[index]['status'] = 'Rejected';
        _filterVisitors();
      }
    });
    _showSuccessMessage('Visitor rejected');
  }

  void _deleteVisitor(int visitorId) {
    setState(() {
      _allVisitors.removeWhere((v) => v['id'] == visitorId);
      _filterVisitors();
    });
    _showSuccessMessage('Visitor removed');
  }

  void _callVisitor(String phone) {
    _showSuccessMessage('Calling $phone...');
  }

  void _shareVisitorDetails(Map<String, dynamic> visitor) {
    _showSuccessMessage('Sharing details for ${visitor['name']}');
  }

  void _editVisitor(int visitorId) {
    _showSuccessMessage('Edit functionality coming soon');
  }

  void _extendTime(int visitorId) {
    _showSuccessMessage('Time extended successfully');
  }

  void _addNote(int visitorId) {
    _showSuccessMessage('Note added successfully');
  }

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
      if (!_isBulkMode) {
        _selectedVisitors.clear();
      }
    });
  }

  void _bulkApprove() {
    setState(() {
      for (final id in _selectedVisitors) {
        final index = _allVisitors.indexWhere((v) => v['id'] == id);
        if (index != -1) {
          _allVisitors[index]['status'] = 'Approved';
        }
      }
      _selectedVisitors.clear();
      _isBulkMode = false;
      _filterVisitors();
    });
    _showSuccessMessage('${_selectedVisitors.length} visitors approved');
  }

  void _handleVoiceSearch() {
    _showSuccessMessage('Voice search activated');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Visitor Management',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        // foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,

        actions: [
          IconButton(
            icon: Icon(
              _isBulkMode ? Icons.close : Icons.checklist,
              color: theme.primaryColor,
              size: 24.sp,
            ),
            onPressed: _toggleBulkMode,
          ),
          if (_isBulkMode && _selectedVisitors.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.check_circle,
                color: theme.primaryColor,
                size: 24.sp,
              ),
              onPressed: _bulkApprove,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 1));
          setState(() => _filterVisitors());
        },
        child: Stack(
          children: [
            Column(
              children: [
                FloatingSearchBarWidget(
                  searchController: _searchController,
                  onVoiceSearch: _handleVoiceSearch,
                  onSearchChanged: (_) => _filterVisitors(),
                ),
                FilterChipsWidget(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() {
                      _selectedFilter = filter;
                      _filterVisitors();
                    });
                  },
                ),
                SizedBox(height: 1.h),
                Expanded(
                  child: _filteredVisitors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                size: 64,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No visitors found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(bottom: 80.h, top: 10.h),
                          itemCount: _filteredVisitors.length,
                          itemBuilder: (context, index) {
                            final visitor = _filteredVisitors[index];
                            final visitorId = visitor['id'] as int;

                            return VisitorCardWidget(
                              visitor: visitor,
                              onApprove: () => _approveVisitor(visitorId),
                              onReject: () => _rejectVisitor(visitorId),
                              onCall: () =>
                                  _callVisitor(visitor['phone'] as String),
                              onShare: () => _shareVisitorDetails(visitor),
                              onDelete: () => _deleteVisitor(visitorId),
                              onEdit: () => _editVisitor(visitorId),
                              onExtendTime: () => _extendTime(visitorId),
                              onAddNote: () => _addNote(visitorId),
                              isSelected: _selectedVisitors.contains(visitorId),
                              onSelectionChanged: () {
                                setState(() {
                                  if (_selectedVisitors.contains(visitorId)) {
                                    _selectedVisitors.remove(visitorId);
                                  } else {
                                    _selectedVisitors.add(visitorId);
                                  }
                                });
                              },
                              isBulkMode: _isBulkMode,
                            );
                          },
                        ),
                ),
              ],
            ),
            if (_activeNotification != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NotificationBannerWidget(
                  visitor: _activeNotification!,
                  onApprove: () {
                    _approveVisitor(_activeNotification!['id'] as int);
                    setState(() => _activeNotification = null);
                  },
                  onDeny: () {
                    _rejectVisitor(_activeNotification!['id'] as int);
                    setState(() => _activeNotification = null);
                  },
                  onDismiss: () {
                    setState(() => _activeNotification = null);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AddVisitorBottomSheet(
                onVisitorAdded: (visitor) {
                  setState(() {
                    _allVisitors.insert(0, visitor);
                    _filterVisitors();
                  });
                  _showSuccessMessage('Visitor added successfully');
                },
              ),
            ),
          );
        },
        icon: Icon(Icons.person_add, color: colorScheme.onPrimary, size: 24),
        label: const Text('Add Visitor'),
        backgroundColor: colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// Bottom sheet for adding new visitor with camera integration
class AddVisitorBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onVisitorAdded;

  const AddVisitorBottomSheet({super.key, required this.onVisitorAdded});

  @override
  State<AddVisitorBottomSheet> createState() => _AddVisitorBottomSheetState();
}

class _AddVisitorBottomSheetState extends State<AddVisitorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _purposeController = TextEditingController();

  XFile? _capturedImage;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _purposeController.dispose();
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
      } catch (e) {
        // Focus mode not supported
      }

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash not supported
        }
      }

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      // Camera initialization failed - continue without camera
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() => _capturedImage = photo);
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
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _capturedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final visitor = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'purpose': _purposeController.text,
        'photo':
            _capturedImage?.path ??
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'photoSemanticLabel':
            'Visitor photo captured for ${_nameController.text}',
        'expectedTime': _selectedDate != null && _selectedTime != null
            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${_selectedTime!.format(context)}'
            : 'Not specified',
        'status': 'Pending',
      };
      widget.onVisitorAdded(visitor);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Add New Visitor',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                // Camera/Photo Section
                Container(
                  height: 240.h,
                  width: double.infinity,
                  // margin: EdgeInsets.only(top: 4.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: _capturedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Image.network(
                                _capturedImage!.path,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2.w,
                              right: 2.w,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: colorScheme.onError,
                                    size: 20.sp,
                                  ),
                                ),
                                onPressed: () =>
                                    setState(() => _capturedImage = null),
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
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Add Visitor'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Filter chips for visitor status filtering
class FilterChipsWidget extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final filters = ['Today', 'Pending', 'Approved', 'Rejected'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
      child: Row(
        spacing: 10.w,
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : (isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Dot indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isSelected ? 6.w : 0,
                    height: 6.w,
                    margin: EdgeInsets.only(right: isSelected ? 6.w : 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  Text(
                    filter,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 13.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Floating search bar with voice search capability
class FloatingSearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onVoiceSearch;
  final ValueChanged<String> onSearchChanged;

  const FloatingSearchBarWidget({
    super.key,
    required this.searchController,
    required this.onVoiceSearch,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search visitors...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: Icon(
              Icons.search,
              color: colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                ),
              IconButton(
                icon: Icon(Icons.mic, color: colorScheme.primary, size: 24),
                onPressed: onVoiceSearch,
              ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        ),
      ),
    );
  }
}

/// Floating notification banner for visitor arrivals
class NotificationBannerWidget extends StatelessWidget {
  final Map<String, dynamic> visitor;
  final VoidCallback onApprove;
  final VoidCallback onDeny;
  final VoidCallback onDismiss;

  const NotificationBannerWidget({
    super.key,
    required this.visitor,
    required this.onApprove,
    required this.onDeny,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visitor at Gate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${visitor['name']} has arrived',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceVariant,
                  ),
                  child: Icon(Icons.close, size: 16.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Approve', style: TextStyle(fontSize: 13.sp)),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: OutlinedButton(
                  onPressed: onDeny,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(color: colorScheme.error),
                  ),
                  child: Text(
                    'Deny',
                    style: TextStyle(fontSize: 13.sp, color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual visitor card widget with swipe actions and status indicators
class VisitorCardWidget extends StatelessWidget {
  final Map<String, dynamic> visitor;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCall;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onExtendTime;
  final VoidCallback onAddNote;
  final bool isSelected;
  final VoidCallback? onSelectionChanged;
  final bool isBulkMode;

  const VisitorCardWidget({
    super.key,
    required this.visitor,
    required this.onApprove,
    required this.onReject,
    required this.onCall,
    required this.onShare,
    required this.onDelete,
    required this.onEdit,
    required this.onExtendTime,
    required this.onAddNote,
    this.isSelected = false,
    this.onSelectionChanged,
    this.isBulkMode = false,
  });

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E); // vivid green
      case 'pending':
        return const Color(0xFFF59E0B); // amber
      case 'rejected':
        return const Color(0xFFEF4444); // red
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFDCFCE7);
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.verified_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'rejected':
        return Icons.remove_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final status = visitor['status'] as String;
    final statusColor = _getStatusColor(status, colorScheme);
    final statusBgColor = isDark
        ? statusColor.withValues(alpha: 0.15)
        : _getStatusBgColor(status);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Slidable(
        key: ValueKey(visitor['id']),
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.78,
          children: [
            _buildSlideAction(
              icon: Icons.check_rounded,
              label: 'Approve',
              color: const Color(0xFF22C55E),
              onTap: (_) => onApprove(),
              isFirst: true,
            ),
            _buildSlideAction(
              icon: Icons.close_rounded,
              label: 'Reject',
              color: const Color(0xFFEF4444),
              onTap: (_) => onReject(),
            ),
            _buildSlideAction(
              icon: Icons.phone_rounded,
              label: 'Call',
              color: colorScheme.secondary,
              onTap: (_) => onCall(),
            ),
            _buildSlideAction(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              color: const Color(0xFF8B5CF6),
              onTap: (_) => onShare(),
              isLast: true,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.22,
          children: [
            _buildSlideAction(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: const Color(0xFFEF4444),
              onTap: (_) => onDelete(),
              isFirst: true,
              isLast: true,
            ),
          ],
        ),
        child: GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => _buildContextMenu(context, theme),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : statusColor.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                spacing: 12.w,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bulk Mode Checkbox
                  if (isBulkMode)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22.w,
                      height: 22.w,
                      // margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              size: 14.sp,
                              color: colorScheme.onPrimary,
                            )
                          : null,
                    ),

                  // Avatar with status indicator
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.network(
                            visitor['photo'] as String,
                            width: 56.w,
                            height: 56.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: statusColor.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.person_rounded,
                                size: 28.sp,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -3,
                        right: -3,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getStatusIcon(status),
                            size: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Name
                        Text(
                          visitor['name'] as String,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 5.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            spacing: 4.w,
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                size: 11.sp,
                                color: colorScheme.primary,
                              ),
                              Text(
                                visitor['purpose'] as String,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 5.h),

                        // Time row
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12.sp,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              visitor['expectedTime'] as String,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status Badge — vertical pill
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              size: 15.sp,
                              color: statusColor,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              _getStatusLabel(status),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  CustomSlidableAction _buildSlideAction({
    required IconData icon,
    required String label,
    required Color color,
    required void Function(BuildContext) onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return CustomSlidableAction(
      onPressed: onTap,
      backgroundColor: color.withValues(alpha: 0.12),
      foregroundColor: color,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final status = visitor['status'] as String;
    final statusColor = _getStatusColor(status, colorScheme);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Visitor mini header
              Container(
                padding: EdgeInsets.all(14.w),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        visitor['photo'] as String,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40.w,
                          height: 40.w,
                          color: statusColor.withValues(alpha: 0.1),
                          child: Icon(Icons.person_rounded, color: statusColor),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor['name'] as String,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            visitor['purpose'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        _getStatusLabel(status),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              _buildMenuTile(
                context: context,
                theme: theme,
                icon: Icons.edit_rounded,
                title: 'Edit Details',
                subtitle: 'Modify visitor information',
                color: colorScheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              _buildMenuTile(
                context: context,
                theme: theme,
                icon: Icons.access_time_rounded,
                title: 'Extend Time',
                subtitle: 'Increase visit duration',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  onExtendTime();
                },
              ),
              _buildMenuTile(
                context: context,
                theme: theme,
                icon: Icons.note_add_rounded,
                title: 'Add Note',
                subtitle: 'Attach a note to this visit',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pop(context);
                  onAddNote();
                },
                isLast: true,
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: color, size: 20.sp),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 58.w,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

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
        if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
          return 'Enter valid 10-digit number';
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
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
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,

          prefixIcon: Icon(widget.icon, size: 18),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),

          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _isFocused
                ? theme.colorScheme.primary
                : Colors.grey.shade600,
          ),

          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),

        validator: (value) => validateField(widget.type, value),
      ),
    );
  }
}
