import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_bloc.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class GuardEditProfileScreen extends StatefulWidget {
  final User user;

  const GuardEditProfileScreen({super.key, required this.user});

  @override
  State<GuardEditProfileScreen> createState() => _GuardEditProfileScreenState();
}

class _GuardEditProfileScreenState extends State<GuardEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _professionController;
  late TextEditingController _hometownController;
  late TextEditingController _profileImageController;

  bool _isUploadingProfile = false;
  bool _isUploadingCover = false;
  File? _pickedProfileImage;
  File? _pickedCoverImage;

  final _s3 = S3UploadService();
  final _picker = ImagePicker();

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    _hometownController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final hasConn = await AppInternetCheck().hasInternetConnection();
    if (!hasConn) {
      if (mounted) {
        AppInternetCheck.checkInternet(context: context);
      }
      return;
    }

    setState(() {
      _isUploadingProfile = _pickedProfileImage != null;
      _isUploadingCover = _pickedCoverImage != null;
    });

    try {
      String? uploadedProfileUrl;
      // ignore: unused_local_variable
      String? uploadedCoverUrl;

      if (_pickedProfileImage != null) {
        uploadedProfileUrl = await _s3.uploadImage(
          _pickedProfileImage!,
          folder: S3UploadService.folderProfiles,
        );
      }

      if (_pickedCoverImage != null) {
        uploadedCoverUrl = await _s3.uploadImage(
          _pickedCoverImage!,
          folder: S3UploadService.folderProfiles,
        );
      }

      if (!mounted) return;

      context.read<ProfileBloc>().add(
        UpdateProfileInfo(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          bio: _bioController.text.trim(),
          profession: _professionController.text.trim(),
          hometown: _hometownController.text.trim(),
          residentType: widget.user.residentType,
          profileImage:
              uploadedProfileUrl ??
              (_profileImageController.text.trim().isEmpty
                  ? null
                  : _profileImageController.text.trim()),
        ),
      );
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          message: 'Image upload failed: $e',
          type: SnackBarType.error,
        );
        setState(() {
          _isUploadingProfile = false;
          _isUploadingCover = false;
        });
      }
    }
  }

  Future<void> _pickImage({required bool isProfile}) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() {
        if (isProfile) {
          _pickedProfileImage = File(picked.path);
        } else {
          _pickedCoverImage = File(picked.path);
        }
      });
    } catch (e) {
      AppSnackbar.show(
        context: context,
        message: 'Failed to pick image: $e',
        type: SnackBarType.error,
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
          // Sync AuthBloc with the new updated user
          context.read<AuthBloc>().add(UserUpdated(state.user));

          AppSnackbar.show(
            context: context,
            message: 'Profile updated successfully!',
            type: SnackBarType.success,
          );
          Navigator.of(context).pop(state.user);
        } else if (state is ProfileError) {
          AppSnackbar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile'), elevation: 0),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar profile photo
                      Positioned(
                        bottom: 0,
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
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50.r,
                                backgroundColor: surfaceColor,
                                backgroundImage: _pickedProfileImage != null
                                    ? FileImage(_pickedProfileImage!)
                                          as ImageProvider
                                    : (_profileImageController.text.isNotEmpty
                                          ? NetworkImage(
                                              _profileImageController.text,
                                            )
                                          : null),
                                child:
                                    _pickedProfileImage == null &&
                                        _profileImageController.text.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 50.sp,
                                        color: primaryColor,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _isUploadingProfile
                                    ? null
                                    : () => _pickImage(isProfile: true),
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
                      SizedBox(height: 16.h),
                      // Fields list inside card
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duty & Biography',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Profession (Shift / Designation)
                              TextFormField(
                                controller: _professionController,
                                decoration: const InputDecoration(
                                  labelText: 'Shift / Designation',
                                  prefixIcon: Icon(Icons.work),
                                  border: OutlineInputBorder(),
                                ),
                                style: TextStyle(color: textColor),
                                validator: (value) {
                                  if (value != null && value.length > 150) {
                                    return 'Shift/Designation must be 150 characters or less';
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
                  color: Colors.black.withOpacity(0.05),
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
}
