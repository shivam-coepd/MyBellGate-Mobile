import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/screens/resident/daily_helper_qr_pass_screen.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class DailyHelpScreen extends StatefulWidget {
  const DailyHelpScreen({super.key});

  @override
  State<DailyHelpScreen> createState() => _DailyHelpScreenState();
}

class _DailyHelpScreenState extends State<DailyHelpScreen> {
  final HouseholdRepository _repository = HouseholdRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allHelpers = [];
  List<Map<String, dynamic>> _filteredHelpers = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Maid',
    'Cook',
    'Cleaner',
    'Driver',
    'Caretaker',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHelpers();
    _searchController.addListener(_filterHelpers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHelpers() async {
    setState(() => _isLoading = true);
    try {
      final helpers = await _repository.getDailyHelpers();
      if (mounted) {
        setState(() {
          _allHelpers = helpers;
          _isLoading = false;
        });
        _filterHelpers();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.show(
          context: context,
          message: 'Failed to load daily help: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  void _filterHelpers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredHelpers = _allHelpers.where((helper) {
        final name = (helper['name'] ?? '').toString().toLowerCase();
        final service = (helper['service_type'] ?? '').toString().toLowerCase();
        final phone = (helper['phone'] ?? '').toString().toLowerCase();
        final matchesQuery =
            query.isEmpty ||
            name.contains(query) ||
            service.contains(query) ||
            phone.contains(query);

        final matchesCategory =
            _selectedCategory == 'All' ||
            service.toLowerCase() == _selectedCategory.toLowerCase();

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'maid':
        return Icons.cleaning_services;
      case 'cook':
        return Icons.soup_kitchen;
      case 'cleaner':
        return Icons.wash;
      case 'driver':
        return Icons.directions_car;
      case 'caretaker':
        return Icons.health_and_safety;
      default:
        return Icons.handyman;
    }
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'maid':
        return Colors.teal;
      case 'cook':
        return Colors.orange;
      case 'cleaner':
        return Colors.blue;
      case 'driver':
        return Colors.indigo;
      case 'caretaker':
        return Colors.purple;
      default:
        return Colors.deepPurple;
    }
  }

  // Show bottom sheet to Add or Edit helper
  void _openHelperForm({Map<String, dynamic>? helperToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _HelperFormBottomSheet(
        helper: helperToEdit,
        onSaved: () {
          _fetchHelpers();
        },
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> helper) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Remove Daily Helper?'),
        content: Text(
          'Are you sure you want to remove ${helper['name'] ?? 'this helper'}? '
          'Their static gate pass will be deactivated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = int.tryParse(helper['id']?.toString() ?? '') ?? 0;
      if (id > 0) {
        try {
          await _repository.deleteDailyHelper(id);
          if (mounted) {
            AppSnackbar.show(
              context: context,
              message: '${helper['name'] ?? 'Helper'} removed successfully',
              type: SnackBarType.success,
            );
            _fetchHelpers();
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.show(
              context: context,
              message: 'Failed to remove helper: $e',
              type: SnackBarType.error,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Daily Help')),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, service or phone...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.primaryColor,
                  size: 20.sp,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Categories Filter Chips
          SizedBox(
            height: 48.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: theme.primaryColor,
                  backgroundColor: theme.cardColor,
                  labelStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : null,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: isSelected
                          ? theme.primaryColor
                          : isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                      _filterHelpers();
                    }
                  },
                );
              },
            ),
          ),

          // Helpers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHelpers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _fetchHelpers,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: _filteredHelpers.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final helper = _filteredHelpers[index];
                        return _buildHelperCard(helper, isDark);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openHelperForm(),
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Add Daily Help',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cleaning_services,
                  size: 64.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _searchController.text.isNotEmpty || _selectedCategory != 'All'
                    ? 'No matching helpers found'
                    : 'No Daily Helpers Added',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                _searchController.text.isNotEmpty || _selectedCategory != 'All'
                    ? 'Try adjusting your search or category filter.'
                    : 'Add your regular house help like Maid, Cook, Driver, Caretaker to generate static QR gate passes for guard entry & exit tracking.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => _openHelperForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Your First Helper'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelperCard(Map<String, dynamic> helper, bool isDark) {
    final theme = Theme.of(context);
    final name = helper['name'] ?? 'Helper';
    final phone = helper['phone'] ?? '';
    final serviceType = helper['service_type'] ?? 'Service';
    final imageUrl = helper['image_url'] ?? '';
    final visitTime = helper['expected_time_in'] ?? helper['visit_time'] ?? '';
    final qrCode = helper['qr_code'] ?? 'DHP-${helper['id']}';
    final isInside = helper['is_inside'] == 1 || helper['is_inside'] == true;
    final serviceColor = _getServiceColor(serviceType);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isInside
              ? Colors.green.shade300
              : isDark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          width: isInside ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Image or Initial
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: serviceColor.withOpacity(0.12),
                      backgroundImage: imageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'H',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: serviceColor,
                              ),
                            )
                          : null,
                    ),
                    if (isInside)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14.r,
                          height: 14.r,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 14.w),

                // Name, Service, Phone, Timing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: isInside
                                  ? Colors.green.withOpacity(0.12)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.r,
                                  height: 6.r,
                                  decoration: BoxDecoration(
                                    color: isInside
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  isInside ? 'INSIDE' : 'OUTSIDE',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isInside
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: serviceColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getServiceIcon(serviceType),
                                  size: 12.sp,
                                  color: serviceColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  serviceType,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: serviceColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (visitTime.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.access_time,
                              size: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              visitTime,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (phone.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Text(
                        'Pass ID: $qrCode',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey.shade800.withValues(alpha: 0.3)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                // View QR Pass Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DailyHelperQrPassScreen(helper: helper),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_2, size: 16),
                    label: const Text('View Pass'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      textStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 18.sp,
                  color: Colors.blue.shade700,
                  tooltip: 'Edit Helper',
                  onPressed: () => _openHelperForm(helperToEdit: helper),
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 18.sp,
                  color: Colors.red.shade600,
                  tooltip: 'Remove Helper',
                  onPressed: () => _confirmDelete(helper),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER BOTTOM SHEET FORM (ADD / EDIT)
// ─────────────────────────────────────────────────────────────────────────────

class _HelperFormBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? helper;
  final VoidCallback onSaved;

  const _HelperFormBottomSheet({this.helper, required this.onSaved});

  @override
  State<_HelperFormBottomSheet> createState() => _HelperFormBottomSheetState();
}

class _HelperFormBottomSheetState extends State<_HelperFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _timeController;
  late String _serviceType;

  File? _imageFile;
  String? _existingImageUrl;
  bool _isSaving = false;

  final List<String> _serviceOptions = [
    'Maid',
    'Cook',
    'Cleaner',
    'Driver',
    'Caretaker',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.helper;
    _nameController = TextEditingController(text: h?['name'] ?? '');
    _phoneController = TextEditingController(text: h?['phone'] ?? '');
    _timeController = TextEditingController(
      text: h?['expected_time_in'] ?? h?['visit_time'] ?? '',
    );
    _serviceType = h?['service_type'] ?? 'Maid';
    _existingImageUrl = h?['image_url'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String? uploadedUrl = _existingImageUrl;
      if (_imageFile != null) {
        uploadedUrl = await S3UploadService().uploadImage(
          _imageFile!,
          folder: 'visitors',
        );
      }

      final repo = HouseholdRepository();
      if (widget.helper != null) {
        final id = int.tryParse(widget.helper!['id']?.toString() ?? '') ?? 0;
        await repo.updateDailyHelper(
          id: id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          purpose: _serviceType,
          visitTime: _timeController.text.trim(),
          imageUrl: uploadedUrl,
        );
        if (mounted) {
          AppSnackbar.show(
            context: context,
            message: 'Daily helper updated successfully',
            type: SnackBarType.success,
          );
        }
      } else {
        await repo.addDailyHelper(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          serviceType: _serviceType,
          visitTime: _timeController.text.trim(),
          imageUrl: uploadedUrl,
        );
        if (mounted) {
          AppSnackbar.show(
            context: context,
            message: 'Daily helper added & static QR Pass created!',
            type: SnackBarType.success,
          );
        }
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnackbar.show(
          context: context,
          message: 'Error saving helper: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.helper != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                isEdit ? 'Edit Daily Helper' : 'Add New Daily Helper',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                'Generates a permanent QR pass for gate check-in & check-out.',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 20.h),

              // Image Picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_existingImageUrl != null &&
                                  _existingImageUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(_existingImageUrl!)
                            : null as ImageProvider?,
                        child:
                            (_imageFile == null &&
                                (_existingImageUrl == null ||
                                    _existingImageUrl!.isEmpty))
                            ? Icon(
                                Icons.person,
                                size: 40.sp,
                                color: theme.primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Service Type Choice Chips
              Text(
                'Service Category',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: _serviceOptions.map((opt) {
                  final isSelected =
                      _serviceType.toLowerCase() == opt.toLowerCase();
                  return ChoiceChip(
                    label: Text(opt),
                    selected: isSelected,
                    selectedColor: theme.primaryColor,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _serviceType = opt);
                      }
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Helper Full Name *',
                  hintText: 'e.g. Sunita Wani',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter helper name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. 9876543210',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Visit Time Field
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Expected Visiting Hours / Timing',
                  hintText: 'e.g. 08:00 AM - 10:00 AM',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Submit Button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20.w,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit
                            ? 'Update Daily Helper'
                            : 'Create & Generate QR Pass',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
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
