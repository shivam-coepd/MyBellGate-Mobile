import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/screens/resident/dashboard_screen.dart';
import 'package:mygate_coepd/screens/resident/visitor_management_screen.dart';
import 'package:mygate_coepd/screens/resident/service_requests_screen.dart';
import 'package:mygate_coepd/screens/resident/bills_payments_screen.dart';
import 'package:mygate_coepd/screens/society/events_and_community_screen.dart';

class ResidentMainScreen extends StatefulWidget {
  final int initialTabIndex;

  const ResidentMainScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ResidentMainScreen> createState() => _ResidentMainScreenState();
}

class _ResidentMainScreenState extends State<ResidentMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const ResidentDashboardScreen(),
    const VisitorManagementScreen(),
    const ServiceRequestsScreen(),
    const BillsPaymentsScreen(),
    const EventsAndCommunityScreen(),
  ];

  final List<NavItem> _navItems = [
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
      badgeCount: 3,
    ),
    NavItem(
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist_rounded,
      label: 'Services',
      badgeCount: 2,
    ),
    NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Bills',
      badgeCount: 1,
    ),
    NavItem(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      label: 'Community',
      badgeCount: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
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

    if (_currentIndex >= _screens.length) {
      _currentIndex = _screens.length - 1;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      body: _screens[_currentIndex],
      bottomNavigationBar: _buildPremiumNavigationBar(theme, primaryColor),
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
            Stack(
              alignment: Alignment.center,
              children: [
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
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: isSelected ? 28.sp : 26.sp,
                  color: isSelected ? primaryColor : Colors.grey.shade600,
                ),
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
