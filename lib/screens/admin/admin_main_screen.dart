import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/screens/admin/admin_dashboard_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
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
      color: AppTheme.onPrimary.withValues(alpha: 0.0),
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
                      width: 40.w,
                      height: 40.h,
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
                  size: isSelected ? 26.r : 24.r,
                  color: isSelected ? primaryColor : AppTheme.onBackgroundLight,
                ),

                // Badge
                if (item.badgeCount > 0)
                  Positioned(
                    right: 0.w,
                    top: -5.h,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.onPrimary, width: 2.w),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        item.badgeCount.toString(),
                        style: TextStyle(
                          color: AppTheme.onPrimary,
                          fontSize: 10.r,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Active indicator dot
                if (isSelected)
                  Positioned(
                    top: -1.h,
                    child: ScaleTransition(
                      scale: animation,
                      child: Container(
                        width: 20.w,
                        height: 4.h,
                        decoration: BoxDecoration(color: primaryColor),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 2.h),

            // Label with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.9),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? primaryColor : AppTheme.onBackgroundLight,
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

class _AdminMainScreenState extends State<AdminMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const Center(child: Text('Management')),
    const Center(child: Text('Reports')),
    const Center(child: Text('Profile')),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Dashboard',
      badgeCount: 0,
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Management',
      badgeCount: 3,
    ),
    NavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Reports',
      badgeCount: 9,
    ),
    NavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'Profile',
      badgeCount: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
            ),
            drawer: _buildDrawer(context, user),
            body: _screens[_currentIndex],
            bottomNavigationBar: _buildPremiumNavigationBar(theme, primaryColor),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 36.r,
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Icon(Icons.person, size: 40.sp, color: AppTheme.onPrimary)
                      : null,
                ),
                SizedBox(height: 12.h),
                Text(
                  user.name,
                  style: TextStyle(
                    color: AppTheme.onPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Administrator',
                  style: TextStyle(color: AppTheme.onPrimary.withValues(alpha: 0.7), fontSize: 14.sp),
                ),
              ],
            ),
          ),
          _drawerTile(context, Icons.home, 'Dashboard', 0),
          _drawerTile(context, Icons.settings, 'Management', 1),
          _drawerTile(context, Icons.description, 'Reports', 2),
          _drawerTile(context, Icons.person, 'Profile', 3),
          const Divider(),
          _drawerTile(
            context,
            Icons.settings,
            'Settings',
            null,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings screen will be implemented'),
                ),
              );
            },
          ),
          _drawerTile(
            context,
            Icons.help,
            'Help & Support',
            null,
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
          _drawerTile(
            context,
            Icons.logout,
            'Logout',
            null,
            onTap: () {
              Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerTile(
    BuildContext context,
    IconData icon,
    String title,
    int? index, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26.sp),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      selected: index != null && _currentIndex == index,
      selectedTileColor: AppTheme.onBackgroundLight.withValues(alpha: 0.1),
      onTap:
          onTap ??
          () {
            Navigator.pop(context);
            if (index != null) _onTabTapped(index);
          },
    );
  }

  Widget _buildPremiumNavigationBar(ThemeData theme, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.onBackgroundDark.withValues(alpha: 0.15),
            blurRadius: 20.r,
            offset: Offset(0, -5.h),
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Help & Support', style: TextStyle(fontSize: 18.sp)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MyGateBell App Help', style: TextStyle(fontSize: 15.sp)),
              SizedBox(height: 12.h),
              Text(
                'For technical support, please contact:',
                style: TextStyle(fontSize: 14.sp),
              ),
              Text(
                'support@mygatebell.com',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                'For general inquiries, please contact:',
                style: TextStyle(fontSize: 14.sp),
              ),
              Text('info@mygatebell.com', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 12.h),
              Text('Phone: +91 9876543210', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(fontSize: 15.sp)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout', style: TextStyle(fontSize: 18.sp)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 15.sp),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(fontSize: 15.sp, color: AppTheme.error),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/auth', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}