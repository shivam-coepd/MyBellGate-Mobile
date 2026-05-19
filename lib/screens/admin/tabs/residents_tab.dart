import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class ResidentsTab extends StatelessWidget {
  const ResidentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> residentStats = [
      {
        'title': 'Total Residents',
        'value': '246',
        'icon': Icons.people,
        'color': AppTheme.primary,
      },
      {
        'title': 'New This Month',
        'value': '12',
        'icon': Icons.person_add,
        'color': AppTheme.success,
      },
      {
        'title': 'Pending Approval',
        'value': '8',
        'icon': Icons.hourglass_empty,
        'color': AppTheme.secondary,
      },
      {
        'title': 'Active Tenants',
        'value': '64',
        'icon': Icons.apartment,
        'color': AppTheme.primary,
      },
    ];

    final List<Map<String, dynamic>> residentList = [
      {
        'id': 1,
        'name': 'Rahul Kumar',
        'unit': 'A-101',
        'phone': '+91 9876543210',
        'status': 'Active',
        'statusColor': AppTheme.success,
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
      },
      {
        'id': 2,
        'name': 'Priya Sharma',
        'unit': 'B-203',
        'phone': '+91 9876543211',
        'status': 'Pending',
        'statusColor': AppTheme.secondary,
        'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
      },
      {
        'id': 3,
        'name': 'Amit Patel',
        'unit': 'C-405',
        'phone': '+91 9876543212',
        'status': 'Active',
        'statusColor': AppTheme.success,
        'image': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&q=80&w=100&h=100',
      },
      {
        'id': 4,
        'name': 'Sneha Gupta',
        'unit': 'D-102',
        'phone': '+91 9876543213',
        'status': 'Inactive',
        'statusColor': AppTheme.onBackgroundLight,
        'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=100&h=100',
      },
    ];

    final List<Map<String, dynamic>> quickActions = [
      {'icon': Icons.add, 'label': 'Add Resident', 'route': '/add-resident'},
      {'icon': Icons.search, 'label': 'Search', 'route': '/search-residents'},
      {'icon': Icons.file_download, 'label': 'Export', 'route': '/export-residents'},
      {'icon': Icons.notifications, 'label': 'Send Notice', 'route': '/send-notice'},
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
              itemCount: residentStats.length,
              itemBuilder: (context, index) {
                final stat = residentStats[index];
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
          // Residents List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Residents List',
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
                        '${residentList.length}',
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
                  itemCount: residentList.length,
                  itemBuilder: (context, index) {
                    final resident = residentList[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(15.r),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25.r,
                              backgroundImage: NetworkImage(resident['image']),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resident['name'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    resident['unit'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.onBackgroundLight,
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    resident['phone'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.onBackgroundLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: resident['statusColor']
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    resident['status'],
                                    style: TextStyle(
                                      color: resident['statusColor'],
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        // Edit resident
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20.r,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // View details
                                      },
                                      icon: Icon(
                                        Icons.visibility,
                                        size: 20.r,
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