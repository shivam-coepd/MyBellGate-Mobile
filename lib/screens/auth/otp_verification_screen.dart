import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/screens/resident/resident_main_screen.dart';
import 'package:mygate_coepd/screens/guard/guard_main_screen.dart';
import 'package:mygate_coepd/screens/auth/approval_pending_screen.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final bool isLogin;
  final String? name;
  final String? email;
  final String? societyId;
  final String? unit;
  final String? role;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.isLogin,
    this.name,
    this.email,
    this.societyId,
    this.unit,
    this.role,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (widget.isLogin) {
        // Login with OTP
        context.read<AuthBloc>().add(
          LoginRequested(phone: widget.phone, otp: _otpController.text),
        );
      } else {
        // Register with OTP
        context.read<AuthBloc>().add(
          RegisterRequested(
            name: widget.name ?? '',
            phone: widget.phone,
            email: widget.email ?? '',
            societyId: widget.societyId ?? '',
            unit: widget.unit ?? '',
            role: widget.role ?? 'resident',
          ),
        );
      }
    }
  }

  void _requestOtp() {
    // Request OTP again
    context.read<AuthBloc>().add(OtpRequested(phone: widget.phone));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          } else if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is Authenticated) {
            setState(() {
              _isLoading = false;
            });
            // Navigate based on the selected role from AppConfig
            final selectedRole = AppConfig.selectedRole ?? 'resident';
            if (selectedRole == 'guard') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const GuardMainScreen(),
                ),
                (route) => false,
              );
            } else {
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
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: theme.colorScheme.surface,
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
                          IconButton(
                            alignment: Alignment.centerLeft,
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppTheme.onPrimary,
                              size: 24.sp,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'Verify Code',
                            style: TextStyle(
                              color: AppTheme.onPrimary,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Please enter the 6-digit verification code sent to your device.',
                            style: TextStyle(
                              color: AppTheme.onPrimary.withValues(alpha: 0.9),
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Phone: ${widget.phone}',
                            style: TextStyle(
                              color: AppTheme.onPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    } else if (state is Authenticated) {
                      final selectedRole = AppConfig.selectedRole ?? 'resident';
                      if (selectedRole == 'guard') {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const GuardMainScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        // Check if user is approved
                        if (state.user.isApproved == false) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ApprovalPendingScreen(),
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
                      }
                    }
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 16.sp,
                              color: theme.colorScheme.onBackground,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              hintStyle: TextStyle(color: Colors.grey.shade200),
                              filled: true,
                              fillColor: theme.colorScheme.onSurface.withValues(
                                alpha: 0.05,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 2.w,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.primaryColor,
                                  width: 2.w,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.length != 6 ||
                                  !RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Enter a valid 6-digit code';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 48.h),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 60),
                              backgroundColor: theme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              shadowColor: theme.primaryColor.withOpacity(0.4),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Verify & Continue',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 24.h),
                          Center(
                            child: TextButton(
                              onPressed: _requestOtp,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Didn't receive the code? ",
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Resend",
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
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
      ),
    );
  }
}
