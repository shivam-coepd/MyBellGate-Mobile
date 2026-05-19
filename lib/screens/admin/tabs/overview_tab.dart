import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OverviewTab extends StatelessWidget {
  final List<Map<String, dynamic>> stats;
  final List<Map<String, dynamic>> quickAccess;
  final List<Map<String, dynamic>> pendingApprovals;
  final List<Map<String, dynamic>> recentActivity;
  final Function(int) onApprove;
  final Function(int) onReject;

  const OverviewTab({
    super.key,
    required this.stats,
    required this.quickAccess,
    required this.pendingApprovals,
    required this.recentActivity,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats Cards
          Padding(
            padding: EdgeInsets.all(20.r),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.w,
                mainAxisSpacing: 15.h,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: stat['color'].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                stat['icon'],
                                color: stat['color'],
                                size: 24.r,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),
          // Quick Access
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: quickAccess.length,
                  itemBuilder: (context, index) {
                    final item = quickAccess[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to the respective module
                            if (item['route'] != null) {
                              Navigator.pushNamed(context, item['route']);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(15.r),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.onBackgroundLight.withValues(alpha: 0.1),
                                  blurRadius: 5.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              item['icon'],
                              color: AppTheme.primary,
                              size: 28.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item['label'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Pending Approvals
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
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
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${pendingApprovals.length}',
                        style: const TextStyle(
                          color: AppTheme.onSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                if (pendingApprovals.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingApprovals.length,
                    itemBuilder: (context, index) {
                      final approval = pendingApprovals[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(15.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25.r,
                                    backgroundImage: CachedNetworkImageProvider(
                                      approval['image'],
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.1),
                                  ),
                                  SizedBox(width: 15.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          approval['name'],
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
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
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        onReject(approval['id']);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
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
                                        onApprove(approval['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r),
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
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.success,
                            size: 40.r,
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
          ),
          SizedBox(height: 20.h),
          // Recent Activity
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
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
                    children: recentActivity.map((activity) {
                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: activity['iconBg'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            activity['icon'],
                            color: activity['iconColor'],
                            size: 24.r,
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
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                        trailing: Text(
                          activity['time'],
                          style: TextStyle(
                            color: AppTheme.onBackgroundLight,
                            fontSize: 12.sp,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 80.h), // Space for bottom bar
        ],
      ),
    );
  }
}