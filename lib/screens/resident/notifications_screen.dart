import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        itemCount: 8,
        padding: EdgeInsets.all(24.w),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isCritical = index == 0;
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: isCritical
                    ? Border(
                        left: BorderSide(
                          color: theme.colorScheme.error,
                          width: 4.w,
                        ),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color:
                          (isCritical
                                  ? theme.colorScheme.error
                                  : theme.primaryColor)
                              .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCritical
                          ? Icons.warning_amber_rounded
                          : Icons.notifications_none_rounded,
                      color: isCritical
                          ? theme.colorScheme.error
                          : theme.primaryColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isCritical
                                  ? 'Critical Health Alert'
                                  : 'Appointment Reminder',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            Text(
                              '2m ago',
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          isCritical
                              ? 'Your heart rate exceeded 100bpm while resting. Please contact your doctor.'
                              : 'Your consultation with Dr. Maria Elena starts in 30 minutes.',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
