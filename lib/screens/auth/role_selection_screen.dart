import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  late final bool isDarkMode;
  late final Color backgroundColor;
  late final Color textColor;
  late final Color secondaryTextColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    backgroundColor = isDarkMode ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    textColor = isDarkMode ? AppTheme.onPrimary : AppTheme.onBackgroundLight;
    secondaryTextColor = isDarkMode
        ? AppTheme.onPrimary.withValues(alpha: 0.7)
        : AppTheme.onBackgroundLight.withValues(alpha: 0.6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Circles
            Positioned(
              top: -150.h,
              left: -150.w,
              child: Container(
                width: 350.r,
                height: 350.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.onPrimary.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -200.h,
              right: -200.w,
              child: Container(
                width: 450.r,
                height: 450.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.onPrimary.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: 80.h,
              right: 40.w,
              child: Container(
                width: 60.r,
                height: 60.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.onPrimary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 120.h,
              left: 30.w,
              child: Container(
                width: 45.r,
                height: 45.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.onPrimary.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                SizedBox(height: 80.h),

                // Logo
                Container(
                  width: 110.r,
                  height: 110.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.onPrimary.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Container(
                      width: 85.r,
                      height: 85.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.onPrimary,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.home_outlined,
                          size: 48.r,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                Text(
                  'MyGateBell',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),

                Text(
                  'Connect. Simplify. Thrive.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.onPrimary.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 50.h),

                // Role Cards Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Your Role',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            'Select how you\'ll be using MyGateBell',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: secondaryTextColor,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Role Cards
                          _buildRoleCard(
                            title: 'Resident',
                            description:
                                'For community members living in the society',
                            icon: Icons.home_outlined,
                            role: 'resident',
                          ),
                          SizedBox(height: 20.h),
                          _buildRoleCard(
                            title: 'Security Guard',
                            description:
                                'For security personnel managing entries and safety',
                            icon: Icons.shield_outlined,
                            role: 'guard',
                          ),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required IconData icon,
    required String role,
  }) {
    final cardColor = isDarkMode ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    final borderColor = isDarkMode
        ? AppTheme.onBackgroundLight.withValues(alpha: 0.4)
        : AppTheme.onBackgroundLight.withValues(alpha: 0.08);
    final shadowColor = isDarkMode
        ? AppTheme.onBackgroundLight.withValues(alpha: 0.15)
        : AppTheme.onBackgroundDark.withValues(alpha: 0.5);
    final primaryColor = AppTheme.primary;

    return GestureDetector(
      onTap: () {
        context.read<AuthBloc>().add(RoleSelected(role: role));
        Navigator.of(context).pushNamed('/auth');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20.r,
              offset: Offset(0, 8.h),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          spacing: 14.w,
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(icon, color: primaryColor, size: 36.r),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 22.r,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
