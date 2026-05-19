import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingPages = [
    {
      'title': 'Welcome to MyGateBell',
      'description': 'Your complete solution for seamless community living',
      'image':
          'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&q=80&w=800&h=1000',
    },
    {
      'title': 'Manage Visitors',
      'description': 'Pre-approve and track visitors with just a few taps',
      'image':
          'https://images.unsplash.com/photo-1543269865-cbf427effbad?auto=format&fit=crop&q=80&w=800&h=1000',
    },
    {
      'title': 'Stay Connected',
      'description': 'Get updates, announcements and chat with neighbors',
      'image':
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&q=80&w=800&h=1000',
    },
    {
      'title': 'Simplify Payments',
      'description': 'Track bills and make payments effortlessly',
      'image':
          'https://images.unsplash.com/photo-1589758438368-0ad531db3366?auto=format&fit=crop&q=80&w=800&h=1000',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingPages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _onboardingPages[index];
              return _buildPage(
                imageUrl: page['image']!,
                title: page['title']!,
                description: page['description']!,
              );
            },
          ),

          // Top Skip Button
          Positioned(
            top: 50.h,
            right: 24.w,
            child: TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(OnboardingCompleted());
                Navigator.of(context).pushReplacementNamed('/role-selection');
              },
              child: Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppTheme.onPrimary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom Section: Dots + Button
          Positioned(
            bottom: 100.h,
            left: 24.w,
            right: 24.w,
            child: Column(
              children: [
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.symmetric(horizontal: 6.w),
                      width: _currentPage == index ? 28.w : 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? primaryColor
                            : (isDarkMode ? AppTheme.onPrimary.withValues(alpha: 0.38) : AppTheme.onBackgroundLight),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // Next / Get Started Button
                SizedBox(
                  width: 220.w,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingPages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.read<AuthBloc>().add(OnboardingCompleted());
                        Navigator.of(context).pushReplacementNamed('/role-selection');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 8,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      _currentPage == _onboardingPages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String imageUrl,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        // Image Section
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) => const Icon(Icons.broken_image, size: 80),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.onPrimary.withValues(alpha: 0.0),
                    AppTheme.onBackgroundDark.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(28.w, 80.h, 28.w, 40.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onPrimary,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: AppTheme.onPrimary.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Empty bottom space (filled by positioned widget)
        Expanded(
          flex: 2,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
      ],
    );
  }
}