import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/notification/notification_bloc.dart';
import 'package:mygate_coepd/blocs/notification/notification_event.dart';
import 'package:mygate_coepd/blocs/notification/notification_state.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(
      const LoadNotifications(refresh: true),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = context.read<NotificationBloc>().state;
        if (state is NotificationLoaded &&
            state.hasMore &&
            !state.isPaginating) {
          context.read<NotificationBloc>().add(const LoadNotifications());
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 8) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'visitor_request':
        return Icons.person_add_alt_1;
      case 'visitor_status':
        return Icons.directions_walk;
      case 'visitor_pre_approval':
        return Icons.verified_user;
      case 'health':
        return Icons.health_and_safety;
      case 'announcement':
        return Icons.campaign;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    context.read<NotificationBloc>().add(const MarkAllAsRead());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInitial ||
              (state is NotificationLoading && state is! NotificationLoaded)) {
            // return const Center(child: CircularProgressIndicator());
            return ListView.builder(
              itemCount: 6,
              padding: EdgeInsets.all(20.w),
              itemBuilder: (context, index) {
                return _buildNotificationCardShimmer(Theme.of(context));
              },
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(state.message, textAlign: TextAlign.center),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        const LoadNotifications(refresh: true),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64.sp,
                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(
                  const LoadNotifications(refresh: true),
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    state.notifications.length + (state.isPaginating ? 1 : 0),
                padding: EdgeInsets.all(20.w),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        // child: CircularProgressIndicator(),
                        child: _buildNotificationCardShimmer(Theme.of(context)),
                      ),
                    );
                  }

                  final notification = state.notifications[index];
                  final isCritical =
                      notification.type.toLowerCase() == 'health' ||
                      notification.title.toLowerCase().contains('critical');

                  return FadeInUp(
                    delay: Duration(milliseconds: (index % 10) * 30),
                    child: GestureDetector(
                      onTap: () {
                        if (!notification.isRead) {
                          context.read<NotificationBloc>().add(
                            MarkAsRead(notification.id),
                          );
                        }
                        // Optionally navigate if actionUrl is present
                        if (notification.actionUrl != null &&
                            notification.actionUrl!.isNotEmpty) {
                          // Handle navigation using your routes
                          // Navigator.pushNamed(context, notification.actionUrl!);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? theme.cardColor
                              : theme.primaryColor.withValues(alpha: 0.05),
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
                              : (!notification.isRead
                                    ? Border.all(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      )
                                    : null),
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
                                _getIconForType(notification.type),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: TextStyle(
                                            fontWeight: notification.isRead
                                                ? FontWeight.w600
                                                : FontWeight.bold,
                                            fontSize: 15.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        _timeAgo(notification.createdAt),
                                        style: TextStyle(
                                          color: theme.colorScheme.secondary,
                                          fontSize: 11.sp,
                                          fontWeight: notification.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    notification.message,
                                    style: TextStyle(
                                      color: notification.isRead
                                          ? theme.colorScheme.secondary
                                          : theme.textTheme.bodyMedium?.color,
                                      fontSize: 13.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!notification.isRead) ...[
                              SizedBox(width: 8.w),
                              Container(
                                width: 8.w,
                                height: 8.w,
                                margin: EdgeInsets.only(top: 6.h),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationCardShimmer(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        height: 100.h,
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
        ),
      ),
    );
  }
}
