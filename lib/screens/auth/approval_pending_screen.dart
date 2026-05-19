import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class ApprovalPendingScreen extends StatelessWidget {
  const ApprovalPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppTheme.onPrimary : AppTheme.onBackgroundLight;
    final subtitleColor = isDarkMode ? AppTheme.onPrimary.withValues(alpha: 0.7) : AppTheme.onBackgroundLight;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pending Icon
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Icon(
                  Icons.access_time,
                  size: 60.r,
                  color: AppTheme.warning,
                ),
              ),
              SizedBox(height: 30.h),

              // Title
              Text(
                'Approval Pending',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 20.h),

              // Description
              Text(
                'Your registration is awaiting approval from the society administrator. You\'ll receive a notification once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: subtitleColor,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),

              // Status Card
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isDarkMode
                      ? null
                      : [
                          BoxShadow(
                            color: AppTheme.onBackgroundLight.withValues(alpha: 0.1),
                            blurRadius: 12.r,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                ),
                child: Column(
                  children: [
                    _buildStatusItem(
                      context,
                      title: 'Registration Submitted',
                      subtitle: _formatDateTime(DateTime.now()),
                      completed: true,
                    ),
                    SizedBox(height: 20.h),
                    _buildStatusItem(
                      context,
                      title: 'Approval Received',
                      subtitle: 'Pending',
                      completed: false,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // Check Status Button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () {
                    // Add real-time status check logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Checking approval status...'),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primary, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'Check Status',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Logout Button
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool completed,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: completed
                ? primaryColor.withValues(alpha: 0.15)
                : AppTheme.onBackgroundLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? primaryColor : AppTheme.onBackgroundLight,
            size: 24.r,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: completed
                      ? (isDarkMode ? AppTheme.onPrimary : AppTheme.onBackgroundLight)
                      : AppTheme.onBackgroundLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.onBackgroundLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/$year at $hour:$minute $period';
  }
}