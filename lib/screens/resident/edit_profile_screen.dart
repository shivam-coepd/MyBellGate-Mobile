import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class EditProfileDetailsScreen extends StatefulWidget {
  final User user;

  const EditProfileDetailsScreen({super.key, required this.user});

  @override
  State<EditProfileDetailsScreen> createState() =>
      _EditProfileDetailsScreenState();
}

class _EditProfileDetailsScreenState extends State<EditProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  late TextEditingController _hometownController;
  late TextEditingController _profileImageController;
  late TextEditingController _coverImageController;

  String? _selectedResidentType;
  bool _isUploadingProfile = false;
  bool _isUploadingCover   = false;

  final _s3 = S3UploadService();
  final _picker = ImagePicker();

  final List<String> _residentTypes = [
    'owner',
    'tenant',
    'family_member',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _bioController = TextEditingController(text: widget.user.bio);
    _professionController = TextEditingController(text: widget.user.profession);
    _hometownController = TextEditingController(text: widget.user.hometown);
    _profileImageController = TextEditingController(
      text: widget.user.profileImage,
    );
    _coverImageController = TextEditingController(
      text: widget.user.coverImageUrl,
    );

    if (_residentTypes.contains(widget.user.residentType)) {
      _selectedResidentType = widget.user.residentType;
    } else {
      _selectedResidentType = _residentTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    _hometownController.dispose();
    _profileImageController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        UpdateProfileInfo(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          bio: _bioController.text.trim(),
          profession: _professionController.text.trim(),
          hometown: _hometownController.text.trim(),
          residentType: _selectedResidentType,
          profileImage: _profileImageController.text.trim().isEmpty
              ? null
              : _profileImageController.text.trim(),
          coverImageUrl: _coverImageController.text.trim().isEmpty
              ? null
              : _coverImageController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final surfaceColor = isDarkMode
        ? AppTheme.surfaceDark
        : AppTheme.surfaceLight;
    final textColor = isDarkMode
        ? AppTheme.onPrimary
        : AppTheme.onBackgroundLight;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(state.user);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            elevation: 0,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Cover & Profile picture layout
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Cover photo banner
                          Container(
                            height: 170.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              image: _coverImageController.text.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        _coverImageController.text,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          // Avatar profile photo
                          Positioned(
                            bottom: -50.h,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4.w,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50.r,
                                    backgroundColor: surfaceColor,
                                    backgroundImage:
                                        _profileImageController.text.isNotEmpty
                                        ? NetworkImage(
                                            _profileImageController.text,
                                          )
                                        : const NetworkImage(
                                            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _isUploadingProfile
                                        ? null
                                        : () => _pickAndUpload(
                                              _profileImageController,
                                              isProfile: true,
                                            ),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.w,
                                        ),
                                      ),
                                      child: _isUploadingProfile
                                          ? SizedBox(
                                              width: 16.sp,
                                              height: 16.sp,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              Icons.camera_alt,
                                              size: 16.sp,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit cover icon
                          Positioned(
                            top: 10.h,
                            right: 10.w,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: _isUploadingCover
                                  ? Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: SizedBox(
                                        width: 20.sp,
                                        height: 20.sp,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      tooltip: 'Change Cover Photo',
                                      onPressed: () => _pickAndUpload(
                                        _coverImageController,
                                        isProfile: false,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 60.h),
                      // Fields list inside card
                      Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Info',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Name field
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: textColor),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name cannot be empty';
                                  }
                                  if (value.length > 100) {
                                    return 'Name must be 100 characters or less';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: textColor),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email cannot be empty';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+$',
                                  );
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              // Resident Type Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedResidentType,
                                decoration: const InputDecoration(
                                  labelText: 'Resident Type',
                                  prefixIcon: Icon(Icons.home_work),
                                  border: OutlineInputBorder(),
                                ),
                                dropdownColor: surfaceColor,
                                style: TextStyle(color: textColor),
                                items: _residentTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(
                                      type[0].toUpperCase() +
                                          type
                                              .substring(1)
                                              .replaceAll('_', ' '),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedResidentType = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'More Details',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Profession
                              TextFormField(
                                controller: _professionController,
                                decoration: const InputDecoration(
                                  labelText: 'Profession',
                                  prefixIcon: Icon(Icons.work),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: textColor),
                                validator: (value) {
                                  if (value != null && value.length > 150) {
                                    return 'Profession must be 150 characters or less';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              // Hometown
                              TextFormField(
                                controller: _hometownController,
                                decoration: const InputDecoration(
                                  labelText: 'Hometown',
                                  prefixIcon: Icon(Icons.location_city),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: textColor),
                                validator: (value) {
                                  if (value != null && value.length > 150) {
                                    return 'Hometown must be 150 characters or less';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16.h),
                              // Bio (Multi-line)
                              TextFormField(
                                controller: _bioController,
                                decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  prefixIcon: Icon(Icons.info_outline),
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                style: TextStyle(color: textColor),
                                maxLines: 3,
                                maxLength: 500,
                                validator: (value) {
                                  if (value != null && value.length > 500) {
                                    return 'Bio must be 500 characters or less';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 100.h), // Space for save button
                    ],
                  ),
                ),
              ),
              if (state is ProfileUpdating)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          bottomSheet: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: state is ProfileUpdating ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Save Profile Changes',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Pick an image from gallery and upload it to S3.
  /// [controller] is updated with the returned public URL.
  /// [isProfile] distinguishes profile vs cover photo for the loading flag.
  Future<void> _pickAndUpload(
    TextEditingController controller, {
    required bool isProfile,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      if (isProfile) {
        _isUploadingProfile = true;
      } else {
        _isUploadingCover = true;
      }
    });

    try {
      final url = await _s3.uploadImage(
        File(picked.path),
        folder: S3UploadService.folderProfiles,
      );
      setState(() => controller.text = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingProfile = false;
          _isUploadingCover   = false;
        });
      }
    }
  }
}
