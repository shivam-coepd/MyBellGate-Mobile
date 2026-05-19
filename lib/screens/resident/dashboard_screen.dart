import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResidentDashboardScreen extends StatefulWidget {
  const ResidentDashboardScreen({super.key});

  @override
  State<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _quickStats = [
    {
      'label': 'Visitors',
      'value': 3,
      'icon': Icons.people,
      'color': Colors.blue,
    },
    {
      'label': 'Bills Due',
      'value': 2,
      'icon': Icons.credit_card,
      'color': Colors.orange,
    },
    {
      'label': 'Updates',
      'value': 4,
      'icon': Icons.notifications,
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _announcements = [
    {
      'title': 'Water Supply Interruption',
      'date': 'Today, 10:00 AM - 2:00 PM',
      'description':
          'Due to maintenance work, there will be a water supply interruption.',
      'image':
          'https://images.unsplash.com/photo-1536566482680-fca31930a0bd?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Important',
      'tagColor': Colors.red,
    },
    {
      'title': 'Annual General Meeting',
      'date': 'May 15, 6:00 PM',
      'description':
          'All residents are requested to attend the Annual General Meeting.',
      'image':
          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Event',
      'tagColor': Colors.blue,
    },
    {
      'title': 'New Gym Equipment',
      'date': 'Starting Next Week',
      'description': 'We have installed new equipment in the community gym.',
      'image':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Amenity',
      'tagColor': Colors.green,
    },
  ];

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
      'icon': Icons.calendar_today,
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

    // Start animations after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final user = state.user;
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                "MyBellGate",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              backgroundColor: theme.scaffoldBackgroundColor,
              // foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,

              // leading: IconButton(
              //   icon: const Icon(Icons.menu),
              //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              // ),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: CircleAvatar(
                    radius: 18.r,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 20.sp,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                ),
                SizedBox(width: 16.w),
              ],
            ),
            // drawer: _buildDrawer(context, user),
            // drawer: AppDrawer(user: user),
            body: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              // backgroundColor: Colors.grey.shade300,
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10.h),
                    statsCarouselWidget(),
                    getAnnouncementsSection(),
                    getQuickActionsSection(),
                    getUpcomingEventsSection(),
                    SizedBox(height: 80.h)
                  ],
                ),
              ),
            ),
            floatingActionButton: ScaleTransition(
              scale: _fadeAnimation,
              child: FloatingActionButton(
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
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget getAppBarUI(User user) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
            offset: Offset(0, 2.h),
            blurRadius: 4.w,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      user.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/announcements');
                },
                icon: Icon(Icons.notifications, size: 24.sp),
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            SizedBox(width: 12.w),
            FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundImage: user.profileImage != null
                      ? CachedNetworkImageProvider(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Icon(
                          Icons.person,
                          color: Theme.of(context).primaryColor,
                          size: 24.sp,
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getQuickStatsUI() {
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
        children: _quickStats.asMap().entries.map((entry) {
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
  }

  Widget getAnnouncementsSection() {
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
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            itemCount: _announcements.length,
            itemBuilder: (context, index) {
              final int count = _announcements.length;
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

              final announcement = _announcements[index];
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
                      child: Container(
                        width: 250.w,
                        margin: EdgeInsets.only(right: 15.w),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: announcement['image'],
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
                                      color: announcement['tagColor'],
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      announcement['tag'],
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
                                        announcement['title'],
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
                                        announcement['date'],
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
                  childAspectRatio: 0.9,
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
                                  Navigator.pushNamed(
                                    context,
                                    '/resident-main/visitors',
                                  );
                                  break;
                                case 'services':
                                  Navigator.pushNamed(
                                    context,
                                    '/resident-main/services',
                                  );
                                  break;
                                case 'bills':
                                  Navigator.pushNamed(
                                    context,
                                    '/resident-main/bills',
                                  );
                                  break;
                                case 'amenities':
                                  Navigator.pushNamed(context, '/amenities');
                                  break;
                                case 'community':
                                  Navigator.pushNamed(
                                    context,
                                    '/resident-main/community',
                                  );
                                  break;
                                case 'announcements':
                                  Navigator.pushNamed(
                                    context,
                                    '/announcements',
                                  );
                                  break;
                                case 'profile':
                                  Navigator.pushNamed(context, '/profile');
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
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
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
                          ).primaryColor.withOpacity(0.1),
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

  Widget statsCarouselWidget() {
    final List<Map<String, dynamic>> statsData = [
      {
        "type": "maintenance",
        "title": "Maintenance Due",
        "amount": "₹ 8,500",
        "dueDate": "Due by 31 Dec 2025",
        "icon": Icons.account_balance_wallet,
        "color": const Color(0xFF7C7296),
        "action": "Pay Now",
      },
      {
        "type": "visitors",
        "title": "Visitor Requests",
        "count": 2,
        "subtitle": "Pending approval",
        "icon": Icons.people,
        "color": const Color(0xFFC9A74D),
        "action": "Review",
      },
      {
        "type": "complaints",
        "title": "Active Complaints",
        "count": 1,
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
          Navigator.pushNamed(context, '/payments-screen');
          break;
        case 'visitors':
          Navigator.pushNamed(context, '/visitor-management-screen');
          break;
        case 'complaints':
          Navigator.pushNamed(context, '/complaints-management-screen');
          break;
      }
    }

    Widget buildStatCard(BuildContext context, Map<String, dynamic> stat) {
      final theme = Theme.of(context);
      final cardColor = stat['color'] as Color;
      final icon = stat['icon'] as IconData;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardColor, cardColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28.sp),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (stat['amount'] != null)
                      Text(
                        stat['amount'] as String,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Text(
                            '${stat['count']}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            stat['subtitle'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    if (stat['dueDate'] != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        stat['dueDate'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
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
                viewportFraction: 0.88,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
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
                          ).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
// import 'package:mygate_coepd/blocs/auth/auth_state.dart';
// import 'package:mygate_coepd/models/user.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ResidentDashboardScreen extends StatefulWidget {
//   const ResidentDashboardScreen({super.key});

//   @override
//   State<ResidentDashboardScreen> createState() =>
//       _ResidentDashboardScreenState();
// }

// class _ResidentDashboardScreenState extends State<ResidentDashboardScreen>
//     with TickerProviderStateMixin {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   final List<Map<String, dynamic>> _quickStats = [
//     {
//       'label': 'Visitors',
//       'value': 3,
//       'icon': Icons.people,
//       'color': Colors.blue,
//     },
//     {
//       'label': 'Bills Due',
//       'value': 2,
//       'icon': Icons.credit_card,
//       'color': Colors.orange,
//     },
//     {
//       'label': 'Updates',
//       'value': 4,
//       'icon': Icons.notifications,
//       'color': Colors.purple,
//     },
//   ];

//   final List<Map<String, dynamic>> _announcements = [
//     {
//       'title': 'Water Supply Interruption',
//       'date': 'Today, 10:00 AM - 2:00 PM',
//       'description':
//           'Due to maintenance work, there will be a water supply interruption.',
//       'image':
//           'https://images.unsplash.com/photo-1536566482680-fca31930a0bd?auto=format&fit=crop&q=80&w=400&h=300',
//       'tag': 'Important',
//       'tagColor': Colors.red,
//     },
//     {
//       'title': 'Annual General Meeting',
//       'date': 'May 15, 6:00 PM',
//       'description':
//           'All residents are requested to attend the Annual General Meeting.',
//       'image':
//           'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&q=80&w=400&h=300',
//       'tag': 'Event',
//       'tagColor': Colors.blue,
//     },
//     {
//       'title': 'New Gym Equipment',
//       'date': 'Starting Next Week',
//       'description': 'We have installed new equipment in the community gym.',
//       'image':
//           'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=400&h=300',
//       'tag': 'Amenity',
//       'tagColor': Colors.green,
//     },
//   ];

//   final List<Map<String, dynamic>> _upcomingEvents = [
//     {
//       'title': 'Weekend Pool Party',
//       'date': 'Saturday, 4:00 PM',
//       'attendees': 24,
//       'image':
//           'https://plus.unsplash.com/premium_photo-1682681906293-2113d2e6cc82?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cG9vbCUyMHBhcnR5fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
//     },
//     {
//       'title': 'Yoga in the Park',
//       'date': 'Sunday, 7:00 AM',
//       'attendees': 12,
//       'image':
//           'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&q=80&w=400&h=300',
//     },
//   ];

//   final List<Map<String, dynamic>> _quickActions = [
//     {
//       'icon': Icons.people,
//       'label': 'Visitors',
//       'color': Colors.blue,
//       'screen': 'visitors',
//     },
//     {
//       'icon': Icons.checklist,
//       'label': 'Services',
//       'color': Colors.green,
//       'screen': 'services',
//     },
//     {
//       'icon': Icons.credit_card,
//       'label': 'Bills',
//       'color': Colors.orange,
//       'screen': 'bills',
//     },
//     {
//       'icon': Icons.calendar_today,
//       'label': 'Amenities',
//       'color': Colors.purple,
//       'screen': 'amenities',
//     },
//     {
//       'icon': Icons.chat,
//       'label': 'Community',
//       'color': Colors.indigo,
//       'screen': 'community',
//     },
//     {
//       'icon': Icons.notifications,
//       'label': 'Alerts',
//       'color': Colors.red,
//       'screen': 'announcements',
//     },
//     {
//       'icon': Icons.person,
//       'label': 'Profile',
//       'color': Colors.teal,
//       'screen': 'profile',
//     },
//   ];

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );

//     // Start animations after a small delay
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _animationController.forward();
//     });

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, state) {
//         if (state is Authenticated) {
//           final user = state.user;
//           return Scaffold(
//             key: _scaffoldKey,
//             appBar: AppBar(
//               title: Text(
//                 "MyBellGate",
//                 style: TextStyle(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                   color: theme.primaryColor,
//                 ),
//               ),
//               backgroundColor: theme.scaffoldBackgroundColor,
//               // foregroundColor: Colors.transparent,
//               surfaceTintColor: Colors.transparent,
//               elevation: 0,

//               // leading: IconButton(
//               //   icon: const Icon(Icons.menu),
//               //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//               // ),
//               actions: [
//                 GestureDetector(
//                   onTap: () => Navigator.pushNamed(context, '/profile'),
//                   child: CircleAvatar(
//                     radius: 18.r,
//                     backgroundImage: user.profileImage != null
//                         ? NetworkImage(user.profileImage!)
//                         : null,
//                     child: user.profileImage == null
//                         ? Icon(
//                             Icons.person,
//                             size: 20.sp,
//                             color: Theme.of(context).primaryColor,
//                           )
//                         : null,
//                   ),
//                 ),
//                 SizedBox(width: 16.w),
//               ],
//             ),
//             // drawer: _buildDrawer(context, user),
//             // drawer: AppDrawer(user: user),
//             body: Scaffold(
//               backgroundColor: theme.scaffoldBackgroundColor,
//               // backgroundColor: Colors.grey.shade300,
//               body: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     SizedBox(height: 10.h),
//                     statsCarouselWidget(),
//                     getAnnouncementsSection(),
//                     getQuickActionsSection(),
//                     eventsGridWidget(),
//                   ],
//                 ),
//               ),
//             ),
//             floatingActionButton: ScaleTransition(
//               scale: _fadeAnimation,
//               child: FloatingActionButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/services');
//                 },
//                 backgroundColor: Theme.of(context).primaryColor,
//                 child: Icon(
//                   Icons.add,
//                   size: 24.sp,
//                   color: Theme.of(context).colorScheme.onPrimary,
//                 ),
//               ),
//             ),
//           );
//         }
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       },
//     );
//   }

//   Widget getAppBarUI(User user) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).primaryColor,
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white.withValues(alpha: 0.1)
//                 : Colors.grey.withValues(alpha: 0.2),
//             offset: Offset(0, 2.h),
//             blurRadius: 4.w,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//           top: MediaQuery.of(context).padding.top,
//           left: 16.w,
//           right: 16.w,
//           bottom: 16.h,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Text(
//                       'Welcome back',
//                       style: TextStyle(
//                         color: Theme.of(
//                           context,
//                         ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Text(
//                       user.name,
//                       style: TextStyle(
//                         color: Theme.of(context).textTheme.bodyLarge?.color,
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: IconButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/announcements');
//                 },
//                 icon: Icon(Icons.notifications, size: 24.sp),
//                 color: Theme.of(context).iconTheme.color,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(context, '/profile');
//                 },
//                 child: CircleAvatar(
//                   radius: 20.r,
//                   backgroundImage: user.profileImage != null
//                       ? CachedNetworkImageProvider(user.profileImage!)
//                       : null,
//                   child: user.profileImage == null
//                       ? Icon(
//                           Icons.person,
//                           color: Theme.of(context).primaryColor,
//                           size: 24.sp,
//                         )
//                       : null,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getQuickStatsUI() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Theme.of(context).primaryColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20.r),
//           bottomRight: Radius.circular(20.r),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? Colors.white.withValues(alpha: 0.1)
//                 : Colors.grey.withValues(alpha: 0.2),
//             blurRadius: 6.w,
//             offset: Offset(0, 4.h),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: _quickStats.asMap().entries.map((entry) {
//           final index = entry.key;
//           final stat = entry.value;

//           return Expanded(
//             child: ScaleTransition(
//               scale: Tween<double>(begin: 0.8, end: 1.0).animate(
//                 CurvedAnimation(
//                   parent: _animationController,
//                   curve: Interval(
//                     0.1 * index,
//                     0.5 + (0.1 * index),
//                     curve: Curves.elasticOut,
//                   ),
//                 ),
//               ),
//               child: GestureDetector(
//                 onTap: () {
//                   // Navigate to respective screens based on stat type
//                   switch (stat['label']) {
//                     case 'Visitors':
//                       Navigator.pushNamed(context, '/visitors');
//                       break;
//                     case 'Bills Due':
//                       Navigator.pushNamed(context, '/bills');
//                       break;
//                     case 'Updates':
//                       Navigator.pushNamed(context, '/announcements');
//                       break;
//                   }
//                 },
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   elevation: 2,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Theme.of(context).cardTheme.color!,
//                           Theme.of(
//                             context,
//                           ).cardTheme.color!.withValues(alpha: 0.95),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Padding(
//                       padding: EdgeInsets.all(12.w),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(10.w),
//                             decoration: BoxDecoration(
//                               color: stat['color'].withValues(
//                                 alpha:
//                                     Theme.of(context).brightness ==
//                                         Brightness.dark
//                                     ? 0.2
//                                     : 0.1,
//                               ),
//                               borderRadius: BorderRadius.circular(30.r),
//                             ),
//                             child: Icon(
//                               stat['icon'] as IconData,
//                               color: stat['color'],
//                               size: 28.sp,
//                             ),
//                           ),
//                           SizedBox(height: 8.h),
//                           Text(
//                             stat['label'] as String,
//                             style: TextStyle(
//                               color: stat['color'],
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(height: 4.h),
//                           Text(
//                             '${stat['value']}',
//                             style: TextStyle(
//                               color: stat['color'],
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget getAnnouncementsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Latest Updates',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).textTheme.titleLarge?.color,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/announcements');
//                 },
//                 child: Text(
//                   'View All',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 180.h,
//           child: ListView.builder(
//             padding: EdgeInsets.symmetric(horizontal: 18.w),
//             scrollDirection: Axis.horizontal,
//             itemCount: _announcements.length,
//             itemBuilder: (context, index) {
//               final int count = _announcements.length;
//               final Animation<double> animation =
//                   Tween<double>(begin: 0.0, end: 1.0).animate(
//                     CurvedAnimation(
//                       parent: _animationController,
//                       curve: Interval(
//                         (1 / count) * index,
//                         1.0,
//                         curve: Curves.fastOutSlowIn,
//                       ),
//                     ),
//                   );

//               final announcement = _announcements[index];
//               return AnimatedBuilder(
//                 animation: animation,
//                 builder: (BuildContext context, Widget? child) {
//                   return Opacity(
//                     opacity: animation.value,
//                     child: Transform(
//                       transform: Matrix4.translationValues(
//                         0.0,
//                         50 * (1.0 - animation.value),
//                         0.0,
//                       ),
//                       child: Container(
//                         width: 250.w,
//                         margin: EdgeInsets.only(right: 15.w),
//                         child: Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16.r),
//                           ),
//                           elevation: 3,
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(16.r),
//                             child: Stack(
//                               children: [
//                                 CachedNetworkImage(
//                                   imageUrl: announcement['image'],
//                                   fit: BoxFit.cover,
//                                   width: double.infinity,
//                                   height: double.infinity,
//                                 ),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                       colors: [
//                                         Colors.transparent,
//                                         Theme.of(context).brightness ==
//                                                 Brightness.dark
//                                             ? Colors.black.withValues(
//                                                 alpha: 0.7,
//                                               )
//                                             : Colors.black.withValues(
//                                                 alpha: 0.5,
//                                               ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 15.h,
//                                   left: 15.w,
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 10.w,
//                                       vertical: 5.h,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: announcement['tagColor'],
//                                       borderRadius: BorderRadius.circular(20.r),
//                                     ),
//                                     child: Text(
//                                       announcement['tag'],
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12.sp,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   bottom: 15.h,
//                                   left: 15.w,
//                                   right: 15.w,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         announcement['title'],
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16.sp,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       SizedBox(height: 5.h),
//                                       Text(
//                                         announcement['date'],
//                                         style: TextStyle(
//                                           color: Colors.white.withValues(
//                                             alpha: 0.8,
//                                           ),
//                                           fontSize: 12.sp,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget getQuickActionsSection() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quick Actions',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(context).textTheme.titleLarge?.color,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               // Calculate optimal cross axis count based on screen width
//               final double itemWidth = 80.w; // Base width for each item
//               final int crossAxisCount = (constraints.maxWidth / itemWidth)
//                   .floor()
//                   .clamp(3, 5);

//               return GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: 15.w,
//                   mainAxisSpacing: 15.h,
//                   childAspectRatio: 0.9,
//                 ),
//                 itemCount: _quickActions.length,
//                 itemBuilder: (context, index) {
//                   final int count = _quickActions.length;
//                   final Animation<double> animation =
//                       Tween<double>(begin: 0.0, end: 1.0).animate(
//                         CurvedAnimation(
//                           parent: _animationController,
//                           curve: Interval(
//                             (1 / count) * index,
//                             1.0,
//                             curve: Curves.fastOutSlowIn,
//                           ),
//                         ),
//                       );

//                   final action = _quickActions[index];
//                   return AnimatedBuilder(
//                     animation: animation,
//                     builder: (BuildContext context, Widget? child) {
//                       return Opacity(
//                         opacity: animation.value,
//                         child: Transform(
//                           transform: Matrix4.translationValues(
//                             0.0,
//                             30 * (1.0 - animation.value),
//                             0.0,
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               // Navigate within the ResidentMainScreen instead of pushing new screens
//                               switch (action['screen']) {
//                                 case 'visitors':
//                                   // We need to access the parent ResidentMainScreen to change tabs
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/resident-main/visitors',
//                                   );
//                                   break;
//                                 case 'services':
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/resident-main/services',
//                                   );
//                                   break;
//                                 case 'bills':
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/resident-main/bills',
//                                   );
//                                   break;
//                                 case 'amenities':
//                                   Navigator.pushNamed(context, '/amenities');
//                                   break;
//                                 case 'community':
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/resident-main/community',
//                                   );
//                                   break;
//                                 case 'announcements':
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/announcements',
//                                   );
//                                   break;
//                                 case 'profile':
//                                   Navigator.pushNamed(context, '/profile');
//                                   break;
//                               }
//                             },
//                             child: Column(
//                               children: [
//                                 Container(
//                                   padding: EdgeInsets.all(15.w),
//                                   decoration: BoxDecoration(
//                                     color: action['color'].withValues(
//                                       alpha:
//                                           Theme.of(context).brightness ==
//                                               Brightness.dark
//                                           ? 0.2
//                                           : 0.1,
//                                     ),
//                                     borderRadius: BorderRadius.circular(16.r),
//                                   ),
//                                   child: Icon(
//                                     action['icon'],
//                                     color: action['color'],
//                                     size: 24.sp,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8.h),
//                                 Text(
//                                   action['label'],
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.w500,
//                                     color: Theme.of(
//                                       context,
//                                     ).textTheme.bodyMedium?.color,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget getUpcomingEventsSection() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Upcoming Events',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).textTheme.titleLarge?.color,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/announcements');
//                 },
//                 child: Text(
//                   'View All',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: _upcomingEvents.length,
//             itemBuilder: (context, index) {
//               final int count = _upcomingEvents.length;
//               final Animation<double> animation =
//                   Tween<double>(begin: 0.0, end: 1.0).animate(
//                     CurvedAnimation(
//                       parent: _animationController,
//                       curve: Interval(
//                         (1 / count) * index,
//                         1.0,
//                         curve: Curves.fastOutSlowIn,
//                       ),
//                     ),
//                   );

//               final event = _upcomingEvents[index];
//               return AnimatedBuilder(
//                 animation: animation,
//                 builder: (BuildContext context, Widget? child) {
//                   return Opacity(
//                     opacity: animation.value,
//                     child: Transform(
//                       transform: Matrix4.translationValues(
//                         0.0,
//                         30 * (1.0 - animation.value),
//                         0.0,
//                       ),
//                       child: Card(
//                         margin: EdgeInsets.only(bottom: 15.h),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16.r),
//                         ),
//                         child: Row(
//                           children: [
//                             SizedBox(width: 15.w),
//                             ClipRRect(
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(16.r),
//                                 bottomLeft: Radius.circular(16.r),
//                               ),
//                               child: CachedNetworkImage(
//                                 imageUrl: event['image'],
//                                 width: 100.w,
//                                 height: 100.h,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             Expanded(
//                               child: Padding(
//                                 padding: EdgeInsets.all(15.w),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       event['title'],
//                                       style: TextStyle(
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.bold,
//                                         color: Theme.of(
//                                           context,
//                                         ).textTheme.titleMedium?.color,
//                                       ),
//                                     ),
//                                     SizedBox(height: 5.h),
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.calendar_today,
//                                           size: 14.sp,
//                                           color: Theme.of(
//                                             context,
//                                           ).textTheme.bodySmall?.color,
//                                         ),
//                                         SizedBox(width: 5.w),
//                                         Text(
//                                           event['date'],
//                                           style: TextStyle(
//                                             fontSize: 12.sp,
//                                             color: Theme.of(
//                                               context,
//                                             ).textTheme.bodySmall?.color,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 10.h),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             CircleAvatar(
//                                               radius: 10.r,
//                                               backgroundColor:
//                                                   Theme.of(
//                                                         context,
//                                                       ).brightness ==
//                                                       Brightness.dark
//                                                   ? Colors.grey[600]
//                                                   : Colors.grey[300],
//                                             ),
//                                             SizedBox(width: 3.w),
//                                             CircleAvatar(
//                                               radius: 10.r,
//                                               backgroundColor:
//                                                   Theme.of(
//                                                         context,
//                                                       ).brightness ==
//                                                       Brightness.dark
//                                                   ? Colors.grey[600]
//                                                   : Colors.grey[300],
//                                             ),
//                                             SizedBox(width: 3.w),
//                                             CircleAvatar(
//                                               radius: 10.r,
//                                               backgroundColor:
//                                                   Theme.of(
//                                                         context,
//                                                       ).brightness ==
//                                                       Brightness.dark
//                                                   ? Colors.grey[600]
//                                                   : Colors.grey[300],
//                                             ),
//                                             SizedBox(width: 5.w),
//                                             Container(
//                                               padding: EdgeInsets.all(3.w),
//                                               decoration: BoxDecoration(
//                                                 color: Theme.of(
//                                                   context,
//                                                 ).primaryColor,
//                                                 borderRadius:
//                                                     BorderRadius.circular(10.r),
//                                               ),
//                                               child: Text(
//                                                 '+${event['attendees']}',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 10.sp,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         OutlinedButton(
//                                           onPressed: () {},
//                                           style: OutlinedButton.styleFrom(
//                                             side: BorderSide(
//                                               color: Theme.of(
//                                                 context,
//                                               ).primaryColor,
//                                             ),
//                                           ),
//                                           child: Text(
//                                             'RSVP',
//                                             style: TextStyle(
//                                               fontSize: 12.sp,
//                                               color: Theme.of(
//                                                 context,
//                                               ).primaryColor,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget eventsGridWidget() {
//     final theme = Theme.of(context);

//     final List<Map<String, dynamic>> events = [
//       {
//         "id": 1,
//         "title": "New Year Party",
//         "date": DateTime(2025, 12, 31, 20, 0),
//         "location": "Clubhouse",
//         "image": "https://images.unsplash.com/photo-1721308303481-1b72cdd51912",
//         "semanticLabel":
//             "Colorful party scene with confetti and balloons in a decorated venue",
//         "attendees": 45,
//         "rsvpStatus": "going",
//       },
//       {
//         "id": 2,
//         "title": "Yoga Session",
//         "date": DateTime(2026, 1, 5, 7, 0),
//         "location": "Garden Area",
//         "image": "https://images.unsplash.com/photo-1594298332319-c04674dbbe3c",
//         "semanticLabel":
//             "Group of people practicing yoga on mats in a peaceful outdoor setting",
//         "attendees": 20,
//         "rsvpStatus": null,
//       },
//       {
//         "id": 3,
//         "title": "Kids Workshop",
//         "date": DateTime(2026, 1, 8, 16, 0),
//         "location": "Activity Room",
//         "image":
//             "https://img.rocket.new/generatedImages/rocket_gen_img_16b6d770b-1764670232758.png",
//         "semanticLabel":
//             "Children engaged in creative activities at colorful workshop tables",
//         "attendees": 15,
//         "rsvpStatus": "interested",
//       },
//     ];

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Upcoming Events',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   HapticFeedback.lightImpact();
//                   Navigator.pushNamed(context, '/events-and-community-screen');
//                 },
//                 child: Text(
//                   'View All',
//                   style: theme.textTheme.labelLarge?.copyWith(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h), // Increased spacing after title
//           SizedBox(
//             height: 180.h,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               // padding: EdgeInsets.symmetric(horizontal: 8.w),
//               itemCount: events.length,
//               itemBuilder: (context, index) {
//                 return _buildEventCard(context, events[index]);
//               },
//             ),
//           ),
//           SizedBox(height: 40.h), // Increased spacing after events list
//         ],
//       ),
//     );
//   }

//   Widget _buildEventCard(BuildContext context, Map<String, dynamic> event) {
//     final theme = Theme.of(context);
//     final rsvpStatus = event["rsvpStatus"] as String?;

//     return Container(
//       width: 200.w,
//       // height: 160.h,
//       margin: EdgeInsets.only(right: 16.w),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.shadow.withValues(alpha: 0.08),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             HapticFeedback.lightImpact();
//             Navigator.pushNamed(context, '/events-and-community-screen');
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Event image
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(16),
//                     ),
//                     child: Image.network(
//                       event["image"] as String,
//                       width: 200.w,
//                       height: 100.h,
//                       fit: BoxFit.cover,
//                       semanticLabel: event["semanticLabel"] as String,
//                     ),
//                   ),
//                   if (rsvpStatus != null)
//                     Positioned(
//                       top: 4.w,
//                       right: 4.w,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 6.w,
//                           vertical: 3.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _getRsvpColor(rsvpStatus, theme),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               _getRsvpIcon(rsvpStatus),
//                               color: Colors.white,
//                               size: 14,
//                             ),
//                             SizedBox(width: 1.w),
//                             Text(
//                               _getRsvpLabel(rsvpStatus),
//                               style: theme.textTheme.labelSmall?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               // Event details
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.all(3.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         event["title"] as String,
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       SizedBox(height: 1.h),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             color: theme.colorScheme.onSurfaceVariant,
//                             size: 14,
//                           ),
//                           SizedBox(width: 1.w),
//                           Expanded(
//                             child: Text(
//                               _formatEventDate(event["date"] as DateTime),
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurfaceVariant,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 0.9.h),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             color: theme.colorScheme.onSurfaceVariant,
//                             size: 14,
//                           ),
//                           SizedBox(width: 1.w),
//                           Expanded(
//                             child: Text(
//                               event["location"] as String,
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurfaceVariant,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.people,
//                             color: theme.colorScheme.primary,
//                             size: 16,
//                           ),
//                           SizedBox(width: 1.w),
//                           Text(
//                             '${event["attendees"] as int? ?? 0} attending',
//                             style: theme.textTheme.labelSmall?.copyWith(
//                               color: theme.colorScheme.primary,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatEventDate(DateTime date) {
//     final months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${date.day} ${months[date.month - 1]}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   Color _getRsvpColor(String status, ThemeData theme) {
//     switch (status) {
//       case 'going':
//         return theme.colorScheme.primary;
//       case 'interested':
//         return theme.colorScheme.secondary;
//       default:
//         return theme.colorScheme.onSurfaceVariant;
//     }
//   }

//   IconData _getRsvpIcon(String status) {
//     switch (status) {
//       case 'going':
//         return Icons.check_circle;
//       case 'interested':
//         return Icons.star;
//       default:
//         return Icons.help;
//     }
//   }

//   String _getRsvpLabel(String status) {
//     switch (status) {
//       case 'going':
//         return 'Going';
//       case 'interested':
//         return 'Interested';
//       default:
//         return 'Maybe';
//     }
//   }

//   Widget statsCarouselWidget() {
//     final List<Map<String, dynamic>> statsData = [
//       {
//         "type": "maintenance",
//         "title": "Maintenance Due",
//         "amount": "₹ 8,500",
//         "dueDate": "Due by 31 Dec 2025",
//         "icon": Icons.account_balance_wallet,
//         "color": const Color(0xFF7C7296),
//         "action": "Pay Now",
//       },
//       {
//         "type": "visitors",
//         "title": "Visitor Requests",
//         "count": 2,
//         "subtitle": "Pending approval",
//         "icon": Icons.people,
//         "color": const Color(0xFFC9A74D),
//         "action": "Review",
//       },
//       {
//         "type": "complaints",
//         "title": "Active Complaints",
//         "count": 1,
//         "subtitle": "In progress",
//         "icon": Icons.report_problem,
//         "color": const Color.fromARGB(255, 178, 59, 59),
//         "action": "Track",
//       },
//     ];

//     int currentPage = 0;

//     void handleStatAction(BuildContext context, String type) {
//       switch (type) {
//         case 'maintenance':
//           Navigator.pushNamed(context, '/payments-screen');
//           break;
//         case 'visitors':
//           Navigator.pushNamed(context, '/visitor-management-screen');
//           break;
//         case 'complaints':
//           Navigator.pushNamed(context, '/complaints-management-screen');
//           break;
//       }
//     }

//     Widget buildStatCard(BuildContext context, Map<String, dynamic> stat) {
//       final theme = Theme.of(context);
//       final cardColor = stat['color'] as Color;
//       final icon = stat['icon'] as IconData;

//       return Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [cardColor, cardColor.withOpacity(0.8)],
//           ),
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: cardColor.withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16.r),
//           onTap: () {
//             HapticFeedback.lightImpact();
//             handleStatAction(context, stat['type'] as String);
//           },
//           child: Padding(
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8.w),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       child: Icon(icon, color: Colors.white, size: 28.sp),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20.r),
//                       ),
//                       child: Text(
//                         stat['action'] as String,
//                         style: theme.textTheme.labelMedium?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       stat['title'] as String,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: Colors.white.withOpacity(0.9),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     if (stat['amount'] != null)
//                       Text(
//                         stat['amount'] as String,
//                         style: theme.textTheme.headlineMedium?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     else
//                       Row(
//                         children: [
//                           Text(
//                             '${stat['count']}',
//                             style: theme.textTheme.headlineMedium?.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           Text(
//                             stat['subtitle'] as String,
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               color: Colors.white.withOpacity(0.8),
//                             ),
//                           ),
//                         ],
//                       ),
//                     if (stat['dueDate'] != null) ...[
//                       SizedBox(height: 4.h),
//                       Text(
//                         stat['dueDate'] as String,
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: Colors.white.withOpacity(0.8),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Column(
//           children: [
//             CarouselSlider.builder(
//               itemCount: statsData.length,
//               itemBuilder: (context, index, realIndex) {
//                 return buildStatCard(context, statsData[index]);
//               },
//               options: CarouselOptions(
//                 height: 180.h,
//                 viewportFraction: 0.88,
//                 enlargeCenterPage: true,
//                 autoPlay: true,
//                 autoPlayInterval: const Duration(seconds: 5),
//                 autoPlayCurve: Curves.easeInOut,
//                 onPageChanged: (index, _) {
//                   setState(() => currentPage = index);
//                   HapticFeedback.selectionClick();
//                 },
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(statsData.length, (index) {
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: EdgeInsets.symmetric(horizontal: 4.w),
//                   width: currentPage == index ? 24.w : 8.w,
//                   height: 8.h,
//                   decoration: BoxDecoration(
//                     color: currentPage == index
//                         ? Theme.of(context).colorScheme.primary
//                         : Theme.of(
//                             context,
//                           ).colorScheme.outline.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(4.r),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
