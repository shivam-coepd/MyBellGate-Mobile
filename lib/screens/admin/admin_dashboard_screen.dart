import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _currentIndex = 0;

  final List<Map<String, dynamic>> _stats = [
    {
      'title': 'Total Residents',
      'value': '246',
      'change': '+3',
      'isIncrease': true,
      'icon': Icons.people,
      'color': AppTheme.primary,
    },
    {
      'title': 'Pending Approvals',
      'value': '12',
      'change': '+5',
      'isIncrease': true,
      'icon': Icons.checklist,
      'color': AppTheme.secondary,
    },
    {
      'title': 'Active Complaints',
      'value': '8',
      'change': '-2',
      'isIncrease': false,
      'icon': Icons.report_problem,
      'color': AppTheme.error,
    },
    {
      'title': 'Collection Rate',
      'value': '92%',
      'change': '+4%',
      'isIncrease': true,
      'icon': Icons.credit_card,
      'color': AppTheme.success,
    },
  ];

  final List<Map<String, dynamic>> _pendingApprovals = [
    {
      'id': 1,
      'name': 'Rahul Kumar',
      'unit': 'A-101',
      'requestedOn': '2023-05-12T10:30:00',
      'type': 'Resident',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'unit': 'B-203',
      'requestedOn': '2023-05-11T14:15:00',
      'type': 'Tenant',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final List<Map<String, dynamic>> _recentActivity = [
    {
      'id': 1,
      'title': 'New Resident Registered',
      'description': 'Amit Patel registered for unit C-405',
      'time': '1 hour ago',
      'icon': Icons.person_add,
      'iconBg': AppTheme.primary,
      'iconColor': AppTheme.onPrimary,
    },
    {
      'id': 2,
      'title': 'Complaint Resolved',
      'description': 'Water leakage in B-201 fixed',
      'time': '3 hours ago',
      'icon': Icons.check_circle,
      'iconBg': AppTheme.success,
      'iconColor': AppTheme.onPrimary,
    },
    {
      'id': 3,
      'title': 'Payment Received',
      'description': '₹15,000 received from A-302',
      'time': '5 hours ago',
      'icon': Icons.credit_card,
      'iconBg': AppTheme.primary,
      'iconColor': AppTheme.onPrimary,
    },
  ];

  final List<Map<String, dynamic>> _quickAccess = [
    {
      'icon': Icons.apartment,
      'label': 'Society Management',
      'route': '/society-management',
    },
    {
      'icon': Icons.people,
      'label': 'Resident Management',
      'route': '/resident-management',
    },
    {
      'icon': Icons.business,
      'label': 'Service Providers',
      'route': '/service-providers',
    },
    {
      'icon': Icons.checklist,
      'label': 'Staff Attendance',
      'route': '/staff-attendance',
    },
    {
      'icon': Icons.house,
      'label': 'Tenant Management',
      'route': '/tenant-management',
    },
    {
      'icon': Icons.swap_horiz,
      'label': 'Move Process',
      'route': '/move-process',
    },
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard Config',
      'route': '/dashboard-config',
    },
    {'icon': Icons.description, 'label': 'Reports', 'route': '/reports'},
    {'icon': Icons.settings, 'label': 'App Controls', 'route': '/app-controls'},
    {
      'icon': Icons.camera,
      'label': 'Selfie Attendance',
      'route': '/selfie-attendance',
    },
    {
      'icon': Icons.privacy_tip,
      'label': 'Masked Directory',
      'route': '/masked-directory',
    },
    {
      'icon': Icons.business,
      'label': 'Multi-Property',
      'route': '/multi-property',
    },
    {'icon': Icons.campaign, 'label': 'Notice Board', 'route': '/notice-board'},
    {
      'icon': Icons.move_to_inbox,
      'label': 'Resident Requests',
      'route': '/resident-requests',
    },
    {
      'icon': Icons.call,
      'label': 'Resident Calling',
      'route': '/resident-calling',
    },
    {
      'icon': Icons.email,
      'label': 'Email Campaigns',
      'route': '/email-campaigns',
    },
    {
      'icon': Icons.notifications,
      'label': 'Push Notifications',
      'route': '/push-notifications',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleApprove(int id) {
    // Handle approval logic
  }

  void _handleReject(int id) {
    // Handle rejection logic
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // ignore: unused_local_variable
          final user = state.user;
          return Scaffold(
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3.w,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: AppTheme.onBackgroundLight,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Residents'),
                    Tab(text: 'Billing'),
                    Tab(text: 'Complaints'),
                    Tab(text: 'Amenities'),
                    Tab(text: 'Reports'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Overview Tab
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.all(15.r),
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Stats Cards
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 15,
                                        ),
                                    itemCount: _stats.length,
                                    itemBuilder: (context, index) {
                                      final stat = _stats[index];
                                      return Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16.r),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(15.w),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(10.r),
                                                    decoration: BoxDecoration(
                                                      color: stat['color'].withValues(
                                                        alpha: 0.1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(12.r),
                                                    ),
                                                    child: Icon(
                                                      stat['icon'],
                                                      color: stat['color'],
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                ],
                                              ),
                                              SizedBox(height: 10.h),
                                              Text(
                                                stat['title'],
                                                style: TextStyle(
                                                  color: AppTheme.onBackgroundLight,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              SizedBox(height: 10.h),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    stat['value'],
                                                    style: TextStyle(
                                                      fontSize: 24.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    stat['change'],
                                                    style: TextStyle(
                                                      color: stat['isIncrease']
                                                          ? AppTheme.success
                                                          : AppTheme.error,
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Quick Access
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Quick Access',
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
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              crossAxisSpacing: 15,
                                              mainAxisSpacing: 15,
                                              childAspectRatio: 0.7,
                                            ),
                                        itemCount: _quickAccess.length,
                                        itemBuilder: (context, index) {
                                          final item = _quickAccess[index];
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // Navigate to the respective module
                                                  Navigator.pushNamed(
                                                    context,
                                                    item['route'],
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(15.w),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).cardTheme.color,
                                                    borderRadius:
                                                        BorderRadius.circular(16.r),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppTheme.onBackgroundLight.withValues(
                                                          alpha: 0.1,
                                                        ),
                                                        blurRadius: 5.w,
                                                        offset: Offset(0, 2.h),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    item['icon'],
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                    size: 28.sp,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Flexible(
                                                child: Text(
                                                  item['label'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  // Pending Approvals
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                              color: AppTheme.secondary,
                                              borderRadius: BorderRadius.circular(
                                                20.r,
                                              ),
                                            ),
                                            child: Text(
                                              '${_pendingApprovals.length}',
                                              style: TextStyle(
                                                color: AppTheme.onSecondary,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      if (_pendingApprovals.isNotEmpty)
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _pendingApprovals.length,
                                          itemBuilder: (context, index) {
                                            final approval = _pendingApprovals[index];
                                            return Card(
                                              margin: EdgeInsets.only(bottom: 15.h),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  16.r,
                                                ),
                                              ),
                                              elevation: 2,
                                              child: Padding(
                                                padding: EdgeInsets.all(15.w),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 25.r,
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                                approval['image'],
                                                              ),
                                                          backgroundColor:
                                                              AppTheme.primary
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                        ),
                                                        SizedBox(width: 15.w),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                approval['name'],
                                                                style: TextStyle(
                                                                  fontSize: 16.sp,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                              ),
                                                              SizedBox(height: 5.h),
                                                              Text(
                                                                '${approval['type']} • ${approval['unit']}',
                                                                style: TextStyle(
                                                                  fontSize: 14.sp,
                                                                  color: AppTheme.onBackgroundLight,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Requested: ${DateTime.parse(approval['requestedOn']).day}/${DateTime.parse(approval['requestedOn']).month}/${DateTime.parse(approval['requestedOn']).year}',
                                                                style: TextStyle(
                                                                  fontSize: 12.sp,
                                                                  color: AppTheme.onBackgroundLight,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 15.h),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Expanded(
                                                          child: OutlinedButton(
                                                            onPressed: () {
                                                              _handleReject(
                                                                approval['id'],
                                                              );
                                                            },
                                                            style: OutlinedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                vertical: 12.h,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12.r,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              'Reject',
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _handleApprove(
                                                                approval['id'],
                                                              );
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                vertical: 12.h,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12.r,
                                                                    ),
                                                              ),
                                                            ),
                                                            child: Text(
                                                              'Approve',
                                                              style: TextStyle(
                                                                fontSize: 14.sp,
                                                              ),
                                                            ),
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
                                          elevation: 2,
                                          child: Padding(
                                            padding: EdgeInsets.all(20.w),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: AppTheme.success,
                                                  size: 40.sp,
                                                ),
                                                SizedBox(height: 15.h),
                                                Text(
                                                  'No pending approvals',
                                                  style: TextStyle(
                                                    color: AppTheme.onBackgroundLight,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  // Recent Activity
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                            child: Text(
                                              'View All',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16.r),
                                        ),
                                        elevation: 2,
                                        child: Column(
                                          children: _recentActivity
                                              .map(
                                                (activity) => ListTile(
                                                  leading: Container(
                                                    padding: EdgeInsets.all(10.w),
                                                    decoration: BoxDecoration(
                                                      color: activity['iconBg']
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(12.r),
                                                    ),
                                                    child: Icon(
                                                      activity['icon'],
                                                      color: activity['iconColor'],
                                                      size: 24.sp,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    activity['title'],
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    activity['description'],
                                                    style: TextStyle(fontSize: 14.sp),
                                                  ),
                                                  trailing: Text(
                                                    activity['time'],
                                                    style: TextStyle(
                                                      color: AppTheme.onBackgroundLight,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 8.h,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 80.h), // Space for bottom bar
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Other tabs would go here
                      const Center(child: Text('Residents Tab')),
                      const Center(child: Text('Billing Tab')),
                      const Center(child: Text('Complaints Tab')),
                      const Center(child: Text('Amenities Tab')),
                      const Center(child: Text('Reports Tab')),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // Add new item
              },
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.add, size: 24.sp),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}