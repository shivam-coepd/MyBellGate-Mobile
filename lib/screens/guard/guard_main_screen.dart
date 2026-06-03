import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/screens/guard/guard_dashboard_screen.dart';
import 'package:mygate_coepd/screens/guard/attendance_screen.dart';
import 'package:mygate_coepd/screens/guard/profile_screen.dart';
import 'package:mygate_coepd/screens/guard/visitor_management_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

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
      const GuardVisitorManagementScreen(),
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
            drawer: _buildDrawer(context, user),
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
              // Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings screen will be implemented'),
                ),
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
          // Show notifications
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notifications would open here')),
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
          backgroundImage: user.profileImage != null
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? Icon(Icons.person, color: Theme.of(context).primaryColor)
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
