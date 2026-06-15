// ignore_for_file: unused_element, unused_local_variable, unused_field

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/screens/guard/coming_soon.dart';
import 'package:mygate_coepd/screens/guard/visitor_management_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/screens/guard/details/group_visitor_entry_screen.dart';
import 'package:mygate_coepd/screens/guard/details/vendor_access_screen.dart';
import 'package:mygate_coepd/screens/guard/details/utility_vehicle_tracking_screen.dart';
import 'package:mygate_coepd/screens/guard/details/offline_mode_screen.dart';
import 'package:mygate_coepd/screens/guard/details/security_alerts_screen.dart';
import 'package:mygate_coepd/screens/guard/details/e_intercom_screen.dart';
import 'package:mygate_coepd/screens/guard/details/guard_calling_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:shimmer/shimmer.dart';

class GuardDashboardScreen extends StatefulWidget {
  const GuardDashboardScreen({super.key});

  @override
  State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
}

class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
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
      'icon': Icons.phone,
      'label': 'Call Guard',
      'color': AppTheme.error,
      'screen': 'call_guard',
    },
    {
      'icon': Icons.warning_amber,
      'label': 'Security',
      'color': AppTheme.secondary,
      'screen': 'security_alerts',
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
  ];

  @override
  void initState() {
    super.initState();
    AppInternetCheck.checkInternet(context: context);
    context.read<GuardBloc>().add(const LoadGuardDashboard());
  }

  void _navigateToScreen(String screen) {
    switch (screen) {
      case 'visitor_entry':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const GuardVisitorManagementScreen(isBackButton: true),
          ),
        );
        break;
      case 'group_entry':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupVisitorEntryScreen()),
        );
        break;
      case 'vendor_access':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VendorAccessScreen()),
        );
        break;
      case 'vehicle_log':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UtilityVehicleTrackingScreen(),
          ),
        );
        break;
      case 'offline_mode':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfflineModeScreen()),
        );
        break;
      case 'security_alerts':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecurityAlertsScreen()),
        );
        break;
      case 'e_intercom':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EIntercomScreen()),
        );
        break;
      case 'call_guard':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GuardCallingScreen()),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommingSoonScreen()),
        );
    }
  }

  void _handleApprove(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'approved'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visitor approved'),
        backgroundColor: AppTheme.success,
      ),
    );
    // Reload dashboard
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.read<GuardBloc>().add(const LoadGuardDashboard());
    });
  }

  void _handleReject(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'rejected'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visitor rejected'),
        backgroundColor: AppTheme.error,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.read<GuardBloc>().add(const LoadGuardDashboard());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return Scaffold(
            body: BlocConsumer<GuardBloc, GuardState>(
              listener: (context, state) async {
                if (state is GuardError) {
                  if (await AppInternetCheck().hasInternetConnection()) {
                    AppSnackbar.show(
                      context: context,
                      message: "Can't load data now. Please try again later.",
                      type: SnackBarType.error,
                    );
                  } else {
                    AppInternetCheck.checkInternet(context: context);
                  }
                }
              },
              builder: (context, state) {
                List<Map<String, dynamic>> pendingVisitors = [];
                List<Map<String, dynamic>> recentActivity = [];
                log(recentActivity.length.toString(), name: 'recentActivity');
                bool isLoading = false;

                if (state is GuardLoading) {
                  isLoading = true;
                } else if (state is GuardDashboardLoaded) {
                  pendingVisitors = state.pendingVisitors;
                  recentActivity = state.recentActivity;
                  log(recentActivity.toString(), name: 'recentActivity');
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (await AppInternetCheck().hasInternetConnection()) {
                      context.read<GuardBloc>().add(const LoadGuardDashboard());
                    } else {
                      AppInternetCheck.checkInternet(context: context);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // Search Bar
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search visitors, vehicles or flats...',
                              hintStyle: TextStyle(
                                color: Colors.grey,
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
                                      crossAxisSpacing: 10.w,
                                      mainAxisSpacing: 16.h,
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
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: action['color']
                                                    .withValues(alpha: 0.3),
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
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      isLoading
                                          ? '...'
                                          : '${pendingVisitors.length}',
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
                              if (isLoading)
                                _buildPendingApprovalsShimmer()
                              else if (pendingVisitors.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: pendingVisitors.length,
                                  itemBuilder: (context, index) {
                                    final visitor = pendingVisitors[index];
                                    return _buildPendingCard(visitor);
                                  },
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(12.r),
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

                          SizedBox(height: 20.h),

                          // Recent Activity
                          if (isLoading)
                            _buildRecentActivityShimmer()
                          else if (recentActivity.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Activity',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Column(
                                    children: recentActivity
                                        .map(
                                          (v) => ListTile(
                                            leading: Container(
                                              width: 50.w,
                                              height: 50.w,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                child: Image.network(
                                                  '${v['image_url']}',
                                                  width: 50.w,
                                                  height: 50.w,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Icon(
                                                          Icons.person,
                                                          color:
                                                              AppTheme.primary,
                                                        );
                                                      },
                                                ),
                                              ),
                                            ),
                                            title: Text(v['name'] ?? 'Visitor'),
                                            subtitle: Text(
                                              '${v['visitor_type'] ?? 'guest'} • ${v['status'] ?? ''}',
                                            ),
                                            trailing: Text(
                                              _formatTime(v['created_at']),
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

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  /// Shimmer effect for Pending Approvals section
  Widget _buildPendingApprovalsShimmer() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (context, index) {
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
                      // Avatar shimmer
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name shimmer
                            Container(
                              width: 120.w,
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Visitor type shimmer
                            Container(
                              width: 80.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            SizedBox(height: 4.h),
                            // Resident info shimmer
                            Container(
                              width: 140.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  // Action buttons shimmer
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
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
      ),
    );
  }

  /// Shimmer effect for Recent Activity section
  Widget _buildRecentActivityShimmer() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header shimmer
          Container(
            width: 140.w,
            height: 22.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: List.generate(3, (index) {
                return ListTile(
                  leading: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  title: Container(
                    width: 100.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  subtitle: Container(
                    width: 80.w,
                    height: 12.h,
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  trailing: Container(
                    width: 50.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> visitor) {
    final residentName = visitor['resident_name'] ?? 'Unknown Resident';
    final visitorType = visitor['visitor_type'] ?? 'Guest';
    final createdAt = _formatTime(visitor['created_at']);

    return Card(
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            Row(
              children: [
                visitor['image_url'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: visitor['image_url'],
                          fit: BoxFit.cover,
                          width: 50.r,
                          height: 50.r,
                        ),
                      )
                    : Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppTheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppTheme.primary,
                          size: 28.sp,
                        ),
                      ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor['name'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        visitorType.toString().toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                      Text(
                        'For: $residentName • $createdAt',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
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
                    onPressed: () => _handleReject(visitor),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleApprove(visitor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return createdAt.toString();
    }
  }
}

// // ignore_for_file: unused_element, unused_local_variable, unused_field

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
// import 'package:mygate_coepd/blocs/auth/auth_state.dart';
// import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
// import 'package:mygate_coepd/screens/guard/coming_soon.dart';
// import 'package:mygate_coepd/screens/guard/visitor_management_screen.dart';
// import 'package:mygate_coepd/theme/app_theme.dart';
// import 'package:mygate_coepd/screens/guard/details/group_visitor_entry_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/vendor_access_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/utility_vehicle_tracking_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/guard_patrolling_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/offline_mode_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/security_alerts_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/e_intercom_screen.dart';
// import 'package:mygate_coepd/screens/guard/details/guard_calling_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class GuardDashboardScreen extends StatefulWidget {
//   const GuardDashboardScreen({super.key});

//   @override
//   State<GuardDashboardScreen> createState() => _GuardDashboardScreenState();
// }

// class _GuardDashboardScreenState extends State<GuardDashboardScreen> {
//   final List<Map<String, dynamic>> _quickActions = [
//     {
//       'icon': Icons.person_add,
//       'label': 'Visitor Entry',
//       'color': AppTheme.primary,
//       'screen': 'visitor_entry',
//     },
//     {
//       'icon': Icons.group,
//       'label': 'Group Entry',
//       'color': AppTheme.secondary,
//       'screen': 'group_entry',
//     },
//     {
//       'icon': Icons.build,
//       'label': 'Vendor Access',
//       'color': AppTheme.success,
//       'screen': 'vendor_access',
//     },
//     {
//       'icon': Icons.directions_car,
//       'label': 'Vehicle Log',
//       'color': AppTheme.warning,
//       'screen': 'vehicle_log',
//     },
//     {
//       'icon': Icons.directions_walk,
//       'label': 'Patrolling',
//       'color': AppTheme.primaryDark,
//       'screen': 'patrolling',
//     },
//     {
//       'icon': Icons.phone,
//       'label': 'Call Guard',
//       'color': AppTheme.error,
//       'screen': 'call_guard',
//     },
//     {
//       'icon': Icons.warning_amber,
//       'label': 'Security',
//       'color': AppTheme.secondary,
//       'screen': 'security_alerts',
//     },
//     {
//       'icon': Icons.voicemail,
//       'label': 'E-Intercom',
//       'color': AppTheme.info,
//       'screen': 'e_intercom',
//     },
//     {
//       'icon': Icons.wifi_off,
//       'label': 'Offline Mode',
//       'color': AppTheme.primaryDark,
//       'screen': 'offline_mode',
//     },
//     {
//       'icon': Icons.language,
//       'label': 'Language',
//       'color': AppTheme.success,
//       'screen': 'language',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     context.read<GuardBloc>().add(const LoadGuardDashboard());
//   }

//   void _navigateToScreen(String screen) {
//     switch (screen) {
//       case 'visitor_entry':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const GuardVisitorManagementScreen(),
//           ),
//         );
//         break;
//       case 'group_entry':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const GroupVisitorEntryScreen()),
//         );
//         break;
//       case 'vendor_access':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const VendorAccessScreen()),
//         );
//         break;
//       case 'vehicle_log':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => const UtilityVehicleTrackingScreen(),
//           ),
//         );
//         break;
//       case 'patrolling':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const GuardPatrollingScreen()),
//         );
//         break;
//       case 'offline_mode':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const OfflineModeScreen()),
//         );
//         break;
//       case 'security_alerts':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const SecurityAlertsScreen()),
//         );
//         break;
//       case 'e_intercom':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const EIntercomScreen()),
//         );
//         break;
//       case 'call_guard':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const GuardCallingScreen()),
//         );
//         break;
//       default:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const CommingSoonScreen()),
//         );
//     }
//   }

//   void _handleApprove(Map<String, dynamic> visitor) {
//     final id = int.tryParse(visitor['id']?.toString() ?? '');
//     if (id == null) return;
//     context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'approved'));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Visitor approved'),
//         backgroundColor: AppTheme.success,
//       ),
//     );
//     // Reload dashboard
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) context.read<GuardBloc>().add(const LoadGuardDashboard());
//     });
//   }

//   void _handleReject(Map<String, dynamic> visitor) {
//     final id = int.tryParse(visitor['id']?.toString() ?? '');
//     if (id == null) return;
//     context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'rejected'));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Visitor rejected'),
//         backgroundColor: AppTheme.error,
//       ),
//     );
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (mounted) context.read<GuardBloc>().add(const LoadGuardDashboard());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, authState) {
//         if (authState is Authenticated) {
//           return Scaffold(
//             body: BlocConsumer<GuardBloc, GuardState>(
//               listener: (context, state) {
//                 if (state is GuardError) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(state.message),
//                       backgroundColor: AppTheme.error,
//                     ),
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 List<Map<String, dynamic>> pendingVisitors = [];
//                 List<Map<String, dynamic>> recentActivity = [];
//                 log(recentActivity.length.toString(), name: 'recentActivity');
//                 bool isLoading = false;

//                 if (state is GuardLoading) {
//                   isLoading = true;
//                 } else if (state is GuardDashboardLoaded) {
//                   pendingVisitors = state.pendingVisitors;
//                   recentActivity = state.recentActivity;
//                   log(recentActivity.toString(), name: 'recentActivity');
//                 }

//                 return RefreshIndicator(
//                   onRefresh: () async {
//                     context.read<GuardBloc>().add(const LoadGuardDashboard());
//                   },
//                   child: SingleChildScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     child: Padding(
//                       padding: EdgeInsets.all(16.w),
//                       child: Column(
//                         children: [
//                           // Search Bar
//                           TextField(
//                             decoration: InputDecoration(
//                               hintText: 'Search visitors, vehicles or flats...',
//                               hintStyle: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 14.sp,
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 20.w,
//                                 vertical: 16.h,
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.search,
//                                 color: Colors.grey,
//                                 size: 20.sp,
//                               ),
//                             ),
//                           ),

//                           // Quick Actions
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 15.h),
//                               Text(
//                                 'Quick Actions',
//                                 style: TextStyle(
//                                   fontSize: 18.sp,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 15.h),
//                               GridView.builder(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 4,
//                                       crossAxisSpacing: 10.w,
//                                       mainAxisSpacing: 16.h,
//                                     ),
//                                 itemCount: _quickActions.length,
//                                 itemBuilder: (context, index) {
//                                   final action = _quickActions[index];
//                                   return Column(
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () =>
//                                             _navigateToScreen(action['screen']),
//                                         child: Container(
//                                           padding: EdgeInsets.all(15.w),
//                                           decoration: BoxDecoration(
//                                             color: action['color'],
//                                             borderRadius: BorderRadius.circular(
//                                               16.r,
//                                             ),
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 color: action['color']
//                                                     .withValues(alpha: 0.3),
//                                                 blurRadius: 10.w,
//                                                 offset: Offset(0, 5.h),
//                                               ),
//                                             ],
//                                           ),
//                                           child: Icon(
//                                             action['icon'],
//                                             color: Colors.white,
//                                             size: 24.sp,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: 8.h),
//                                       Flexible(
//                                         child: Text(
//                                           action['label'],
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(fontSize: 10.sp),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),

//                           SizedBox(height: 20.h),

//                           // Pending Approvals
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Pending Approvals',
//                                     style: TextStyle(
//                                       fontSize: 18.sp,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: EdgeInsets.all(10.w),
//                                     decoration: BoxDecoration(
//                                       color: Theme.of(context).primaryColor,
//                                       // borderRadius: BorderRadius.circular(20.r),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: Text(
//                                       '${pendingVisitors.length}',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 15.h),
//                               if (isLoading)
//                                 const Center(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20),
//                                     child: CircularProgressIndicator(),
//                                   ),
//                                 )
//                               else if (pendingVisitors.isNotEmpty)
//                                 ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemCount: pendingVisitors.length,
//                                   itemBuilder: (context, index) {
//                                     final visitor = pendingVisitors[index];
//                                     return _buildPendingCard(visitor);
//                                   },
//                                 )
//                               else
//                                 Card(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16.r),
//                                   ),
//                                   child: Padding(
//                                     padding: EdgeInsets.all(20.w),
//                                     child: Column(
//                                       children: [
//                                         Icon(
//                                           Icons.check_circle,
//                                           color: Colors.green,
//                                           size: 40.sp,
//                                         ),
//                                         SizedBox(height: 15.h),
//                                         const Text(
//                                           'No pending approvals',
//                                           style: TextStyle(color: Colors.grey),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),

//                           SizedBox(height: 20.h),

//                           // Recent Activity
//                           if (recentActivity.isNotEmpty)
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Recent Activity',
//                                   style: TextStyle(
//                                     fontSize: 18.sp,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 10.h),
//                                 Card(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(16.r),
//                                   ),
//                                   child: Column(
//                                     children: recentActivity
//                                         .map(
//                                           (v) => ListTile(
//                                             leading: Container(
//                                               width: 50.w,
//                                               height: 50.w,
//                                               decoration: BoxDecoration(
//                                                 color: AppTheme.primary
//                                                     .withValues(alpha: 0.1),
//                                                 borderRadius:
//                                                     BorderRadius.circular(12.r),
//                                               ),
//                                               // child: Icon(
//                                               //   Icons.person,
//                                               //   color: AppTheme.primary,
//                                               // ),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12.r),
//                                                 child: Image.network(
//                                                   '${v['image_url']}',
//                                                   width: 50.w,
//                                                   height: 50.w,
//                                                   fit: BoxFit.cover,
//                                                   errorBuilder:
//                                                       (
//                                                         context,
//                                                         error,
//                                                         stackTrace,
//                                                       ) {
//                                                         return Icon(
//                                                           Icons.person,
//                                                           color:
//                                                               AppTheme.primary,
//                                                         );
//                                                       },
//                                                 ),
//                                               ),
//                                             ),
//                                             title: Text(v['name'] ?? 'Visitor'),
//                                             subtitle: Text(
//                                               '${v['visitor_type'] ?? 'guest'} • ${v['status'] ?? ''}',
//                                             ),
//                                             trailing: Text(
//                                               _formatTime(v['created_at']),
//                                               style: TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 12.sp,
//                                               ),
//                                             ),
//                                           ),
//                                         )
//                                         .toList(),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                           SizedBox(height: 20.h),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//         }
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       },
//     );
//   }

//   Widget _buildPendingCard(Map<String, dynamic> visitor) {
//     final residentName = visitor['resident_name'] ?? 'Unknown Resident';
//     final visitorType = visitor['visitor_type'] ?? 'Guest';
//     final createdAt = _formatTime(visitor['created_at']);

//     return Card(
//       margin: EdgeInsets.only(bottom: 15.h),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       child: Padding(
//         padding: EdgeInsets.all(15.w),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 visitor['image_url'] != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(12.r),
//                         child: CachedNetworkImage(
//                           imageUrl: visitor['image_url'],
//                           fit: BoxFit.cover,
//                           width: 50.r,
//                           height: 50.r,
//                         ),
//                       )
//                     : Container(
//                         width: 50.r,
//                         height: 50.r,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12.r),
//                           color: AppTheme.primary.withValues(alpha: 0.1),
//                         ),
//                         child: Icon(
//                           Icons.person,
//                           color: AppTheme.primary,
//                           size: 28.sp,
//                         ),
//                       ),
//                 SizedBox(width: 15.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         visitor['name'] ?? '',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         visitorType.toString().toUpperCase(),
//                         style: TextStyle(fontSize: 13.sp, color: Colors.grey),
//                       ),
//                       Text(
//                         'For: $residentName • $createdAt',
//                         style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 15.h),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => _handleReject(visitor),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppTheme.error,
//                       side: const BorderSide(color: AppTheme.error),
//                     ),
//                     child: const Text('Reject'),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _handleApprove(visitor),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.success,
//                     ),
//                     child: const Text(
//                       'Approve',
//                       style: TextStyle(color: Colors.white),
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

//   String _formatTime(dynamic createdAt) {
//     if (createdAt == null) return '';
//     try {
//       final dt = DateTime.parse(createdAt.toString());
//       final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
//       final ampm = dt.hour >= 12 ? 'PM' : 'AM';
//       return '$hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
//     } catch (_) {
//       return createdAt.toString();
//     }
//   }
// }
