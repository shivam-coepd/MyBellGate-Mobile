import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reportStats = [
      {
        'title': 'Generated Reports',
        'value': '24',
        'icon': Icons.description,
        'color': AppTheme.primary,
      },
      {
        'title': 'This Month',
        'value': '6',
        'icon': Icons.calendar_month,
        'color': AppTheme.success,
      },
      {
        'title': 'Pending',
        'value': '2',
        'icon': Icons.pending_actions,
        'color': AppTheme.secondary,
      },
      {
        'title': 'Automated',
        'value': '18',
        'icon': Icons.auto_graph,
        'color': AppTheme.primary,
      },
    ];

    final List<Map<String, dynamic>> reportList = [
      {
        'id': 1,
        'title': 'Monthly Financial Report',
        'date': '15 Jun 2023',
        'type': 'Financial',
        'status': 'Generated',
        'statusColor': AppTheme.success,
      },
      {
        'id': 2,
        'title': 'Resident Activity Report',
        'date': '12 Jun 2023',
        'type': 'Activity',
        'status': 'Generated',
        'statusColor': AppTheme.success,
      },
      {
        'id': 3,
        'title': 'Maintenance Report',
        'date': '10 Jun 2023',
        'type': 'Maintenance',
        'status': 'Pending',
        'statusColor': AppTheme.secondary,
      },
      {
        'id': 4,
        'title': 'Security Report',
        'date': '08 Jun 2023',
        'type': 'Security',
        'status': 'Generated',
        'statusColor': AppTheme.success,
      },
    ];

    final List<Map<String, dynamic>> quickActions = [
      {'icon': Icons.add, 'label': 'New Report', 'route': '/generate-report'},
      {'icon': Icons.search, 'label': 'Search', 'route': '/search-reports'},
      {'icon': Icons.schedule, 'label': 'Schedule', 'route': '/schedule-reports'},
      {'icon': Icons.download, 'label': 'Download All', 'route': '/download-reports'},
    ];

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
              itemCount: reportStats.length,
              itemBuilder: (context, index) {
                final stat = reportStats[index];
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
                        Text(
                          stat['value'],
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Quick Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.h,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: quickActions.length,
                  itemBuilder: (context, index) {
                    final action = quickActions[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to the respective action
                            if (action['route'] != null) {
                              Navigator.pushNamed(context, action['route']);
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
                              action['icon'],
                              color: AppTheme.primary,
                              size: 28.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          action['label'],
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
          // Reports List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reports List',
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
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${reportList.length}',
                        style: const TextStyle(
                          color: AppTheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reportList.length,
                  itemBuilder: (context, index) {
                    final report = reportList[index];
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    report['title'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: report['statusColor']
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    report['status'],
                                    style: TextStyle(
                                      color: report['statusColor'],
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Type: ${report['type']}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      'Date: ${report['date']}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppTheme.onBackgroundLight,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // View report
                                      },
                                      icon: Icon(
                                        Icons.visibility,
                                        size: 24.r,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // Download report
                                      },
                                      icon: Icon(
                                        Icons.download,
                                        size: 24.r,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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