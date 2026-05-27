import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/communications/communications_bloc.dart';
import 'package:mygate_coepd/models/announcement.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});
  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  String _selectedCategory = 'All';
  int _expandedId = -1;

  final List<String> _categories = [
    'All',
    'Important',
    'Event',
    'Amenity',
    'Maintenance',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animCtrl.forward();
      context.read<CommunicationsBloc>().add(
        const LoadAnnouncements(isDraft: false),
      );
    });
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context.read<CommunicationsBloc>().add(const LoadPolls(isActive: true));
      } else {
        context.read<CommunicationsBloc>().add(
          const LoadAnnouncements(isDraft: false),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Color _tagColor(String? sendVia) {
    switch (sendVia) {
      case 'sms':
        return Colors.orange;
      case 'email':
        return Colors.blue;
      case 'whatsapp':
        return Colors.green;
      default:
        return const Color(0xFF006D77);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements', style: TextStyle(fontSize: 18.sp)),
        bottom: TabBar(
          controller: _tabController,
          // labelColor: theme.colorScheme.onSurface,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white,
          labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Announcements'),
            Tab(text: 'Polls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAnnouncementsTab(), _buildPollsTab()],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return BlocBuilder<CommunicationsBloc, CommunicationsState>(
      builder: (ctx, state) {
        if (state is CommunicationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CommunicationsError) {
          return _errorWidget(
            state.message,
            () => ctx.read<CommunicationsBloc>().add(const LoadAnnouncements()),
          );
        }
        if (state is AnnouncementsLoaded) {
          final items = _selectedCategory == 'All'
              ? state.announcements
              : state.announcements
                    .where((a) => a.sendVia == _selectedCategory.toLowerCase())
                    .toList();
          return Column(
            children: [
              SizedBox(height: 12.h),
              // Category chips
              SizedBox(
                height: 44.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: _categories.map((c) {
                    final sel = _selectedCategory == c;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = c),
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        decoration: BoxDecoration(
                          color: sel
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            c,
                            style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: items.isEmpty
                    ? _emptyWidget(
                        'No Announcements',
                        'No announcements in this category.',
                      )
                    : RefreshIndicator(
                        onRefresh: () async => ctx
                            .read<CommunicationsBloc>()
                            .add(const LoadAnnouncements(isDraft: false)),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _announcementCard(items[i]),
                        ),
                      ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _announcementCard(Announcement a) {
    final expanded = _expandedId == int.tryParse(a.id);
    final tColor = _tagColor(a.sendVia);
    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => setState(
          () => _expandedId = expanded ? -1 : int.tryParse(a.id) ?? -1,
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      a.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: tColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      a.sendVia.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(Icons.access_time, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    a.createdAt ?? '',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  if (a.createdByName != null) ...[
                    SizedBox(width: 10.w),
                    Icon(Icons.person, size: 13.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      a.createdByName!,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              if (expanded) ...[
                SizedBox(height: 10.h),
                Text(
                  a.content,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                if (a.targetGroupName != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.group, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 5.w),
                      Text(
                        'Target: ${a.targetGroupName}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollsTab() {
    return BlocBuilder<CommunicationsBloc, CommunicationsState>(
      builder: (ctx, state) {
        if (state is CommunicationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CommunicationsError) {
          return _errorWidget(
            state.message,
            () => ctx.read<CommunicationsBloc>().add(
              const LoadPolls(isActive: true),
            ),
          );
        }
        if (state is VoteCast) {
          // Reload polls after vote
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => ctx.read<CommunicationsBloc>().add(
              const LoadPolls(isActive: true),
            ),
          );
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PollsLoaded) {
          if (state.polls.isEmpty) {
            return _emptyWidget(
              'No Active Polls',
              'No polls are currently active.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ctx.read<CommunicationsBloc>().add(
              const LoadPolls(isActive: true),
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.polls.length,
              itemBuilder: (_, i) => _pollCard(ctx, state.polls[i]),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _pollCard(BuildContext ctx, Poll p) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.question,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (p.hasVoted)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Voted',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.schedule, size: 13.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  'Ends: ${p.endsAt}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                SizedBox(width: 10.w),
                Text(
                  '${p.totalVotes} votes',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ...p.options.map((opt) {
              final pct = p.totalVotes > 0 ? opt.voteCount / p.totalVotes : 0.0;
              return GestureDetector(
                onTap: p.hasVoted
                    ? null
                    : () => ctx.read<CommunicationsBloc>().add(
                        VoteOnPoll(p.id, opt.id),
                      ),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt.optionText,
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ),
                          if (p.hasVoted)
                            Text(
                              '${(pct * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                        ],
                      ),
                      if (p.hasVoted) ...[
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6.h,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(String msg, VoidCallback retry) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56.sp, color: Colors.red),
          SizedBox(height: 14.h),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 18.h),
          ElevatedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  Widget _emptyWidget(String t, String s) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Icon(
            Icons.notifications_none,
            size: 48.sp,
            color: const Color(0xFF006D77),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          t,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          s,
          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
