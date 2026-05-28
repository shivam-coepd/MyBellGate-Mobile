import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  int _hoveredIndex = -1;

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Resident',
      'description':
          'Access visitor management, pay bills, book amenities, and stay connected with your community.',
      'icon': Icons.home_rounded,
      'role': 'resident',
      'gradient': [Color(0xFF6C63FF), Color(0xFF4A44D6)],
      'features': ['Visitor Pre-approval', 'Bill Payments', 'Community Chat'],
    },
    {
      'title': 'Security Guard',
      'description':
          'Manage visitor entries, monitor deliveries, and ensure community safety with digital tools.',
      'icon': Icons.shield_rounded,
      'role': 'guard',
      'gradient': [Color(0xFF00BFA6), Color(0xFF00897B)],
      'features': ['Entry Management', 'Real-time Alerts', 'Visitor Logs'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    HapticFeedback.mediumImpact();
    context.read<AuthBloc>().add(RoleSelected(role: role));
    Navigator.of(context).pushNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Animated Background Elements ──
          _buildBackgroundElements(isDarkMode),

          // ── Main Content ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Section ──
                _buildHeader(isDarkMode),
                SizedBox(height: 10.h),

                // ── Role Selection Cards ──
                Expanded(child: _buildRoleCardsSection(isDarkMode)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BACKGROUND ELEMENTS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBackgroundElements(bool isDarkMode) {
    return Stack(
      children: [
        // Top gradient orb
        Positioned(
          top: -100.h,
          right: -80.w,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.05),
                child: Container(
                  width: 300.w,
                  height: 300.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF6C63FF).withOpacity(0.15),
                        Color(0xFF6C63FF).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom gradient orb
        Positioned(
          bottom: -120.h,
          left: -100.w,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.08),
                child: Container(
                  width: 350.w,
                  height: 350.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF00BFA6).withOpacity(0.12),
                        Color(0xFF00BFA6).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Decorative dots pattern
        ...List.generate(8, (index) {
          return Positioned(
            top: (100 + index * 80).h,
            left: index.isEven ? (20 + index * 15).w : null,
            right: index.isOdd ? (30 + index * 10).w : null,
            child: Container(
              width: (4 + index % 3 * 2).w,
              height: (4 + index % 3 * 2).h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade300.withOpacity(0.5),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 32.h),

          // Welcome Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Color(0xFF1A1A2E),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'How would you like to use MyGateBell?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ROLE CARDS SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRoleCardsSection(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: _roles.length,
        itemBuilder: (context, index) {
          final role = _roles[index];
          final List<Color> gradient = List<Color>.from(
            role['gradient'] as List,
          );

          return AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              final delay = index * 0.2;
              final value =
                  (_slideController.value - delay).clamp(0.0, 1.0) /
                  (1 - delay);
              return Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: Opacity(opacity: value.clamp(0.3, 1.0), child: child),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildRoleCard(
                role: role,
                gradient: gradient,
                isDarkMode: isDarkMode,
                index: index,
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ROLE CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRoleCard({
    required Map<String, dynamic> role,
    required List<Color> gradient,
    required bool isDarkMode,
    required int index,
  }) {
    final bool isHovered = _hoveredIndex == index;
    final List<String> features = List<String>.from(role['features'] as List);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: () => _selectRole(role['role'] as String),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isHovered
                  ? gradient[0].withOpacity(0.5)
                  : isDarkMode
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade200,
              width: isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? gradient[0].withOpacity(0.2)
                    : isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.shade200.withOpacity(0.8),
                blurRadius: isHovered ? 25 : 15,
                offset: Offset(0, isHovered ? 12 : 6),
                spreadRadius: isHovered ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Icon + Title + Arrow
                      Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: gradient[0].withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              role['icon'] as IconData,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // Title & Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  role['title'] as String,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Color(0xFF1A1A2E),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: gradient),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    'Tap to Select',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            transform: Matrix4.identity()
                              ..translate(isHovered ? 4.0 : 0.0, 0.0, 0.0),
                            child: Container(
                              width: 36.w,
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? gradient[0].withOpacity(0.1)
                                    : isDarkMode
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: isHovered
                                    ? gradient[0]
                                    : isDarkMode
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.grey.shade400,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Description
                      Text(
                        role['description'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.5)
                              : Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Feature Chips
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: features.map((feature) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : gradient[0].withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.1)
                                    : gradient[0].withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: gradient[0],
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.7)
                                        : gradient[0].withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
// import 'package:mygate_coepd/blocs/auth/auth_event.dart';
// import 'package:mygate_coepd/theme/app_theme.dart';

// class RoleSelectionScreen extends StatefulWidget {
//   const RoleSelectionScreen({super.key});

//   @override
//   State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
// }

// class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
//   late final bool isDarkMode;
//   late final Color backgroundColor;
//   late final Color textColor;
//   late final Color secondaryTextColor;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     backgroundColor = isDarkMode ? AppTheme.surfaceDark : AppTheme.surfaceLight;
//     textColor = isDarkMode ? AppTheme.onPrimary : AppTheme.onBackgroundLight;
//     secondaryTextColor = isDarkMode
//         ? AppTheme.onPrimary.withValues(alpha: 0.7)
//         : AppTheme.onBackgroundLight.withValues(alpha: 0.6);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppTheme.primary, AppTheme.primaryDark],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Decorative Circles
//             Positioned(
//               top: -150.h,
//               left: -150.w,
//               child: Container(
//                 width: 350.r,
//                 height: 350.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppTheme.onPrimary.withValues(alpha: 0.1),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: -200.h,
//               right: -200.w,
//               child: Container(
//                 width: 450.r,
//                 height: 450.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppTheme.onPrimary.withValues(alpha: 0.1),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 80.h,
//               right: 40.w,
//               child: Container(
//                 width: 60.r,
//                 height: 60.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppTheme.onPrimary.withValues(alpha: 0.05),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 120.h,
//               left: 30.w,
//               child: Container(
//                 width: 45.r,
//                 height: 45.r,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppTheme.onPrimary.withValues(alpha: 0.05),
//                 ),
//               ),
//             ),

//             // Main Content
//             Column(
//               children: [
//                 SizedBox(height: 80.h),

//                 // Logo
//                 Container(
//                   width: 110.r,
//                   height: 110.r,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppTheme.onPrimary.withValues(alpha: 0.2),
//                   ),
//                   child: Center(
//                     child: Container(
//                       width: 85.r,
//                       height: 85.r,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppTheme.onPrimary,
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.home_outlined,
//                           size: 48.r,
//                           color: AppTheme.primary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),

//                 Text(
//                   'MyGateBell',
//                   style: TextStyle(
//                     fontSize: 32.sp,
//                     fontWeight: FontWeight.bold,
//                     color: AppTheme.onPrimary,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//                 SizedBox(height: 12.h),

//                 Text(
//                   'Connect. Simplify. Thrive.',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     color: AppTheme.onPrimary.withValues(alpha: 0.7),
//                     letterSpacing: 1.2,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 50.h),

//                 // Role Cards Container
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: backgroundColor,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(30.r),
//                         topRight: Radius.circular(30.r),
//                       ),
//                     ),
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 10.h),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Choose Your Role',
//                             style: TextStyle(
//                               fontSize: 28.sp,
//                               fontWeight: FontWeight.bold,
//                               color: textColor,
//                             ),
//                           ),
//                           Text(
//                             'Select how you\'ll be using MyGateBell',
//                             style: TextStyle(
//                               fontSize: 16.sp,
//                               color: secondaryTextColor,
//                               height: 1.4,
//                             ),
//                           ),
//                           SizedBox(height: 20.h),

//                           // Role Cards
//                           _buildRoleCard(
//                             title: 'Resident',
//                             description:
//                                 'For community members living in the society',
//                             icon: Icons.home_outlined,
//                             role: 'resident',
//                           ),
//                           SizedBox(height: 20.h),
//                           _buildRoleCard(
//                             title: 'Security Guard',
//                             description:
//                                 'For security personnel managing entries and safety',
//                             icon: Icons.shield_outlined,
//                             role: 'guard',
//                           ),
//                           SizedBox(height: 40.h),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleCard({
//     required String title,
//     required String description,
//     required IconData icon,
//     required String role,
//   }) {
//     final cardColor = isDarkMode ? AppTheme.surfaceDark : AppTheme.surfaceLight;
//     final borderColor = isDarkMode
//         ? AppTheme.onBackgroundLight.withValues(alpha: 0.4)
//         : AppTheme.onBackgroundLight.withValues(alpha: 0.08);
//     final shadowColor = isDarkMode
//         ? AppTheme.onBackgroundLight.withValues(alpha: 0.15)
//         : AppTheme.onBackgroundDark.withValues(alpha: 0.5);
//     final primaryColor = AppTheme.primary;

//     return GestureDetector(
//       onTap: () {
//         context.read<AuthBloc>().add(RoleSelected(role: role));
//         Navigator.of(context).pushNamed('/auth');
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//         padding: EdgeInsets.all(12.r),
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(24.r),
//           border: Border.all(color: borderColor, width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: shadowColor,
//               blurRadius: 20.r,
//               offset: Offset(0, 8.h),
//               spreadRadius: 1,
//             ),
//           ],
//         ),
//         child: Row(
//           spacing: 14.w,
//           children: [
//             Container(
//               padding: EdgeInsets.all(14.r),
//               decoration: BoxDecoration(
//                 color: primaryColor.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(18.r),
//               ),
//               child: Icon(icon, color: primaryColor, size: 36.r),
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 20.sp,
//                       fontWeight: FontWeight.bold,
//                       color: textColor,
//                     ),
//                   ),
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       color: secondaryTextColor,
//                       height: 1.4,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 22.r,
//               color: secondaryTextColor,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
