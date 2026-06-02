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
                        Color(0xFF6C63FF).withValues(alpha: 0.15),
                        Color(0xFF6C63FF).withValues(alpha: 0.0),
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
                        Color(0xFF00BFA6).withValues(alpha: 0.12),
                        Color(0xFF00BFA6).withValues(alpha: 0.0),
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
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade300.withValues(alpha: 0.5),
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
            spacing: 2.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Role',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  // color: isDarkMode ? Colors.white : Color(0xFF1A1A2E),
                  color: Theme.of(context).primaryColor,
                  height: 1.2,
                ),
              ),
              Text(
                'How would you like to use MyGateBell?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.5)
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
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
            child: _buildRoleCard(
              role: role,
              gradient: gradient,
              isDarkMode: isDarkMode,
              index: index,
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
          margin: EdgeInsets.only(bottom: 16.h),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isHovered
                  ? gradient[0].withValues(alpha: 0.5)
                  : isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
              width: isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? gradient[0].withValues(alpha: 0.2)
                    : isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.shade200.withValues(alpha: 0.8),
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
                                  color: gradient[0].withValues(alpha: 0.3),
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
                                    ? gradient[0].withValues(alpha: 0.1)
                                    : isDarkMode
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: isHovered
                                    ? gradient[0]
                                    : isDarkMode
                                    ? Colors.white.withValues(alpha: 0.4)
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
                              ? Colors.white.withValues(alpha: 0.5)
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
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : gradient[0].withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : gradient[0].withValues(alpha: 0.15),
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
                                        ? Colors.white.withValues(alpha: 0.7)
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
