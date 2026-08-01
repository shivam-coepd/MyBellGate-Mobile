import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/screens/resident/resident_main_screen.dart';
import 'package:mygate_coepd/screens/guard/guard_main_screen.dart';
import 'package:mygate_coepd/screens/auth/approval_pending_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final bool _isLogin = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _societyIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill phone if remember device is enabled
    // Only pre-fill actual phone numbers, not role names
    if (AppConfig.rememberDevice && AppConfig.selectedRole != null) {
      // Check if the stored value is actually a phone number (10-15 digits)
      final selectedRole = AppConfig.selectedRole ?? '';
      if (RegExp(r'^[0-9]{10,15}$').hasMatch(selectedRole)) {
        _phoneController.text = selectedRole;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _unitController.dispose();
    _societyIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        context.read<AuthBloc>().add(
          LoginRequested(
            phone: _phoneController.text,
            password: _passwordController.text,
            role: AppConfig.selectedRole ?? 'resident',
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          RegisterRequested(
            name: _nameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
            societyId: _societyIdController.text,
            unit: _unitController.text,
            role: AppConfig.selectedRole ?? 'resident',
            password: _passwordController.text,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedRole = AppConfig.selectedRole ?? 'resident';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.backgroundDark
        : AppTheme.backgroundLight;
    final surfaceColor = isDarkMode
        ? AppTheme.surfaceDark
        : AppTheme.surfaceLight;
    final textColor = isDarkMode
        ? AppTheme.onPrimary
        : AppTheme.onBackgroundLight;
    final secondaryTextColor = isDarkMode
        ? AppTheme.onPrimary.withValues(alpha: 0.7)
        : AppTheme.onBackgroundLight;
    final iconColor = AppTheme.primary;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor,
        child: Column(
          children: [
            // Header with role info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background elements
                  Positioned(
                    top: -30.h,
                    right: -30.w,
                    child: Container(
                      width: 120.r,
                      height: 120.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.onPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -25.h,
                    left: 30.w,
                    child: Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.onPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24.w,
                      right: 24.w,
                      top: 50.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppTheme.onPrimary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                selectedRole == 'guard'
                                    ? Icons.shield_outlined
                                    : selectedRole == 'admin'
                                    ? Icons.admin_panel_settings_outlined
                                    : Icons.home_outlined,
                                color: AppTheme.onPrimary,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logging in as',
                                  style: TextStyle(
                                    color: AppTheme.onPrimary.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  selectedRole == 'guard'
                                      ? 'Security Guard'
                                      : selectedRole == 'admin'
                                      ? 'Administrator'
                                      : 'Resident',
                                  style: TextStyle(
                                    color: AppTheme.onPrimary,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          _isLogin ? 'Welcome Back' : 'Join Your Community',
                          style: TextStyle(
                            color: AppTheme.onPrimary,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isLogin
                              ? 'Sign in to access your community'
                              : 'Create an account to get started',
                          style: TextStyle(
                            color: AppTheme.onPrimary.withValues(alpha: 0.9),
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Form content
            Expanded(
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    AppSnackbar.show(
                      context: context,
                      message: state.message,
                      type: SnackBarType.error,
                    );
                  } else if (state is Authenticated) {
                    // Navigate based on the actual user role from the database
                    final userRole = state.user.role;

                    if (userRole == 'guard') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const GuardMainScreen(),
                        ),
                        (route) => false,
                      );
                    } else if (userRole == 'resident') {
                      // Check if user is approved
                      if (state.user.isApproved == false) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const ApprovalPendingScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const ResidentMainScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    } else {
                      // Fallback for other roles or if not explicitly handled
                      AppSnackbar.show(
                        context: context,
                        message: 'Role not supported yet',
                        type: SnackBarType.error,
                      );
                    }
                  }
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isLogin) ...[
                          // Society ID for registration
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppTheme.onBackgroundLight
                                            .withValues(alpha: 0.1),
                                        blurRadius: 10.r,
                                        offset: Offset(0, 5.h),
                                      ),
                                    ],
                            ),
                            child: TextFormField(
                              controller: _societyIdController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Society ID',
                                labelStyle: TextStyle(
                                  color: secondaryTextColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.apartment_outlined,
                                  color: iconColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 18.h,
                                ),
                              ),
                              validator: (value) {
                                if (!_isLogin &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter society ID';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                          // Name for registration
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppTheme.onBackgroundLight
                                            .withValues(alpha: 0.1),
                                        blurRadius: 10.r,
                                        offset: Offset(0, 5.h),
                                      ),
                                    ],
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: TextStyle(
                                  color: secondaryTextColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: iconColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 18.h,
                                ),
                              ),
                              validator: (value) {
                                if (!_isLogin &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                          // Unit for resident registration
                          if (selectedRole == 'resident')
                            Container(
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: isDarkMode
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppTheme.onBackgroundLight
                                              .withValues(alpha: 0.1),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 5.h),
                                        ),
                                      ],
                              ),
                              child: TextFormField(
                                controller: _unitController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: 'Unit/Apartment Number',
                                  labelStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_on_outlined,
                                    color: iconColor,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 18.h,
                                  ),
                                ),
                                validator: (value) {
                                  if (!_isLogin &&
                                      selectedRole == 'resident' &&
                                      (value == null || value.isEmpty)) {
                                    return 'Please enter your unit number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          SizedBox(height: 20.h),
                        ],
                        // Phone number
                        Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: isDarkMode
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppTheme.onBackgroundLight
                                          .withValues(alpha: 0.1),
                                      blurRadius: 10.r,
                                      offset: Offset(0, 5.h),
                                    ),
                                  ],
                          ),
                          child: TextFormField(
                            controller: _phoneController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: iconColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 18.h,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Only digits
                              LengthLimitingTextInputFormatter(
                                10,
                              ), // Limit to 10 digits (invisible)
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              // Simple phone validation
                              if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Email address - Only show for registration
                        if (!_isLogin)
                          Container(
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppTheme.onBackgroundLight
                                            .withValues(alpha: 0.1),
                                        blurRadius: 10.r,
                                        offset: Offset(0, 5.h),
                                      ),
                                    ],
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: TextStyle(
                                  color: secondaryTextColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: iconColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 18.h,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (!_isLogin &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter your email address';
                                }
                                if (!_isLogin &&
                                    value != null &&
                                    !RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                        if (!_isLogin) SizedBox(height: 20.h),

                        // Password
                        Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: isDarkMode
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppTheme.onBackgroundLight
                                          .withValues(alpha: 0.1),
                                      blurRadius: 10.r,
                                      offset: Offset(0, 5.h),
                                    ),
                                  ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: secondaryTextColor),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: iconColor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: iconColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 18.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (!_isLogin && value.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 30.h),

                        SizedBox(
                          width: double.infinity,
                          height: 55.h,
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        _submitForm();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: iconColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: isDarkMode ? 2 : 5,
                                ),
                                child: state is AuthLoading
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.h,
                                        child: CircularProgressIndicator(
                                          color: AppTheme.onPrimary,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isLogin ? 'Sign In' : 'Sign Up',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.onPrimary,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Navigate to role selection screen
                              Navigator.of(
                                context,
                              ).pushNamed('/role-selection');
                            },
                            child: Text(
                              'Change Role',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: secondaryTextColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
