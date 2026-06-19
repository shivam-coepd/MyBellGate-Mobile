import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/repositories/visitor_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/communications/communications_bloc.dart';
import 'package:mygate_coepd/blocs/accounting/accounting_bloc.dart';
import 'package:mygate_coepd/blocs/helpdesk/helpdesk_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ResidentDashboardScreen extends StatefulWidget {
  const ResidentDashboardScreen({super.key});

  @override
  State<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Weekend Pool Party',
      'date': 'Saturday, 4:00 PM',
      'attendees': 24,
      'image':
          'https://plus.unsplash.com/premium_photo-1682681906293-2113d2e6cc82?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG9vbCUyMHBhcnR5fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
    },
    {
      'title': 'Yoga in the Park',
      'date': 'Sunday, 7:00 AM',
      'attendees': 12,
      'image':
          'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80&w=400&h=300',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.people,
      'label': 'Visitors',
      'color': Colors.blue,
      'screen': 'visitors',
    },
    {
      'icon': Icons.checklist,
      'label': 'Services',
      'color': Colors.green,
      'screen': 'services',
    },
    {
      'icon': Icons.credit_card,
      'label': 'Bills',
      'color': Colors.orange,
      'screen': 'bills',
    },
    {
      'icon': Icons.calendar_month,
      'label': 'Amenities',
      'color': Colors.purple,
      'screen': 'amenities',
    },
    {
      'icon': Icons.chat,
      'label': 'Community',
      'color': Colors.indigo,
      'screen': 'community',
    },
    {
      'icon': Icons.notifications,
      'label': 'Alerts',
      'color': Colors.red,
      'screen': 'announcements',
    },
    {
      'icon': Icons.person,
      'label': 'Profile',
      'color': Colors.teal,
      'screen': 'profile',
    },
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  int _pendingVisitorsCount = 0;
  bool _dataLoaded = false;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Load data only on first build; subsequent updates via pull-to-refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      if (!_dataLoaded) {
        _loadDashboardData();
        _dataLoaded = true;
      }
    });

    super.initState();
  }

  void _loadDashboardData() {
    context.read<CommunicationsBloc>().add(
      const LoadAnnouncements(isDraft: false),
    );
    context.read<AccountingBloc>().add(const LoadInvoices());
    context.read<HelpdeskBloc>().add(const LoadTickets());
    _fetchVisitorsCount();
  }

  Future<void> _onRefresh() async {
    _loadDashboardData();
    // Wait briefly so the indicator is visible
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _fetchVisitorsCount() async {
    try {
      final repository = VisitorRepository();
      final visitors = await repository.getVisitors(status: 'pending');
      if (mounted) {
        setState(() {
          _pendingVisitorsCount = visitors.length;
        });
      }
    } catch (e) {
      // ignore on dashboard
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return SafeArea(
            child: Scaffold(
              key: _scaffoldKey,
              body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      buildInfoHeader(),
                      statsCarouselWidget(),
                      getAnnouncementsSection(),
                      getQuickActionsSection(),
                      getUpcomingEventsSection(),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
              floatingActionButton: ScaleTransition(
                scale: _fadeAnimation,
                child: FloatingActionButton(
                  heroTag: 'dashboard_fab',
                  onPressed: () {
                    Navigator.pushNamed(context, '/services');
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.add,
                    size: 24.sp,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget getQuickStatsUI() {
    return BlocBuilder<AccountingBloc, AccountingState>(
      builder: (context, accState) {
        return BlocBuilder<CommunicationsBloc, CommunicationsState>(
          builder: (context, commState) {
            int billsDue = 0;
            if (accState is InvoicesLoaded) {
              billsDue = accState.invoices
                  .where((i) => i.status != 'paid')
                  .length;
            }
            int updatesCount = 0;
            if (commState is AnnouncementsLoaded) {
              updatesCount = commState.announcements.length;
            }

            final List<Map<String, dynamic>> dynamicStats = [
              {
                'label': 'Visitors',
                'value': _pendingVisitorsCount,
                'icon': Icons.people,
                'color': Colors.blue,
              },
              {
                'label': 'Bills Due',
                'value': billsDue,
                'icon': Icons.credit_card,
                'color': Colors.orange,
              },
              {
                'label': 'Updates',
                'value': updatesCount,
                'icon': Icons.notifications,
                'color': Colors.purple,
              },
            ];

            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 6.w,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dynamicStats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final stat = entry.value;

                  return Expanded(
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.1 * index,
                            0.5 + (0.1 * index),
                            curve: Curves.elasticOut,
                          ),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to respective screens based on stat type
                          switch (stat['label']) {
                            case 'Visitors':
                              Navigator.pushNamed(context, '/visitors');
                              break;
                            case 'Bills Due':
                              Navigator.pushNamed(context, '/bills');
                              break;
                            case 'Updates':
                              Navigator.pushNamed(context, '/announcements');
                              break;
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(context).cardTheme.color!,
                                  Theme.of(
                                    context,
                                  ).cardTheme.color!.withValues(alpha: 0.95),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: stat['color'].withValues(
                                        alpha:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? 0.2
                                            : 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Icon(
                                      stat['icon'] as IconData,
                                      color: stat['color'],
                                      size: 28.sp,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    stat['label'] as String,
                                    style: TextStyle(
                                      color: stat['color'],
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${stat['value']}',
                                    style: TextStyle(
                                      color: stat['color'],
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget getAnnouncementsSection() {
    return BlocBuilder<CommunicationsBloc, CommunicationsState>(
      builder: (context, state) {
        // Show shimmer while loading or on initial state
        if (state is CommunicationsLoading || state is CommunicationsInitial) {
          return _buildShimmerSection();
        }

        // Only render when announcements are actually loaded
        if (state is! AnnouncementsLoaded) {
          return const SizedBox.shrink();
        }

        final items = state.announcements.take(5).toList();

        // Nothing to show
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Updates',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/announcements');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text('View All', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 181.h,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final int count = items.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            (1 / count) * index,
                            1.0,
                            curve: Curves.fastOutSlowIn,
                          ),
                        ),
                      );

                  final announcement = items[index];

                  Color tagColor;
                  switch (announcement.sendVia) {
                    case 'sms':
                      tagColor = Colors.orange;
                      break;
                    case 'email':
                      tagColor = Colors.blue;
                      break;
                    case 'whatsapp':
                      tagColor = Colors.green;
                      break;
                    default:
                      tagColor = const Color(0xFF006D77);
                  }

                  final String fallbackImage = index % 2 == 0
                      ? 'https://images.unsplash.com/photo-1536566482680-fca31930a0bd?auto=format&fit=crop&q=80&w=400&h=300'
                      : 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&q=80&w=400&h=300';

                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Opacity(
                        opacity: animation.value,
                        child: Transform(
                          transform: Matrix4.translationValues(
                            0.0,
                            50 * (1.0 - animation.value),
                            0.0,
                          ),
                          child: SizedBox(
                            width: 250.w,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: fallbackImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.black.withValues(
                                                    alpha: 0.7,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.5,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 15.h,
                                      left: 15.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: tagColor,
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: Text(
                                          announcement.sendVia.toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 15.h,
                                      left: 15.w,
                                      right: 15.w,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            announcement.title,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5.h),
                                          Text(
                                            announcement.createdAt ?? '',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Updates',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/announcements');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.zero,
                ),
                child: Text('View All', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 181.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Theme.of(context).cardColor,
                highlightColor: isDark
                    ? const Color(0xFF334155)
                    : Colors.grey.shade100,
                child: SizedBox(
                  width: 250.w,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        color: Colors.white,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.grey[300]),
                            ),
                            Positioned(
                              top: 15.h,
                              left: 15.w,
                              child: Container(
                                width: 60.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15.h,
                              left: 15.w,
                              right: 15.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 180.w,
                                    height: 16.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    width: 100.w,
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
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget getQuickActionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate optimal cross axis count based on screen width
              final double itemWidth = 80.w; // Base width for each item
              final int crossAxisCount = (constraints.maxWidth / itemWidth)
                  .floor()
                  .clamp(3, 5);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 15.w,
                  mainAxisSpacing: 15.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: _quickActions.length,
                itemBuilder: (context, index) {
                  final int count = _quickActions.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            (1 / count) * index,
                            1.0,
                            curve: Curves.fastOutSlowIn,
                          ),
                        ),
                      );

                  final action = _quickActions[index];
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Opacity(
                        opacity: animation.value,
                        child: Transform(
                          transform: Matrix4.translationValues(
                            0.0,
                            30 * (1.0 - animation.value),
                            0.0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate within the ResidentMainScreen instead of pushing new screens
                              switch (action['screen']) {
                                case 'visitors':
                                  // We need to access the parent ResidentMainScreen to change tabs
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/resident-main/visitors',
                                  );
                                  break;
                                case 'services':
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/resident-main/services',
                                  );
                                  break;
                                case 'bills':
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/resident-main/bills',
                                  );
                                  break;
                                case 'amenities':
                                  Navigator.pushNamed(context, '/amenities');
                                  break;
                                case 'community':
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/community',
                                  );
                                  break;
                                case 'announcements':
                                  Navigator.pushNamed(
                                    context,
                                    '/announcements',
                                  );
                                  break;
                                case 'profile':
                                  Navigator.pushNamed(
                                    context,
                                    '/profile-details',
                                  );
                                  break;
                              }
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(15.w),
                                  decoration: BoxDecoration(
                                    color: action['color'].withValues(
                                      alpha:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? 0.2
                                          : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    action['icon'],
                                    color: action['color'],
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  action['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getUpcomingEventsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingEvents.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final count = _upcomingEvents.length;

              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (1 / count) * index,
                    1,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              );

              final event = _upcomingEvents[index];

              return AnimatedBuilder(
                animation: animation,
                builder: (_, __) {
                  return Opacity(
                    opacity: animation.value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - animation.value)),
                      child: _buildEventCard(event),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upcoming Events',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/announcements'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.zero,
          ),
          child: Text('View All', style: TextStyle(fontSize: 14.sp)),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Material(
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: event['image'],
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 90.w,
                      height: 90.w,
                      color: Colors.grey.shade300,
                    ),
                    errorWidget: (_, __, ___) =>
                        Icon(Icons.image_not_supported),
                  ),
                ),

                SizedBox(width: 12.w),

                /// CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// TITLE
                      Text(
                        event['title'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      /// DATE BADGE
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, size: 12.sp),
                            SizedBox(width: 4.w),
                            Text(
                              event['date'],
                              style: TextStyle(fontSize: 11.sp),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h),

                      /// FOOTER ROW
                      Row(
                        children: [
                          _buildAttendees(event),

                          const Spacer(),

                          _buildRSVPButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendees(Map<String, dynamic> event) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int avatarCount = 3;
    final double overlap = 12.w;

    return SizedBox(
      height: 24.h,
      width: (avatarCount + 1) * overlap + 30.w, // space for +count
      child: Stack(
        children: [
          /// AVATARS
          ...List.generate(
            avatarCount,
            (index) => Positioned(
              left: index * overlap,
              child: CircleAvatar(
                radius: 10.r,
                backgroundColor: Colors.white, // border effect
                child: CircleAvatar(
                  radius: 9.r,
                  backgroundColor: isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),

          /// +COUNT BADGE (also overlapped)
          Positioned(
            left: avatarCount * overlap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: Text(
                '+${event['attendees']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRSVPButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 0,
      ),
      child: Text('RSVP', style: TextStyle(fontSize: 12.sp)),
    );
  }

  // --- Header Info Section ---
  Widget buildInfoHeader() {
    final user = context.read<UserRepository>().getCurrentUser();
    final firstName = (user?.name ?? 'Resident').split(' ').first;
    return Padding(
      padding: EdgeInsets.only(right: 10.w, left: 10.w, bottom: 20.h, top: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Profile & Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      child: ClipOval(
                        child: Image.network(
                          user?.profileImage ?? '',
                          width: 50.w, // Double the radius you want
                          height: 50.w,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 50.w, // Double the radius you want
                                height: 50.w,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50.w, // Double the radius you want
                              height: 50.w,
                              color: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $firstName",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          user?.unit != null
                              ? "Unit: ${user!.unit}"
                              : "Ready to Achieve More Today?",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF8E8E8E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification Icon (Optional, usually present in such UIs)
          InkWell(
            onTap: () =>
                Navigator.pushNamed(context, '/resident-notifications'),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 22.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statsCarouselWidget() {
    return BlocBuilder<AccountingBloc, AccountingState>(
      builder: (context, accState) {
        return BlocBuilder<HelpdeskBloc, HelpdeskState>(
          builder: (context, helpState) {
            double totalDue = 0;
            if (accState is InvoicesLoaded) {
              totalDue = accState.invoices
                  .where((i) => i.status != 'paid')
                  .fold(0.0, (sum, item) => sum + item.totalAmount);
            }
            int activeTickets = 0;
            if (helpState is TicketsLoaded) {
              activeTickets = helpState.tickets
                  .where((t) => t.status != 'resolved' && t.status != 'closed')
                  .length;
            }

            final List<Map<String, dynamic>> statsData = [
              {
                "type": "maintenance",
                "title": "Maintenance Due",
                "amount": "₹ ${totalDue.toStringAsFixed(0)}",
                "dueDate": totalDue > 0 ? "Pay before due date" : "All clear",
                "icon": Icons.account_balance_wallet,
                "color": const Color(0xFF7C7296),
                "action": "Pay Now",
              },
              {
                "type": "visitors",
                "title": "Visitor Requests",
                "count": _pendingVisitorsCount,
                "subtitle": _pendingVisitorsCount == 1
                    ? "Pending approval"
                    : "Pending approvals",
                "icon": Icons.people,
                "color": const Color(0xFFC9A74D),
                "action": "Review",
              },
              {
                "type": "complaints",
                "title": "Active Complaints",
                "count": activeTickets,
                "subtitle": "In progress",
                "icon": Icons.report_problem,
                "color": const Color.fromARGB(255, 178, 59, 59),
                "action": "Track",
              },
            ];

            int currentPage = 0;

            void handleStatAction(BuildContext context, String type) {
              switch (type) {
                case 'maintenance':
                  Navigator.pushNamed(context, '/bills');
                  break;
                case 'visitors':
                  Navigator.pushNamed(context, '/visitors');
                  break;
                case 'complaints':
                  Navigator.pushNamed(context, '/services');
                  break;
              }
            }

            Widget buildStatCard(
              BuildContext context,
              Map<String, dynamic> stat,
            ) {
              final theme = Theme.of(context);
              final cardColor = stat['color'] as Color;
              final icon = stat['icon'] as IconData;

              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cardColor, cardColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    handleStatAction(context, stat['type'] as String);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                icon,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                stat['action'] as String,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                stat['title'] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (stat['amount'] != null)
                                Text(
                                  stat['amount'] as String,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                              else
                                Row(
                                  children: [
                                    Text(
                                      '${stat['count']}',
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      stat['subtitle'] as String,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              if (stat['dueDate'] != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  stat['dueDate'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: statsData.length,
                      itemBuilder: (context, index, realIndex) {
                        return buildStatCard(context, statsData[index]);
                      },
                      options: CarouselOptions(
                        height: 180.h,
                        viewportFraction: 0.8,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        autoPlayCurve: Curves.easeInOut,
                        onPageChanged: (index, _) {
                          setState(() => currentPage = index);
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(statsData.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          width: currentPage == index ? 24.w : 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: currentPage == index
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
