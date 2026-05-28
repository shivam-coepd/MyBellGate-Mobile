import 'package:flutter/material.dart';
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Breathing + fade animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);

    // Trigger app startup
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OnboardingState) {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          } else if (state is Unauthenticated) {
            Navigator.of(context).pushReplacementNamed('/auth');
            // Navigator.of(context).pushReplacementNamed('/location-selection');
          } else if (state is Authenticated) {
            final selectedRole = AppConfig.selectedRole ?? 'resident';
            Widget nextScreen;

            switch (selectedRole) {
              case 'guard':
                nextScreen = const GuardMainScreen();
                break;
              default:
                nextScreen = state.user.isApproved == false
                    ? const ApprovalPendingScreen()
                    : const ResidentMainScreen();
            }

            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Color(0xFF006D77),
                // Color(0xFF005A63),
                AppTheme.primary,
                AppTheme.primaryDark,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative Circles
              Positioned(
                top: -100.h,
                left: -100.w,
                child: Container(
                  width: 300.r,
                  height: 300.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -150.h,
                right: -150.w,
                child: Container(
                  width: 400.r,
                  height: 400.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                top: 100.h,
                right: 50.w,
                child: Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.onPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 150.h,
                left: 30.w,
                child: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.onPrimary.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Main Animated Content
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            Container(
                              width: 140.r,
                              height: 140.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.onPrimary.withValues(
                                  alpha: 0.25,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.onPrimary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 30.r,
                                    spreadRadius: 10.r,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 110.r,
                                  height: 110.r,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.onPrimary,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      "assets/images/app_logo.png",
                                      width: 70.w,
                                      height: 70.w,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // App Name
                            Text(
                              'MyGateBell',
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onPrimary,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.onBackgroundDark.withValues(
                                      alpha: 0.26,
                                    ),
                                    offset: Offset(0, 2),
                                    blurRadius: 8.r,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Tagline
                            Text(
                              'Connect. Simplify. Thrive.',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: AppTheme.onPrimary,
                                letterSpacing: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 80.h),

                            // Custom Breathing Loader
                            SizedBox(
                              width: 60.r,
                              height: 60.r,
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.onPrimary,
                                ),
                                strokeWidth: 5.w,
                                backgroundColor: AppTheme.onPrimary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppTheme.onPrimary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
