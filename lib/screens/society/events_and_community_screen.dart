import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/repositories/community_repository.dart';
import 'package:mygate_coepd/screens/society/event_details_screen.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/blocs/community/community_bloc.dart';
import 'package:mygate_coepd/blocs/events/events_bloc.dart';
import 'package:mygate_coepd/blocs/communications/communications_bloc.dart';
import 'package:mygate_coepd/models/announcement.dart';
import 'package:mygate_coepd/models/community_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class EventsAndCommunityScreen extends StatefulWidget {
  const EventsAndCommunityScreen({super.key});

  @override
  State<EventsAndCommunityScreen> createState() =>
      _EventsAndCommunityScreenState();
}

class _EventsAndCommunityScreenState extends State<EventsAndCommunityScreen>
    with SingleTickerProviderStateMixin {
  int _selectedSegment = 0; // Community Feed selected by default
  late TabController _tabController;
  final ScrollController _eventsScrollController = ScrollController();
  final ScrollController _feedScrollController = ScrollController();
  final ScrollController _pollsScrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    _feedScrollController.addListener(_handleScroll);

    // Load dynamic community data
    context.read<CommunityBloc>().add(LoadCommunityData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _eventsScrollController.dispose();
    _feedScrollController.dispose();
    _pollsScrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_feedScrollController.hasClients) return;
    if (_feedScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) setState(() => _showFab = false);
    } else if (_feedScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) setState(() => _showFab = true);
    }
  }

  void _handleTabSelection() {
    if (_selectedSegment != _tabController.index) {
      setState(() => _selectedSegment = _tabController.index);
    }
  }

  void _handleSegmentTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedSegment = index);
    _tabController.animateTo(index);
  }

  void _showCreatePostSheet() {
    HapticFeedback.mediumImpact();
    final communityBloc = context.read<CommunityBloc>();
    final commsBloc = context.read<CommunicationsBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: communityBloc),
          BlocProvider.value(value: commsBloc),
        ],
        child: const CreatePostBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Community Management'),
        backgroundColor: theme.scaffoldBackgroundColor,
        // foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSegmentedControl(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                EventsSectionWidget(scrollController: _eventsScrollController),
                CommunityFeedSectionWidget(
                  scrollController: _feedScrollController,
                ),
                PollsSectionWidget(scrollController: _pollsScrollController),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedSegment == 1 && _showFab
          ? _buildFloatingActionButton(theme)
          : null,
    );
  }

  Widget _buildSegmentedControl(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildSegmentButton(0, 'Events', theme),
          _buildSegmentButton(1, 'Feed', theme),
          _buildSegmentButton(2, 'Polls', theme),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(int index, String label, ThemeData theme) {
    final isSelected = _selectedSegment == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleSegmentTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            spacing: 6.w,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                index == 0
                    ? Icons.event
                    : index == 1
                    ? Icons.feed
                    : Icons.poll,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (0.1 * (0.5 - (value - 0.5).abs())),
          child: FloatingActionButton.extended(
            onPressed: _showCreatePostSheet,
            backgroundColor: theme.colorScheme.primary,
            elevation: 4,
            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 24),
            label: Text(
              'Create Post',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Events section displaying upcoming activities with RSVP functionality
class EventsSectionWidget extends StatefulWidget {
  final ScrollController scrollController;

  const EventsSectionWidget({super.key, required this.scrollController});

  @override
  State<EventsSectionWidget> createState() => _EventsSectionWidgetState();
}

class _EventsSectionWidgetState extends State<EventsSectionWidget> {
  void _handleShare(Map<String, dynamic> event) {
    HapticFeedback.mediumImpact();
    // ignore: deprecated_member_use
    Share.share(
      'Join me at ${event["title"] ?? "this event"} on ${event["event_date"] ?? "upcoming date"} at ${event["event_time"] ?? ""}. Location: ${event["location"] ?? "TBA"}',
      subject: event["title"] ?? "Event",
    );
  }

  void _handleGetDirections(Map<String, dynamic> event) {
    HapticFeedback.lightImpact();
    AppSnackbar.show(
      context: context,
      message:
          'Opening directions to ${event["location"] ?? "Unknown location"}',
      type: SnackBarType.info,
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: 4,
            itemBuilder: (_, _) => buildEventCardShimmer(theme),
          );
        }
        if (state is EventsError) {
          return Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 100.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72.sp,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),

                SizedBox(height: 20.h),

                Text(
                  "Unable to Load Community Events",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  "Something went wrong while fetching the latest community events.\nPlease try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24.h),

                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<EventsBloc>().add(LoadEvents());
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is EventsLoaded) {
          final events = state.events;
          if (events.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<EventsBloc>().add(LoadEvents());
                await Future.delayed(const Duration(seconds: 1));
                HapticFeedback.lightImpact();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(child: Text("No events found.")),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<EventsBloc>().add(LoadEvents());
              await Future.delayed(const Duration(seconds: 1));
              HapticFeedback.lightImpact();
            },
            child: ListView.builder(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildEventCard(event, theme, context);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEventCard(
    Map<String, dynamic> event,
    ThemeData theme,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => _showEventDetails(event),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventImage(event, theme),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                spacing: 6.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventHeader(event, theme),
                  _buildEventDetails(event, theme),
                  _buildEventFooter(event, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(Map<String, dynamic> event, ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            event["cover_image"]?.isNotEmpty == true
                ? event["cover_image"]
                : 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678',
            width: double.infinity,
            height: 140.h,
            fit: BoxFit.cover,
            semanticLabel: event["semanticLabel"],
          ),
        ),
        Positioned(
          top: 10.w,
          right: 10.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              event["category"] ?? "General",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventHeader(Map<String, dynamic> event, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            event["title"] ?? "Untitled Event",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDetails(Map<String, dynamic> event, ThemeData theme) {
    return Column(
      spacing: 6.h,
      children: [
        _buildDetailRow(
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          '${event["event_date"] ?? ""} • ${event["event_time"] ?? ""}',
          theme,
        ),
        _buildDetailRow(
          Icon(
            Icons.location_on,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          event["location"] ?? "TBA",
          theme,
        ),
      ],
    );
  }

  Widget _buildDetailRow(Widget icon, String text, ThemeData theme) {
    return Row(
      children: [
        icon,
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEventFooter(Map<String, dynamic> event, ThemeData theme) {
    return Row(
      spacing: 10.w,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.network(
            event["organizerAvatar"] ??
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(event["organizer"] ?? "Admin")}&background=random',
            width: 32.w,
            height: 32.w,
            fit: BoxFit.cover,
            semanticLabel: event["organizerAvatarLabel"],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event["organizer"] ?? "Society Admin",
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${event["attendees"] ?? 0} attending',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.directions,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => _handleGetDirections(event),
          tooltip: 'Get Directions',
        ),
      ],
    );
  }

  Widget buildEventCardShimmer(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Event Image
          Stack(
            children: [
              _shimmerBox(width: double.infinity, height: 140.h, radius: 16.r),

              Positioned(
                top: 12.h,
                right: 12.w,
                child: _shimmerBox(width: 70.w, height: 24.h, radius: 20.r),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                _shimmerBox(width: 180.w, height: 16.h),

                SizedBox(height: 14.h),

                /// Date Time
                Row(
                  children: [
                    _shimmerBox(width: 16.w, height: 16.w, radius: 8.r),
                    SizedBox(width: 8.w),
                    _shimmerBox(width: 180.w, height: 12.h),
                  ],
                ),

                SizedBox(height: 10.h),

                /// Location
                Row(
                  children: [
                    _shimmerBox(width: 16.w, height: 16.w, radius: 8.r),
                    SizedBox(width: 8.w),
                    _shimmerBox(width: 140.w, height: 12.h),
                  ],
                ),

                SizedBox(height: 16.h),

                /// Footer
                Row(
                  children: [
                    _shimmerBox(width: 32.w, height: 32.w, radius: 16.r),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBox(width: 100.w, height: 12.h),

                          SizedBox(height: 6.h),

                          _shimmerBox(width: 70.w, height: 10.h),
                        ],
                      ),
                    ),

                    _shimmerBox(width: 36.w, height: 36.w, radius: 18.r),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Community feed section with resident posts and social interactions
class CommunityFeedSectionWidget extends StatefulWidget {
  final ScrollController scrollController;

  const CommunityFeedSectionWidget({super.key, required this.scrollController});

  @override
  State<CommunityFeedSectionWidget> createState() =>
      _CommunityFeedSectionWidgetState();
}

class _CommunityFeedSectionWidgetState
    extends State<CommunityFeedSectionWidget> {
  void _handleLike(int postId) {
    HapticFeedback.lightImpact();
    context.read<CommunityBloc>().add(LikeCommunityPost(postId));
  }

  void _handleComment(int postId) {
    HapticFeedback.mediumImpact();
    final communityBloc = context.read<CommunityBloc>();
    final communityRepo = context.read<CommunityRepository>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: communityBloc),
          RepositoryProvider.value(value: communityRepo),
        ],
        child: _CommentsBottomSheet(postId: postId),
      ),
    );
  }

  void _handleShare(CommunityPost post) {
    HapticFeedback.mediumImpact();
    // ignore: deprecated_member_use
    Share.share('${post.userName}: ${post.content}', subject: 'Community Post');
  }

  void _handleReport(int postId) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Post', style: theme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to report this post for violating community guidelines?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppSnackbar.show(
                context: context,
                message: 'Post reported. Our team will review it.',
                type: SnackBarType.info,
              );
            },
            child: Text(
              'Report',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(int postId) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post', style: theme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to delete this post?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CommunityBloc>().add(DeleteCommunityPost(postId));
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 3,
            itemBuilder: (_, _) => buildCommunityPostShimmer(theme),
          );
        } else if (state is CommunityError) {
          return Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 100.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72.sp,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),

                SizedBox(height: 20.h),

                Text(
                  "Unable to Load Community Feed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  "Something went wrong while fetching the latest community updates.\nPlease try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24.h),

                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CommunityBloc>().add(LoadCommunityData());
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (state is CommunityLoaded) {
          final posts = state.posts;

          final authState = context.read<AuthBloc>().state;
          final currentUserId = (authState is Authenticated)
              ? int.tryParse(authState.user.id)
              : null;

          if (posts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CommunityBloc>().add(LoadCommunityData());
                await Future.delayed(const Duration(seconds: 1));
                HapticFeedback.lightImpact();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Text(
                        'No community posts yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CommunityBloc>().add(LoadCommunityData());
              await Future.delayed(const Duration(seconds: 1));
              HapticFeedback.lightImpact();
            },
            child: ListView.builder(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _buildPostCard(post, currentUserId, theme);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildPostCard(
    CommunityPost post,
    int? currentUserId,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post, currentUserId, theme),
          _buildPostContent(post, theme),
          if (post.image != null && post.image!.isNotEmpty)
            _buildPostImages(post, theme),
          _buildPostActions(post, theme),
        ],
      ),
    );
  }

  Widget _buildPostHeader(
    CommunityPost post,
    int? currentUserId,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(color: theme.primaryColor, width: 1.w),
          ),
          child: CircleAvatar(
            radius: 18.r,
            backgroundImage: post.userAvatar != null
                ? CachedNetworkImageProvider(post.userAvatar!)
                : null,
            child: post.userAvatar == null ? const Icon(Icons.person) : null,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'Post',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.3.h),
              Text(
                post.time.split(' ').first,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'report') {
              _handleReport(post.id);
            } else if (value == 'delete') {
              _handleDelete(post.id);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          itemBuilder: (context) => [
            if (currentUserId == post.userId)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Delete Post', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            if (currentUserId != post.userId)
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: theme.colorScheme.error, size: 20),
                    SizedBox(width: 3.w),
                    Text('Report Post', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
          ],
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(CommunityPost post, ThemeData theme) {
    return Text(
      post.content,
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
    );
  }

  Widget _buildPostImages(CommunityPost post, ThemeData theme) {
    return SizedBox(
      height: 130.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r.r),
        child: CachedNetworkImage(
          imageUrl: post.image!,
          width: double.infinity,
          height: 130.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPostActions(CommunityPost post, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          _buildActionButton(
            Icon(
              post.hasLiked ? Icons.favorite : Icons.favorite_border_outlined,
              color: post.hasLiked
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            '${post.likesCount}',
            () => _handleLike(post.id),
            theme,
          ),
          SizedBox(width: 4.w),
          _buildActionButton(
            Icon(
              Icons.comment,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            '${post.commentsCount}',
            () => _handleComment(post.id),
            theme,
          ),
          SizedBox(width: 4.w),
          _buildActionButton(
            Icon(
              Icons.share,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            '0',
            () => _handleShare(post),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    Widget icon,
    String count,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Row(
          children: [
            icon,
            SizedBox(width: 1.w),
            Text(
              count,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCommunityPostShimmer(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              _shimmerBox(width: 36.w, height: 36.w, radius: 18.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 120.w, height: 12.h),
                    SizedBox(height: 8.h),
                    _shimmerBox(width: 70.w, height: 10.h),
                  ],
                ),
              ),
              _shimmerBox(width: 20.w, height: 20.w, radius: 10.r),
            ],
          ),

          SizedBox(height: 14.h),

          /// Content
          _shimmerBox(width: double.infinity, height: 12.h),

          SizedBox(height: 8.h),

          _shimmerBox(width: 250.w, height: 12.h),

          SizedBox(height: 14.h),

          /// Image Placeholder
          _shimmerBox(width: double.infinity, height: 130.h, radius: 12.r),

          SizedBox(height: 14.h),

          /// Actions
          Row(
            children: [
              _actionShimmer(),
              SizedBox(width: 20.w),
              _actionShimmer(),
              SizedBox(width: 20.w),
              _actionShimmer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionShimmer() {
    return Row(
      children: [
        _shimmerBox(width: 18.w, height: 18.w, radius: 9.r),
        SizedBox(width: 6.w),
        _shimmerBox(width: 20.w, height: 10.h),
      ],
    );
  }
}

/// Comments bottom sheet
class _CommentsBottomSheet extends StatefulWidget {
  final int postId;

  const _CommentsBottomSheet({required this.postId});

  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _hasText = false;

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(() {
      final hasText = _commentController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  Future<void> _loadComments() async {
    try {
      final repository = context.read<CommunityRepository>();
      final comments = await repository.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = List<Map<String, dynamic>>.from(comments);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _postComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();

    // Dispatch to BLoC to create post remotely
    context.read<CommunityBloc>().add(
      CommentOnCommunityPost(widget.postId, text),
    );

    // Optimistic UI update
    setState(() {
      _comments.add({
        "user_name": "You",
        "avatar_url": "https://ui-avatars.com/api/?name=You&background=random",
        "content": text,
        "created_at": DateTime.now().toIso8601String(),
        "unit": "N/A",
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final keyboardHeight = mq.viewInsets.bottom;
    final maxSheetHeight = mq.size.height * 0.94;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(theme),
                _buildHeader(theme),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                Flexible(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _comments.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildCommentsList(theme),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                _buildComposer(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Drag handle ────────────────────────────────────────────────────────

  Widget _buildDragHandle(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
      child: Container(
        width: 32.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  // ─── Header — text-led, count as quiet secondary info ──────────────────

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 12.w, 12.h),
      child: Row(
        children: [
          Text(
            'Comments',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(width: 8.w),
          if (_comments.isNotEmpty)
            Text(
              '${_comments.length}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20.sp,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ─── Empty state ─────────────────────────────────────────────────────────

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 32.sp,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            SizedBox(height: 12.h),
            Text(
              'No comments yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Be the first to share your thoughts',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Comments list — flat rows, hairline between each, no card chrome ──

  Widget _buildCommentsList(ThemeData theme) {
    // Helper to format time
    String formatTime(String? dateStr) {
      if (dateStr == null) return '';
      final date = DateTime.tryParse(dateStr);
      if (date == null) return '';
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${diff.inDays}d';
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
      itemCount: _comments.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
      ),
      itemBuilder: (context, index) {
        final comment = _comments[index];
        final author = comment["user_name"] ?? "Unknown";
        final avatar =
            comment["avatar_url"] ?? "https://ui-avatars.com/api/?name=Unknown";
        final text = comment["content"] ?? "";
        final time = formatTime(comment["created_at"]);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  avatar,
                  width: 30.w,
                  height: 30.w,
                  fit: BoxFit.cover,
                  semanticLabel: author,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 30.w,
                      height: 30.w,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          time,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5.sp,
                        height: 1.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Composer — borderless input, accent send affordance ───────────────

  Widget _buildComposer(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 8.h, 12.w, 8.h),
      child: Row(
        // spacing: 6.w,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxHeight: 100.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: TextField(
                controller: _commentController,
                focusNode: _commentFocusNode,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Write a comment…',
                  isCollapsed: true,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                    fontSize: 13.5.sp,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5.sp),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40.w,
            height: 40.w,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: _hasText
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_upward_rounded,
                color: _hasText
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                size: 20.sp,
              ),
              onPressed: _hasText ? _postComment : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for creating new posts with text, photos, and polls
class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

enum _PostMode { text, poll }

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];
  bool _isUploadingImages = false;
  String _privacySetting = 'public'; // public, residents_only
  _PostMode _mode = _PostMode.text;
  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _s3 = S3UploadService();

  bool get _isCreatingPoll => _mode == _PostMode.poll;

  @override
  void dispose() {
    _contentController.dispose();
    for (var controller in _pollOptions) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      if (images.isEmpty) return;

      HapticFeedback.lightImpact();

      final toAdd = images.take(4 - _selectedImages.length).toList();
      if (toAdd.isEmpty) return;

      setState(() {
        _selectedImages.addAll(toAdd);
        _isUploadingImages = true;
      });

      try {
        for (final img in toAdd) {
          final url = await _s3.uploadImage(
            File(img.path),
            folder: S3UploadService.folderCommunity,
          );
          _uploadedImageUrls.add(url);
        }
      } catch (e) {
        if (mounted) {
          _showSnack('Image upload failed', isError: true);
        }
      } finally {
        if (mounted) setState(() => _isUploadingImages = false);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _removeImage(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedImages.removeAt(index);
      if (index < _uploadedImageUrls.length) {
        _uploadedImageUrls.removeAt(index);
      }
    });
  }

  void _setMode(_PostMode mode) {
    if (mode == _mode) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mode = mode;
      if (mode == _PostMode.poll) {
        _selectedImages.clear();
        _uploadedImageUrls.clear();
      }
    });
  }

  void _addPollOption() {
    if (_pollOptions.length < 6) {
      HapticFeedback.lightImpact();
      setState(() => _pollOptions.add(TextEditingController()));
    }
  }

  void _removePollOption(int index) {
    if (_pollOptions.length > 2) {
      HapticFeedback.lightImpact();
      setState(() {
        _pollOptions[index].dispose();
        _pollOptions.removeAt(index);
      });
    }
  }

  void _createPost() {
    if (_contentController.text.trim().isEmpty) {
      _showSnack(
        _isCreatingPoll ? 'Write a poll question' : 'Write something to post',
      );
      return;
    }

    if (_isCreatingPoll) {
      final filled = _pollOptions.where((c) => c.text.trim().isNotEmpty).length;
      if (filled < 2) {
        _showSnack('Add at least 2 poll options');
        return;
      }
    }

    if (_isUploadingImages) {
      _showSnack('Images are still uploading');
      return;
    }

    HapticFeedback.mediumImpact();

    if (_isCreatingPoll) {
      final options = _pollOptions
          .map((e) => e.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      context.read<CommunicationsBloc>().add(
        CreatePoll(
          question: _contentController.text.trim(),
          options: options,
          endsAt: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          pollType: _privacySetting,
        ),
      );
    } else {
      context.read<CommunityBloc>().add(
        CreateCommunityPost(
          content: _contentController.text.trim(),
          image: _uploadedImageUrls.isNotEmpty
              ? _uploadedImageUrls.first
              : null,
        ),
      );
    }

    Navigator.pop(context);
    _showSnack(_isCreatingPoll ? 'Poll posted' : 'Post created');
  }

  void _showSnack(String message, {bool isError = false}) {
    AppSnackbar.show(
      context: context,
      message: message,
      type: isError ? SnackBarType.error : SnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final keyboardHeight = mq.viewInsets.bottom;
    final maxSheetHeight = mq.size.height * 0.94;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDragHandle(theme),
                _buildHeader(theme),
                _buildModeSwitch(theme),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIdentityRow(theme),
                        SizedBox(height: 18.h),
                        _buildContentInput(theme),
                        if (_isUploadingImages) ...[
                          SizedBox(height: 14.h),
                          _buildUploadingIndicator(theme),
                        ],
                        if (!_isCreatingPoll && _selectedImages.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _buildImagePreview(theme),
                        ],
                        if (_isCreatingPoll) ...[
                          SizedBox(height: 16.h),
                          _buildPollOptions(theme),
                        ],
                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                _buildFooterActions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Drag handle ────────────────────────────────────────────────────────

  Widget _buildDragHandle(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 4.h),
      child: Container(
        width: 32.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  // ─── Header — flat, text-led, no button chrome ─────────────────────────

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 12.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'New post',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                letterSpacing: -0.2,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              minimumSize: Size(0, 36.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
            ),
            child: Text('Cancel', style: TextStyle(fontSize: 15.sp)),
          ),
          SizedBox(width: 4.w),
          FilledButton(
            onPressed: _createPost,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              minimumSize: Size(0, 36.h),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Post',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Segmented mode switch — iOS-native style ──────────────────────────

  Widget _buildModeSwitch(ThemeData theme) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(16.w, 4.h, 16.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Post',
              icon: Icons.article_outlined,
              selected: _mode == _PostMode.text,
              onTap: () => _setMode(_PostMode.text),
              theme: theme,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Poll',
              icon: Icons.bar_chart_rounded,
              selected: _mode == _PostMode.poll,
              onTap: () => _setMode(_PostMode.poll),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Identity row — name + inline privacy pill ─────────────────────────

  Widget _buildIdentityRow(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person_outline,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'You',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: _buildPrivacyPill(theme)),
      ],
    );
  }

  Widget _buildPrivacyPill(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showPrivacyPicker(theme),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _privacySetting == 'public' ? Icons.public : Icons.people_outline,
              size: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                _privacySetting == 'public' ? 'Public' : 'Residents only',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.unfold_more_rounded,
              size: 12.sp,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Content input — borderless, large, airy ───────────────────────────

  Widget _buildContentInput(ThemeData theme) {
    return TextField(
      controller: _contentController,
      maxLines: _isCreatingPoll ? 3 : 8,
      minLines: 2,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: _isCreatingPoll ? 'Ask a question…' : "What's on your mind?",
        border: InputBorder.none,
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16.sp, height: 1.5),
    );
  }

  // ─── Uploading indicator — quiet text row, no boxed container ──────────

  Widget _buildUploadingIndicator(ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 14.w,
          height: 14.w,
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'Uploading images…',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  // ─── Image preview ───────────────────────────────────────────────────────

  Widget _buildImagePreview(ThemeData theme) {
    final imageHeight = 96.h;
    final isSingle = _selectedImages.length == 1;

    return SizedBox(
      height: imageHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final width = isSingle ? 180.w : 112.w;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Stack(
              children: [
                Container(
                  width: width,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: _uploadedImageUrls.length > index
                        ? Image.network(
                            _uploadedImageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImageErrorPlaceholder(theme);
                            },
                          )
                        : Image.file(
                            File(_selectedImages[index].path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImageErrorPlaceholder(theme);
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: 5.h,
                  right: 5.w,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                    ),
                  ),
                ),
                if (_uploadedImageUrls.length <= index)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageErrorPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
          size: 22.sp,
        ),
      ),
    );
  }

  // ─── Poll options — flat rows, hairline dividers, no boxed card ────────

  Widget _buildPollOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_pollOptions.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Container(
                  width: 26.w,
                  height: 26.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.6,
                      ),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _pollOptions[index],
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      isDense: true,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                ),
                if (_pollOptions.length > 2)
                  SizedBox(
                    width: 30.w,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        size: 16.sp,
                      ),
                      onPressed: () => _removePollOption(index),
                    ),
                  ),
              ],
            ),
          );
        }),
        if (_pollOptions.length < 6)
          GestureDetector(
            onTap: _addPollOption,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: theme.colorScheme.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Add option',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── Privacy picker — inline modal, consistent flat style ──────────────

  void _showPrivacyPicker(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Text(
                'Who can see this?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 12.h),
              _buildPrivacyOption(
                theme,
                'public',
                Icons.public,
                'Public',
                'Anyone can see this post',
              ),
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              _buildPrivacyOption(
                theme,
                'residents_only',
                Icons.people_outline,
                'Residents only',
                'Only residents of this society can see',
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyOption(
    ThemeData theme,
    String value,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = _privacySetting == value;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _privacySetting = value);
        Navigator.pop(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 19.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: theme.colorScheme.primary, size: 18.sp),
          ],
        ),
      ),
    );
  }

  // ─── Footer — single photo action only (poll handled by segment switch) ─

  Widget _buildFooterActions(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
      child: Row(
        children: [
          _FooterIconAction(
            icon: Icons.image_outlined,
            label: 'Photo',
            enabled: !_isCreatingPoll,
            onTap: _isCreatingPoll ? null : _pickImages,
            theme: theme,
          ),
          const Spacer(),
          if (!_isCreatingPoll && _selectedImages.isNotEmpty)
            Text(
              '${_selectedImages.length}/4',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ────────────────────────────────────────────────────

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        padding: EdgeInsets.all(16.w),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: selected
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterIconAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _FooterIconAction({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19.sp, color: color),
            SizedBox(width: 7.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Polls section with voting functionality and results visualization
class PollsSectionWidget extends StatefulWidget {
  final ScrollController scrollController;

  const PollsSectionWidget({super.key, required this.scrollController});

  @override
  State<PollsSectionWidget> createState() => _PollsSectionWidgetState();
}

class _PollsSectionWidgetState extends State<PollsSectionWidget> {
  @override
  void initState() {
    super.initState();
    context.read<CommunicationsBloc>().add(const LoadPolls(isActive: true));
  }

  void _handleVote(String pollId, String optionId) {
    HapticFeedback.mediumImpact();
    context.read<CommunicationsBloc>().add(VoteOnPoll(pollId, optionId));
    AppSnackbar.show(
      context: context,
      message: 'Your vote has been recorded!',
      type: SnackBarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<CommunicationsBloc, CommunicationsState>(
      listener: (context, state) {
        if (state is VoteCast ||
            state is PollCreated ||
            state is PollUpdated ||
            state is PollDeleted) {
          context.read<CommunicationsBloc>().add(
            const LoadPolls(isActive: true),
          );
        }
      },
      buildWhen: (previous, current) =>
          current is PollsLoaded ||
          current is CommunicationsLoading ||
          current is CommunicationsError,
      builder: (context, state) {
        if (state is CommunicationsLoading) {
          return ListView.builder(
            itemCount: 4,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemBuilder: (_, _) => buildPollCardShimmer(theme),
          );
        }
        if (state is CommunicationsError) {
          return Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 100.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 72.sp,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),

                SizedBox(height: 20.h),

                Text(
                  "Unable to Load Community Polls",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  "Something went wrong while fetching the latest community polls.\nPlease try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24.h),

                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<CommunicationsBloc>().add(
                      const LoadPolls(isActive: true),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        List<Poll> polls = [];
        if (state is PollsLoaded) {
          polls = state.polls;
        }

        if (polls.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CommunicationsBloc>().add(
                const LoadPolls(isActive: true),
              );
              await Future.delayed(const Duration(seconds: 1));
              HapticFeedback.lightImpact();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      'No active polls.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<CommunicationsBloc>().add(
              const LoadPolls(isActive: true),
            );
            await Future.delayed(const Duration(seconds: 1));
            HapticFeedback.lightImpact();
          },
          child: ListView.builder(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return _buildPollCard(poll, theme);
            },
          ),
        );
      },
    );
  }

  Widget _buildPollCard(Poll poll, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 6.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPollHeader(poll, theme),
          _buildPollQuestion(poll, theme),
          _buildPollOptions(poll, theme),
          _buildPollFooter(poll, theme),
        ],
      ),
    );
  }

  Widget _buildPollHeader(Poll poll, ThemeData theme) {
    return Row(
      spacing: 10.w,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: CircleAvatar(
            radius: 18.w,
            backgroundImage:
                poll.createdByProfileImage != null &&
                    poll.createdByProfileImage!.isNotEmpty
                ? CachedNetworkImageProvider(poll.createdByProfileImage!)
                : CachedNetworkImageProvider(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(poll.createdByName ?? "Admin")}&background=random',
                  ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poll.createdByName ?? 'Admin',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.3.h),
              Text(
                poll.createdAt != null ? poll.createdAt!.split(' ').first : '',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: poll.isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            spacing: 4.w,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                poll.isActive ? Icons.access_time : Icons.check_circle,
                color: poll.isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),
              Text(
                poll.isActive ? 'Active' : 'Closed',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: poll.isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            bool canEdit = false;
            if (authState is Authenticated) {
              final String uid = authState.user.id.toString();
              final String role = authState.user.role;
              canEdit =
                  uid == poll.createdBy.toString() ||
                  role == 'admin' ||
                  role == 'super_admin';
            }
            if (!canEdit) return const SizedBox.shrink();

            return PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'close') {
                  context.read<CommunicationsBloc>().add(
                    UpdatePoll(poll.id, const {'is_active': false}),
                  );
                } else if (value == 'delete') {
                  context.read<CommunicationsBloc>().add(DeletePoll(poll.id));
                }
              },
              itemBuilder: (context) => [
                if (poll.isActive)
                  PopupMenuItem(
                    value: 'close',
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                        SizedBox(width: 8.w),
                        const Text('Close Poll'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8.w),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPollQuestion(Poll poll, ThemeData theme) {
    return Text(
      poll.question,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildPollOptions(Poll poll, ThemeData theme) {
    final options = poll.options;
    final totalVotes = poll.totalVotes;
    final hasVoted = poll.hasVoted;

    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final votes = option.voteCount;
        final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;

        return GestureDetector(
          onTap: (poll.isActive && !hasVoted)
              ? () => _handleVote(poll.id, option.id)
              : null,
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        option.optionText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasVoted) ...[
                      SizedBox(width: 2.w),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 1.h),
                Stack(
                  children: [
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 5.h,
                      width: hasVoted
                          ? (percentage /
                                    100 *
                                    MediaQuery.of(context).size.width *
                                    0.8)
                                .w
                          : 0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.5),
                            theme.colorScheme.secondary.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPollFooter(Poll poll, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.how_to_vote,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                '${poll.totalVotes} votes',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (poll.hasVoted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                spacing: 2.w,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: theme.colorScheme.primary, size: 14),
                  SizedBox(width: 1.w),
                  Text(
                    'Voted',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildPollCardShimmer(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              _shimmerBox(width: 36.w, height: 36.w, radius: 18.r),

              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 120.w, height: 12.h),
                    SizedBox(height: 6.h),
                    _shimmerBox(width: 70.w, height: 10.h),
                  ],
                ),
              ),

              _shimmerBox(width: 70.w, height: 26.h, radius: 20.r),
            ],
          ),

          SizedBox(height: 16.h),

          /// Question
          _shimmerBox(width: double.infinity, height: 16.h),

          SizedBox(height: 8.h),

          _shimmerBox(width: 220.w, height: 16.h),

          SizedBox(height: 16.h),

          /// Poll Options
          ...List.generate(
            2,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 160.w + (index * 15).w, height: 12.h),

                  SizedBox(height: 8.h),

                  _shimmerBox(width: double.infinity, height: 5.h, radius: 6.r),
                ],
              ),
            ),
          ),

          SizedBox(height: 6.h),

          /// Footer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _shimmerBox(width: 18.w, height: 18.w, radius: 9.r),
                    SizedBox(width: 8.w),
                    _shimmerBox(width: 70.w, height: 12.h),
                  ],
                ),

                _shimmerBox(width: 60.w, height: 24.h, radius: 20.r),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _shimmerBox({double? width, double? height, double radius = 6}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}
