import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class BillingTab extends StatelessWidget {
  const BillingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> billingStats = [
      {
        'title': 'Total Revenue',
        'value': '₹4,25,000',
        'change': '+12%',
        'isIncrease': true,
        'icon': Icons.account_balance_wallet,
        'color': AppTheme.success,
      },
      {
        'title': 'Pending Payments',
        'value': '₹86,500',
        'change': '-5%',
        'isIncrease': false,
        'icon': Icons.pending_actions,
        'color': AppTheme.secondary,
      },
      {
        'title': 'Overdue Bills',
        'value': '₹32,000',
        'change': '+3',
        'isIncrease': true,
        'icon': Icons.warning,
        'color': AppTheme.error,
      },
      {
        'title': 'Collection Rate',
        'value': '89%',
        'change': '+2%',
        'isIncrease': true,
        'icon': Icons.trending_up,
        'color': AppTheme.primary,
      },
    ];

    final List<Map<String, dynamic>> billingList = [
      {
        'id': 1,
        'resident': 'Rahul Kumar',
        'unit': 'A-101',
        'amount': '₹12,500',
        'dueDate': '15 Jun 2023',
        'status': 'Paid',
        'statusColor': AppTheme.success,
      },
      {
        'id': 2,
        'resident': 'Priya Sharma',
        'unit': 'B-203',
        'amount': '₹8,750',
        'dueDate': '15 Jun 2023',
        'status': 'Pending',
        'statusColor': AppTheme.secondary,
      },
      {
        'id': 3,
        'resident': 'Amit Patel',
        'unit': 'C-405',
        'amount': '₹15,200',
        'dueDate': '10 Jun 2023',
        'status': 'Overdue',
        'statusColor': AppTheme.error,
      },
      {
        'id': 4,
        'resident': 'Sneha Gupta',
        'unit': 'D-102',
        'amount': '₹11,300',
        'dueDate': '20 Jun 2023',
        'status': 'Pending',
        'statusColor': AppTheme.secondary,
      },
    ];

    final List<Map<String, dynamic>> quickActions = [
      {'icon': Icons.add, 'label': 'New Bill', 'route': '/create-bill'},
      {'icon': Icons.search, 'label': 'Search', 'route': '/search-bills'},
      {'icon': Icons.file_download, 'label': 'Export', 'route': '/export-bills'},
      {'icon': Icons.notifications, 'label': 'Send Reminder', 'route': '/send-reminder'},
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
              itemCount: billingStats.length,
              itemBuilder: (context, index) {
                final stat = billingStats[index];
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
                                fontSize: 20.sp,
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
          // Billing List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Billing List',
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
                        '${billingList.length}',
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
                  itemCount: billingList.length,
                  itemBuilder: (context, index) {
                    final bill = billingList[index];
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
                                Text(
                                  bill['resident'],
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bill['statusColor']
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    bill['status'],
                                    style: TextStyle(
                                      color: bill['statusColor'],
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
                                      'Unit: ${bill['unit']}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppTheme.onBackgroundLight,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      'Due: ${bill['dueDate']}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: AppTheme.onBackgroundLight,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  bill['amount'],
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // View details
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
                                      'View',
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
                                      // Send reminder
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
                                      'Remind',
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