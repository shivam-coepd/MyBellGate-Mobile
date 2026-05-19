import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class AppDrawer extends StatefulWidget {
  final User user;

  const AppDrawer({
    super.key,
    required this.user,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int _currentIndex = 0; // Assuming you track selected tab index

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Add navigation logic if needed
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
              Text('For technical support, please contact:', style: TextStyle(fontSize: 14.sp)),
              Text('support@mygatebell.com', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 12.h),
              Text('For general inquiries, please contact:', style: TextStyle(fontSize: 14.sp)),
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
        content: Text('Are you sure you want to logout?', style: TextStyle(fontSize: 15.sp)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Logout', style: TextStyle(fontSize: 15.sp, color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerTile(
    IconData icon,
    String title,
    int? index, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26.sp),
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      selected: index != null && _currentIndex == index,
      selectedTileColor: Colors.grey.withOpacity(0.1),
      onTap: onTap ??
          () {
            Navigator.pop(context);
            if (index != null) _onTabTapped(index);
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox.shrink(); // Or show loading/unauthenticated drawer
        }

        final user = state.user;

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
                          ? const Icon(Icons.person, color: Colors.white, size: 40)
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
                      'Resident',
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
              _drawerTile(Icons.home, 'Home', 0),
              _drawerTile(Icons.people, 'Visitors', 1),
              _drawerTile(Icons.checklist, 'Services', 2),
              _drawerTile(Icons.account_balance_wallet, 'Bills & Payments', 3),
              _drawerTile(Icons.groups, 'Community & Events', 4),
              const Divider(),
              _drawerTile(
                Icons.settings,
                'Settings',
                null,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings screen will be implemented')),
                  );
                },
              ),
              _drawerTile(
                Icons.help,
                'Help & Support',
                null,
                onTap: () {
                  Navigator.pop(context);
                  _showHelpDialog(context);
                },
              ),
              _drawerTile(
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
      },
    );
  }
}