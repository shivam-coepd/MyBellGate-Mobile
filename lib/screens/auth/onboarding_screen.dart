import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _buttonAnimationController;
  late final AnimationController _slideAnimationController;
  late final AnimationController _fadeAnimationController;

  int _currentPage = 0;
  bool _isLastPage = false;

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'title': 'Welcome to MyGateBell',
      'description':
          'Your complete solution for seamless community living. Manage everything from visitors to payments in one place.',
      'icon': Icons.apartment_rounded,
      'color': Color(0xFF6C63FF),
      'gradient': [Color(0xFF6C63FF), Color(0xFF4A44D6)],
      'image': 'assets/images/onboarding_01.png',
    },
    {
      'title': 'Smart Visitor Management',
      'description':
          'Pre-approve guests, track deliveries, and receive real-time notifications when someone arrives at your gate.',
      'icon': Icons.people_alt_rounded,
      'color': Color(0xFF00BFA6),
      'gradient': [Color(0xFF00BFA6), Color(0xFF00897B)],
      'image': 'assets/images/onboarding_02.png',
    },
    {
      'title': 'Stay Connected',
      'description':
          'Get instant updates, community announcements, and chat with your neighbors effortlessly.',
      'icon': Icons.chat_bubble_rounded,
      'color': Color(0xFFFF6584),
      'gradient': [Color(0xFFFF6584), Color(0xFFE91E63)],
      'image': 'assets/images/onboarding_03.png',
    },
    {
      'title': 'Hassle-free Payments',
      'description':
          'Track maintenance bills, pay dues, and manage all community finances with just a few taps.',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFFFFA726),
      'gradient': [Color(0xFFFFA726), Color(0xFFFF7043)],
      'image': 'assets/images/onboarding_04.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonAnimationController.dispose();
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _isLastPage = index == _onboardingPages.length - 1;
    });

    // Reset and replay animations
    _fadeAnimationController.reset();
    _slideAnimationController.reset();
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    context.read<AuthBloc>().add(OnboardingCompleted());
    Navigator.of(context).pushReplacementNamed('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final currentPageData = _onboardingPages[_currentPage];

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0F0F1B) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Skip ──
            // _buildTopBar(isDarkMode),

            // ── Main Content Area ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildPageContent(
                    pageData: _onboardingPages[index],
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            ),

            // ── Bottom Section: Progress + Button ──
            _buildBottomSection(isDarkMode, currentPageData),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopBar(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo / Brand
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A44D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'MyGateBell',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          // Skip Button
          AnimatedOpacity(
            opacity: _isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: TextButton(
              onPressed: _isLastPage ? null : _finishOnboarding,
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.grey.shade600,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                'Skip',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PAGE CONTENT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPageContent({
    required Map<String, dynamic> pageData,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Animated Illustration Area ──
          _buildAnimatedIllustration(pageData, isDarkMode),

          SizedBox(height: 48.h),

          // ── Title ──
          AnimatedBuilder(
            animation: _slideAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - _slideAnimationController.value)),
                child: Opacity(
                  opacity: _slideAnimationController.value,
                  child: child,
                ),
              );
            },
            child: Text(
              pageData['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color(0xFF1A1A2E),
                height: 1.3,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // ── Description ──
          AnimatedBuilder(
            animation: _slideAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 40 * (1 - _slideAnimationController.value)),
                child: Opacity(
                  opacity: _slideAnimationController.value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Text(
              pageData['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ANIMATED ILLUSTRATION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAnimatedIllustration(
    Map<String, dynamic> pageData,
    bool isDarkMode,
  ) {
    final List<Color> gradient = List<Color>.from(pageData['gradient'] as List);
    final IconData icon = pageData['icon'] as IconData;

    return AnimatedBuilder(
      animation: _fadeAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _fadeAnimationController.value),
          child: Opacity(opacity: _fadeAnimationController.value, child: child),
        );
      },
      child: Container(
        width: 280.w,
        height: 280.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient[0].withValues(alpha: 0.15),
              gradient[1].withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 2,
                    sigmaY: 2,
                  ), // Small blur amount
                  child: Image.asset(
                    pageData['image'],
                    width: 280.w,
                    height: 280.w,
                  ),
                ),
              ),
            ),
            // Decorative circles
            ...List.generate(3, (index) {
              return Positioned(
                top: 20.h + (index * 30),
                right: 20.w + (index * 20),
                child: Container(
                  width: (20 + index * 15).w,
                  height: (20 + index * 15).h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: gradient[0].withValues(alpha: 0.1 - (index * 0.02)),
                  ),
                ),
              );
            }),

            // Main icon with glow
            Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26.r),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  ),
                  BoxShadow(
                    color: gradient[1].withValues(alpha: 0.2),
                    blurRadius: 60,
                    offset: Offset(0, 30),
                  ),
                ],
              ),
              // child: Icon(icon, size: 60.sp, color: Colors.white),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26.r),
                child: Image.asset(
                  pageData['image'],
                  width: 160.w,
                  height: 160.w,
                ),
              ),
            ),

            // Floating badge
            Positioned(
              bottom: 30.h,
              right: 30.w,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: gradient[0],
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomSection(
    bool isDarkMode,
    Map<String, dynamic> currentPageData,
  ) {
    final List<Color> gradient = List<Color>.from(
      currentPageData['gradient'] as List,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(32.w, 24.h, 32.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Progress Indicators ──
          _buildProgressIndicators(isDarkMode, gradient),

          SizedBox(height: 32.h),

          // ── Navigation Buttons ──
          _buildNavigationButtons(gradient),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PROGRESS INDICATORS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProgressIndicators(bool isDarkMode, List<Color> activeGradient) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_onboardingPages.length, (index) {
        final isActive = index == _currentPage;
        final pageColor = _onboardingPages[index]['color'] as Color;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 32.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            gradient: isActive ? LinearGradient(colors: activeGradient) : null,
            color: isActive
                ? null
                : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION BUTTONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildNavigationButtons(List<Color> gradient) {
    return Row(
      children: [
        // Back Button (hidden on first page)
        AnimatedOpacity(
          opacity: _currentPage > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage > 0 ? 56.w : 0,
            height: 56.h,
            child: _currentPage > 0
                ? MaterialButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    elevation: 0,
                    shape: CircleBorder(),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey.shade700,
                      size: 24.sp,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),

        SizedBox(width: _currentPage > 0 ? 16.w : 0),

        // Next / Get Started Button
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: MaterialButton(
              onPressed: _nextPage,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLastPage ? 'Get Started' : 'Next',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLastPage
                        ? Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 22.sp,
                            key: ValueKey('check'),
                          )
                        : Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22.sp,
                            key: ValueKey('arrow'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
// import 'package:mygate_coepd/blocs/auth/auth_event.dart';
// import 'package:mygate_coepd/theme/app_theme.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<Map<String, String>> _onboardingPages = [
//     {
//       'title': 'Welcome to MyGateBell',
//       'description': 'Your complete solution for seamless community living',
//       'image':
//           'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&q=80&w=800&h=1000',
//     },
//     {
//       'title': 'Manage Visitors',
//       'description': 'Pre-approve and track visitors with just a few taps',
//       'image':
//           'https://images.unsplash.com/photo-1543269865-cbf427effbad?auto=format&fit=crop&q=80&w=800&h=1000',
//     },
//     {
//       'title': 'Stay Connected',
//       'description': 'Get updates, announcements and chat with neighbors',
//       'image':
//           'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&q=80&w=800&h=1000',
//     },
//     {
//       'title': 'Simplify Payments',
//       'description': 'Track bills and make payments effortlessly',
//       'image':
//           'https://images.unsplash.com/photo-1589758438368-0ad531db3366?auto=format&fit=crop&q=80&w=800&h=1000',
//     },
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = Theme.of(context).primaryColor;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // PageView
//           PageView.builder(
//             controller: _pageController,
//             itemCount: _onboardingPages.length,
//             onPageChanged: (index) => setState(() => _currentPage = index),
//             itemBuilder: (context, index) {
//               final page = _onboardingPages[index];
//               return _buildPage(
//                 imageUrl: page['image']!,
//                 title: page['title']!,
//                 description: page['description']!,
//               );
//             },
//           ),

//           // Top Skip Button
//           Positioned(
//             top: 50.h,
//             right: 24.w,
//             child: TextButton(
//               onPressed: () {
//                 context.read<AuthBloc>().add(OnboardingCompleted());
//                 Navigator.of(context).pushReplacementNamed('/role-selection');
//               },
//               child: Text(
//                 'Skip',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   color: AppTheme.onPrimary.withValues(alpha: 0.7),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),

//           // Bottom Section: Dots + Button
//           Positioned(
//             bottom: 100.h,
//             left: 24.w,
//             right: 24.w,
//             child: Column(
//               children: [
//                 // Page Indicators
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     _onboardingPages.length,
//                     (index) => AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                       margin: EdgeInsets.symmetric(horizontal: 6.w),
//                       width: _currentPage == index ? 28.w : 10.w,
//                       height: 10.h,
//                       decoration: BoxDecoration(
//                         color: _currentPage == index
//                             ? primaryColor
//                             : (isDarkMode ? AppTheme.onPrimary.withValues(alpha: 0.38) : AppTheme.onBackgroundLight),
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 40.h),

//                 // Next / Get Started Button
//                 SizedBox(
//                   width: 220.w,
//                   height: 56.h,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_currentPage < _onboardingPages.length - 1) {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 400),
//                           curve: Curves.easeInOut,
//                         );
//                       } else {
//                         context.read<AuthBloc>().add(OnboardingCompleted());
//                         Navigator.of(context).pushReplacementNamed('/role-selection');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       elevation: 8,
//                       shadowColor: primaryColor.withValues(alpha: 0.4),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30.r),
//                       ),
//                     ),
//                     child: Text(
//                       _currentPage == _onboardingPages.length - 1
//                           ? 'Get Started'
//                           : 'Next',
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.onPrimary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPage({
//     required String imageUrl,
//     required String title,
//     required String description,
//   }) {
//     return Column(
//       children: [
//         // Image Section
//         Expanded(
//           flex: 3,
//           child: Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(imageUrl),
//                 fit: BoxFit.cover,
//                 onError: (exception, stackTrace) => const Icon(Icons.broken_image, size: 80),
//               ),
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     AppTheme.onPrimary.withValues(alpha: 0.0),
//                     AppTheme.onBackgroundDark.withValues(alpha: 0.7),
//                   ],
//                   stops: const [0.4, 1.0],
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(28.w, 80.h, 28.w, 40.h),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 32.sp,
//                         fontWeight: FontWeight.bold,
//                         color: AppTheme.onPrimary,
//                         height: 1.2,
//                       ),
//                     ),
//                     SizedBox(height: 16.h),
//                     Text(
//                       description,
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         color: AppTheme.onPrimary.withValues(alpha: 0.7),
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Empty bottom space (filled by positioned widget)
//         Expanded(
//           flex: 2,
//           child: Container(
//             color: Theme.of(context).scaffoldBackgroundColor,
//           ),
//         ),
//       ],
//     );
//   }
// }