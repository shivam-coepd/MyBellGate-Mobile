// ignore_for_file: unused_element

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/screens/guard/details/multilingual_support_screen.dart';
import 'package:mygate_coepd/screens/common/security_privacy_screen.dart';
import 'package:mygate_coepd/screens/common/support_feedback_screen.dart';
import 'package:mygate_coepd/screens/common/about_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/blocs/theme/theme_cubit.dart';

class GuardProfileScreen extends StatefulWidget {
  const GuardProfileScreen({super.key});

  @override
  State<GuardProfileScreen> createState() => _GuardProfileScreenState();
}

class _GuardProfileScreenState extends State<GuardProfileScreen> {
  bool _isOffline = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Hindi',
    'Kannada',
    'Gujarati',
    'Tamil',
    'Telugu',
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {
      'title': 'Visitor Entry Approved',
      'description': 'Approved entry for Rahul Kumar to A-101',
      'time': '10:30 AM',
      'icon': Icons.person,
      'color': Colors.blue,
    },
    {
      'title': 'Patrol Completed',
      'description': 'Completed Main Gate Route patrol',
      'time': '09:15 AM',
      'icon': Icons.directions_walk,
      'color': Colors.green,
    },
    {
      'title': 'Attendance Marked',
      'description': 'Morning shift attendance marked',
      'time': '08:00 AM',
      'icon': Icons.check_circle,
      'color': Colors.orange,
    },
  ];

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutRequested());
                // Navigate to login screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              ..._languages.map(
                (language) => RadioListTile<String>(
                  title: Text(language),
                  value: language,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToMultilingualSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MultilingualSupportScreen(),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  void checkInternet() async {
    bool isConnected = await AppInternetCheck().hasInternetConnection();

    if (isConnected) {
      setState(() {
        _isOffline = false;
      });
    } else {
      setState(() {
        _isOffline = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  spacing: 20.h,
                  children: [
                    // Offline Banner
                    if (_isOffline)
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.wifi_off, color: Colors.white),
                                SizedBox(width: 10.w),
                                const Text(
                                  'Offline Mode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isOffline = false;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Profile Header
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        elevation: 4,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              Row(
                                spacing: 10.w,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // 🧾 Left Side — Profile Info
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Name
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: 5.h),

                                      // Role Badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Text(
                                          'Security Guard',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primary
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 10.r,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 45.r,
                                          backgroundColor: Colors.white,
                                          backgroundImage:
                                              user.profileImage != null
                                              ? CachedNetworkImageProvider(
                                                  user.profileImage!,
                                                )
                                              : null,
                                          child: user.profileImage == null
                                              ? Icon(
                                                  Icons.person,
                                                  size: 50.sp,
                                                  color: AppTheme.primary,
                                                )
                                              : null,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            // edit profile image
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5.w),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 16.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 14.h),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              SizedBox(height: 10.h),

                              // Info rows
                              _buildInfoItem(Icons.email_outlined, user.email),
                              SizedBox(height: 10.h),
                              _buildInfoItem(Icons.phone_outlined, user.phone),
                              SizedBox(height: 10.h),
                              _buildInfoItem(
                                Icons.badge_outlined,
                                '${user.appUserId}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Account Settings
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            spacing: 6.h,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.notifications_outlined,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Notifications',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                  activeThumbColor: AppTheme.primary,
                                ),
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.fingerprint,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Biometric Login',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Switch(
                                  value: _biometricEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _biometricEnabled = value;
                                    });
                                  },
                                  activeThumbColor: AppTheme.primary,
                                ),
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.dark_mode_outlined,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Dark Theme',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Switch(
                                  value:
                                      context.watch<ThemeCubit>().state ==
                                      ThemeMode.dark,
                                  onChanged: (value) {
                                    context.read<ThemeCubit>().updateTheme(
                                      value ? ThemeMode.dark : ThemeMode.light,
                                    );
                                  },
                                  activeThumbColor: AppTheme.primary,
                                ),
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.language,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Language',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                subtitle: Text(
                                  _selectedLanguage,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.sp,
                                ),
                                onTap: _navigateToMultilingualSupport,
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.lock_outline,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Change Password',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SecurityPrivacyScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Support Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            spacing: 6.h,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.help_outline_outlined,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Help Center',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SupportFeedbackScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.feedback_outlined,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Send Feedback',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SupportFeedbackScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: AppTheme.primary,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'About',
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20.sp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AboutScreen(),
                                    ),
                                  );
                                },
                              ),
                              Divider(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: AppTheme.error,
                                    size: 24.sp,
                                  ),
                                ),
                                title: Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppTheme.error,
                                  ),
                                ),
                                onTap: () => _showLogoutConfirmation(),
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
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppTheme.primary, size: 20.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
