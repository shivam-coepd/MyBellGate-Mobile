import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/screens/resident/resident_main_screen.dart';
import 'package:mygate_coepd/screens/guard/guard_main_screen.dart';
import 'package:mygate_coepd/screens/admin/admin_main_screen.dart';
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
    context.read<AuthBloc>().add(
      OtpRequested(phone: widget.phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
            } else if (selectedRole == 'admin') {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AdminMainScreen(),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verify Code', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 12),
                Text(
                  'Please enter the 6-digit verification code sent to your device.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  'Phone: ${widget.phone}',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 16,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: TextStyle(color: Colors.grey.shade200),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Enter a valid 6-digit code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: theme.primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Verify & Continue', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _requestOtp,
                    child: Text(
                      "Didn't receive the code? Resend",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
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