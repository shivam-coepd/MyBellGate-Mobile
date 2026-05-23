// ignore_for_file: unused_element, unused_local_variable, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/screens/guard/coming_soon.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/screens/guard/details/group_visitor_entry_screen.dart';
import 'package:mygate_coepd/screens/guard/details/vendor_access_screen.dart';
import 'package:mygate_coepd/screens/guard/details/utility_vehicle_tracking_screen.dart';
import 'package:mygate_coepd/screens/guard/details/guard_patrolling_screen.dart';
import 'package:mygate_coepd/screens/guard/details/offline_mode_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
  bool _isOffline = false;
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pendingVisitors = [
    {
      'id': 1,
      'name': 'Rahul Kumar',
      'type': 'Delivery',
      'flat': 'A-101',
      'time': '10:15 AM',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'type': 'Guest',
      'flat': 'B-203',
      'time': '10:05 AM',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.person_add,
      'label': 'Visitor Entry',
      'color': AppTheme.primary,
      'screen': 'visitor_entry',
    },
    {
      'icon': Icons.group,
      'label': 'Group Entry',
      'color': AppTheme.secondary,
      'screen': 'group_entry',
    },
    {
      'icon': Icons.build,
      'label': 'Vendor Access',
      'color': AppTheme.success,
      'screen': 'vendor_access',
    },
    {
      'icon': Icons.directions_car,
      'label': 'Vehicle Log',
      'color': AppTheme.warning,
      'screen': 'vehicle_log',
    },
    {
      'icon': Icons.directions_walk,
      'label': 'Patrolling',
      'color': AppTheme.primaryDark,
      'screen': 'patrolling',
    },
    {
      'icon': Icons.phone,
      'label': 'Call Guard',
      'color': AppTheme.error,
      'screen': 'call_guard',
    },
    {
      'icon': Icons.thermostat,
      'label': 'Temp Check',
      'color': AppTheme.info,
      'screen': 'temp_check',
    },
    {
      'icon': Icons.keyboard_voice,
      'label': 'Voice Entry',
      'color': AppTheme.secondary,
      'screen': 'voice_entry',
    },
    {
      'icon': Icons.voicemail,
      'label': 'E-Intercom',
      'color': AppTheme.info,
      'screen': 'e_intercom',
    },
    {
      'icon': Icons.wifi_off,
      'label': 'Offline Mode',
      'color': AppTheme.primaryDark,
      'screen': 'offline_mode',
    },
    {
      'icon': Icons.language,
      'label': 'Language',
      'color': AppTheme.success,
      'screen': 'language',
    },
  ];

  final List<Map<String, dynamic>> _recentActivity = [
    {
      'icon': Icons.person,
      'title': 'Visitor Entry',
      'description': 'Amit Patel for B-404',
      'time': '10:32 AM',
      'iconBg': AppTheme.primary,
      'iconColor': AppTheme.onPrimary,
    },
    {
      'icon': Icons.directions_car,
      'title': 'Vehicle Exit',
      'description': 'MH02 AB 1234',
      'time': '10:15 AM',
      'iconBg': AppTheme.success,
      'iconColor': AppTheme.onPrimary,
    },
    {
      'icon': Icons.inventory,
      'title': 'Delivery Accepted',
      'description': 'Amazon Package for A-101',
      'time': '9:45 AM',
      'iconBg': AppTheme.warning,
      'iconColor': AppTheme.onPrimary,
    },
  ];

  void _handleApprove(int id) {
    setState(() {
      // Remove the approved visitor from the list
    });
  }

  void _handleReject(int id) {
    setState(() {
      // Remove the rejected visitor from the list
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToScreen(String screen) {
    switch (screen) {
      case 'group_entry':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GroupVisitorEntryScreen(),
          ),
        );
        break;
      case 'vendor_access':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VendorAccessScreen()),
        );
        break;
      case 'vehicle_log':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UtilityVehicleTrackingScreen(),
          ),
        );
        break;
      case 'patrolling':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GuardPatrollingScreen(),
          ),
        );
        break;
      case 'call_guard':
        Navigator.push(
          context,
          // MaterialPageRoute(builder: (context) => const GuardCallingScreen()),
          MaterialPageRoute(builder: (context) => const CommingSoonScreen()),
        );
        break;
      case 'temp_check':
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => const TemperatureMaskScreen(),
            builder: (context) => const CommingSoonScreen(),
          ),
        );
        break;
      case 'voice_entry':
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => const VoiceCommandEntryScreen(),
            builder: (context) => const CommingSoonScreen(),
          ),
        );
        break;
      case 'e_intercom':
        Navigator.push(
          context,
          // MaterialPageRoute(builder: (context) => const EIntercomScreen()),
          MaterialPageRoute(builder: (context) => const CommingSoonScreen()),
        );
        break;
      case 'offline_mode':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OfflineModeScreen()),
        );
        break;
      case 'language':
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (context) => const MultilingualSupportScreen(),
            builder: (context) => const CommingSoonScreen(),
          ),
        );
        break;
      default:
        // For visitor entry and other simple actions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action not implemented yet'),
            backgroundColor: AppTheme.primary,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Offline Banner
                    if (_isOffline)
                      Container(
                        padding: EdgeInsets.all(10.w),
                        color: AppTheme.warning,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.wifi_off, color: AppTheme.onPrimary),
                                SizedBox(width: 10.w),
                                Text(
                                  'Offline Mode',
                                  style: TextStyle(
                                    color: AppTheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isOffline = false;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: AppTheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Search Bar at top
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 5,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search visitors, vehicles or flats...',
                          hintStyle: TextStyle(
                            color: AppTheme.onBackgroundLight,
                            fontSize: 14.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                        ),
                        onSubmitted: (value) {
                          // Handle search
                        },
                      ),
                    ),
                    // Quick Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15.h),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 15.w,
                                mainAxisSpacing: 15.h,
                              ),
                          itemCount: _quickActions.length,
                          itemBuilder: (context, index) {
                            final action = _quickActions[index];
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _navigateToScreen(action['screen']),
                                  child: Container(
                                    padding: EdgeInsets.all(15.w),
                                    decoration: BoxDecoration(
                                      color: action['color'],
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: action['color'].withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 10.w,
                                          offset: Offset(0, 5.h),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      action['icon'],
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Flexible(
                                  child: Text(
                                    action['label'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10.sp),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    // Pending Approvals
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pending Approvals',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '${_pendingVisitors.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),
                        if (_pendingVisitors.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pendingVisitors.length,
                            itemBuilder: (context, index) {
                              final visitor = _pendingVisitors[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 15.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(15.w),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25.r,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                  visitor['image'],
                                                ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  visitor['name'],
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow: TextOverflow
                                                      .ellipsis, // ADD THIS
                                                  maxLines: 1,
                                                ),
                                                SizedBox(height: 5.h),
                                                Text(
                                                  visitor['type'],
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  'For: ${visitor['flat']} • ${visitor['time']}',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                _handleReject(visitor['id']);
                                              },
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _handleApprove(visitor['id']);
                                              },
                                              child: const Text('Approve'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 40.sp,
                                  ),
                                  SizedBox(height: 15.h),
                                  const Text(
                                    'No pending approvals',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // Recent Activity
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // View all activity
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: _recentActivity
                                .map(
                                  (activity) => ListTile(
                                    leading: Container(
                                      padding: EdgeInsets.all(10.w),
                                      decoration: BoxDecoration(
                                        color: activity['iconBg'].withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Icon(
                                        activity['icon'],
                                        color: activity['iconColor'],
                                      ),
                                    ),
                                    title: Text(activity['title']),
                                    subtitle: Text(activity['description']),
                                    trailing: Text(
                                      activity['time'],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h), // Reduced space
                  ],
                ),
              ),
            ),
            // Removed bottomNavigationBar from here since it's handled in GuardMainScreen
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
