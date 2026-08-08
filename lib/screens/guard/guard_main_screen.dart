import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/screens/common/support_feedback_screen.dart';
import 'package:mygate_coepd/screens/guard/guard_dashboard_screen.dart';
import 'package:mygate_coepd/screens/guard/attendance_screen.dart';
import 'package:mygate_coepd/screens/guard/profile_screen.dart';
import 'package:mygate_coepd/screens/guard/visitor_management_screen.dart';
import 'package:mygate_coepd/screens/resident/notifications_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class GuardMainScreen extends StatefulWidget {
  const GuardMainScreen({super.key});

  @override
  State<GuardMainScreen> createState() => _GuardMainScreenState();
}

class _GuardMainScreenState extends State<GuardMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;
  late final List<NavItem> _navItems;

  @override
  void initState() {
    super.initState();
    _screens = [
      const GuardDashboardScreen(),
      const GuardVisitorManagementScreen(isBackButton: false),
      const AttendanceScreen(),
      const GuardProfileScreen(),
    ];

    _navItems = [
      NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        badgeCount: 0,
      ),
      NavItem(
        icon: Icons.people_outlined,
        activeIcon: Icons.people_rounded,
        label: 'Visitors',
        badgeCount: 2,
      ),
      NavItem(
        icon: Icons.checklist_outlined,
        activeIcon: Icons.checklist_rounded,
        label: 'Attendance',
        badgeCount: 0,
      ),
      NavItem(
        icon: Icons.person_outlined,
        activeIcon: Icons.person,
        label: 'Profile',
        badgeCount: 0,
      ),
    ];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation for the initially selected tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Reset and forward the animation for the newly selected tab
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Ensure index doesn't exceed the number of screens
    if (_currentIndex >= _screens.length) {
      _currentIndex = _screens.length - 1;
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(_navItems[_currentIndex].label),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: _buildAppBarActions(user),
            ),
            // drawer: _buildDrawer(context, user),
            drawer: GuardDrawer(
              user: user,
              currentIndex: _currentIndex,
              onTabChanged: _onTabTapped,
            ),
            body: _screens[_currentIndex],
            bottomNavigationBar: _buildPremiumNavigationBar(
              theme,
              primaryColor,
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildDrawer(BuildContext context, User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                SizedBox(height: 10.h),
                Text(
                  user.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Security Guard',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            selected: _currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              _onTabTapped(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Visitors'),
            selected: _currentIndex == 1,
            onTap: () {
              Navigator.pop(context);
              _onTabTapped(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Attendance'),
            selected: _currentIndex == 2,
            onTap: () {
              Navigator.pop(context);
              _onTabTapped(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            selected: _currentIndex == 3,
            onTap: () {
              Navigator.pop(context);
              _onTabTapped(3);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              AppSnackbar.show(
                context: context,
                message: 'Settings screen will be implemented',
                type: SnackBarType.info,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumNavigationBar(ThemeData theme, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20.r,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        child: Container(
          height: 80.h + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = _currentIndex == index;

              return Expanded(
                child: _BuildAnimatedNavItem(
                  animation: _animation,
                  isSelected: isSelected,
                  item: item,
                  primaryColor: primaryColor,
                  onTap: () => _onTabTapped(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(User user) {
    return [
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
        icon: const Icon(Icons.notifications),
      ),
      SizedBox(width: 12.w),
      GestureDetector(
        onTap: () {
          _onTabTapped(3); // Navigate to profile
        },
        child: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.5),
          backgroundImage: user.profileImage != null
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? Icon(Icons.person, color: Colors.white)
              : null,
        ),
      ),
      SizedBox(width: 16.w),
    ];
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('MyGateBell App Help'),
                SizedBox(height: 10.h),
                Text('For technical support, please contact:'),
                Text('support@mygatebell.com'),
                SizedBox(height: 10.h),
                Text('For general inquiries, please contact:'),
                Text('info@mygatebell.com'),
                SizedBox(height: 10.h),
                Text('Phone: +91 9876543210'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                // Trigger logout event in AuthBloc
                context.read<AuthBloc>().add(LogoutRequested());
                // Navigate to login screen
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/auth', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badgeCount,
  });
}

class _BuildAnimatedNavItem extends StatelessWidget {
  final Animation<double> animation;
  final bool isSelected;
  final NavItem item;
  final Color primaryColor;
  final VoidCallback onTap;

  const _BuildAnimatedNavItem({
    required this.animation,
    required this.isSelected,
    required this.item,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: primaryColor.withValues(alpha: 0.1),
        highlightColor: primaryColor.withValues(alpha: 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Background highlight for selected item
                if (isSelected)
                  ScaleTransition(
                    scale: animation,
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withValues(alpha: 0.15),
                            primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),

                // Icon
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: isSelected ? 28.sp : 26.sp,
                  color: isSelected ? primaryColor : Colors.grey.shade600,
                ),

                // Active indicator dot
                if (isSelected)
                  Positioned(
                    top: -2.h,
                    child: ScaleTransition(
                      scale: animation,
                      child: Container(
                        width: 24.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 4.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.9),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.grey.shade600,
                  letterSpacing: isSelected ? 0.5 : 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuardDrawer extends StatefulWidget {
  final User user;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const GuardDrawer({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  State<GuardDrawer> createState() => _GuardDrawerState();
}

class _GuardDrawerState extends State<GuardDrawer>
    with SingleTickerProviderStateMixin {
  // int _currentIndex = 0;
  int _hoveredIndex = -1;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    widget.onTabChanged(index);
  }

  void _showHelpDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: isDark ? Color(0xFF1A1A2E) : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: AppTheme.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildSupportOption(
                icon: Icons.phone_outlined,
                title: 'Emergency Helpline',
                subtitle: '+91 98765 43210',
                color: Colors.red,
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
              _buildSupportOption(
                icon: Icons.email_outlined,
                title: 'Supervisor Contact',
                subtitle: 'supervisor@mygatebell.com',
                color: Color(0xFF6C63FF),
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
              _buildSupportOption(
                icon: Icons.info_outline_rounded,
                title: 'App Support',
                subtitle: 'support@mygatebell.com',
                color: Color(0xFF00BFA6),
                isDark: isDark,
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : color.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.copy_rounded, size: 18.sp, color: color.withOpacity(0.6)),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authBloc = context.read<AuthBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: isDark ? Color(0xFF1A1A2E) : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'End Shift?',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to logout and end your shift?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white
                            : Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final navigator = Navigator.of(dialogContext);
                        navigator.pop();
                        authBloc.add(LogoutRequested());
                        navigator.pushNamedAndRemoveUntil(
                          '/auth',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    int? index,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final isSelected = index != null && widget.currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isHovered = _hoveredIndex == (index ?? -2);

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index ?? -2),
      onExit: (_) => setState(() => _hoveredIndex = -1),
      child: GestureDetector(
        onTap: onTap ?? () => _onTabTapped(index ?? 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08)
                : isHovered
                ? (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected
                ? Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(isDark ? 0.2 : 0.15)
                    : isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: isSelected
                    ? AppTheme.primary
                    : isDestructive
                    ? Colors.red
                    : (isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey.shade600),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primary
                    : isDestructive
                    ? Colors.red
                    : (isDark
                          ? Colors.white.withOpacity(0.9)
                          : Color(0xFF1A1A2E)),
              ),
            ),
            trailing: isSelected
                ? Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.grey.shade400,
                  ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white.withOpacity(0.35) : Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(User user) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary, // Deep security blue
            AppTheme.primaryDark,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with badge and close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'MyGateBell Guard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Profile row
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 32.r,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: user.profileImage != null
                            ? NetworkImage(user.profileImage!)
                            : null,
                        child: user.profileImage == null
                            ? Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 36.sp,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: Container(
                        width: 14.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFF1A237E),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 16.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Security Guard',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.phone,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // SizedBox(height: 20.h),

            // // Quick stats row - Guard specific
            // Row(
            //   children: [
            //     _buildHeaderStat(
            //       icon: Icons.login_rounded,
            //       value: '24',
            //       label: 'Entries Today',
            //     ),
            //     SizedBox(width: 12.w),
            //     _buildHeaderStat(
            //       icon: Icons.pending_actions_rounded,
            //       value: '3',
            //       label: 'Pending',
            //     ),
            //     SizedBox(width: 12.w),
            //     _buildHeaderStat(
            //       icon: Icons.schedule_rounded,
            //       value: '08:00',
            //       label: 'Shift Started',
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.7), size: 16.sp),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 9.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = widget.user;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.80,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Header ──
            _buildDrawerHeader(user),

            SizedBox(height: 8.h),

            // ── Main Navigation ──
            _buildSectionHeader('Operations'),
            _buildDrawerTile(icon: Icons.home_rounded, title: 'Home', index: 0),
            _buildDrawerTile(
              icon: Icons.people_rounded,
              title: 'Visitors',
              index: 1,
            ),
            _buildDrawerTile(
              icon: Icons.checklist_rounded,
              title: 'Attendance',
              index: 2,
            ),
            _buildDrawerTile(
              icon: Icons.person_rounded,
              title: 'My Profile',
              index: 3,
            ),

            SizedBox(height: 8.h),

            // ── Divider ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200,
                thickness: 1,
              ),
            ),

            // ── Account ──
            _buildSectionHeader('Account'),
            _buildDrawerTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                AppSnackbar.show(
                  context: context,
                  message: 'Settings screen will be implemented',
                  type: SnackBarType.info,
                );
              },
            ),
            _buildDrawerTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SupportFeedbackScreen()),
                );
              },
            ),

            SizedBox(height: 8.h),

            // ── Divider ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200,
                thickness: 1,
              ),
            ),

            // ── Logout ──
            SizedBox(height: 8.h),
            _buildDrawerTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),

            SizedBox(height: 24.h),

            // ── App Version Footer ──
            Center(
              child: Text(
                'MyGateBell Guard v1.0.3',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark
                      ? Colors.white.withOpacity(0.25)
                      : Colors.grey.shade400,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
