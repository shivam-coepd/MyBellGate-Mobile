import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/events/events_bloc.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  bool _isGoing = false;
  final ScrollController _scrollCtrl = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _isGoing = widget.event['my_status'] == 'going';
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();

    _scrollCtrl.addListener(() {
      final collapsed = _scrollCtrl.offset > 200.h;
      if (collapsed != _isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        Map<String, dynamic> currentEvent = widget.event;
        if (state is EventsLoaded) {
          currentEvent = state.events.firstWhere(
            (e) => e['id'] == widget.event['id'],
            orElse: () => widget.event,
          );
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(colorScheme, isDark, currentEvent),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: _buildContent(
                      context,
                      theme,
                      colorScheme,
                      isDark,
                      currentEvent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(
            context,
            theme,
            colorScheme,
            currentEvent,
          ),
        );
      },
    );
  }

  // ─── Sliver App Bar ───────────────────────────────────────────────────────

  Widget _buildSliverAppBar(
    ColorScheme cs,
    bool isDark,
    Map<String, dynamic> currentEvent,
  ) {
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      stretch: true,
      backgroundColor: cs.surface,
      elevation: _isHeaderCollapsed ? 0.5 : 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,

      // leading: IconButton(
      //   icon: Icon(Icons.arrow_back_ios_new_rounded),
      //   onPressed: () {
      //     HapticFeedback.lightImpact();
      //     Navigator.pop(context);
      //   },
      // ),
      leadingWidth: 44.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              currentEvent["cover_image"]?.isNotEmpty == true
                  ? currentEvent["cover_image"]
                  : 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678',
              fit: BoxFit.cover,
            ),
            // Gradient overlay for readability
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
            // Category chip
            Positioned(
              bottom: 16.h,
              left: 16.w,
              child: _CategoryChip(label: currentEvent["category"] ?? 'Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: accent ? Colors.amber[300] : Colors.white,
        ),
      ),
    );
  }

  // ─── Main Content ──────────────────────────────────────────────────────────

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    bool isDark,
    Map<String, dynamic> currentEvent,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentEvent["title"] ?? 'Untitled Event',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: 10.h),
                _buildQuickStats(theme, cs, isDark, currentEvent),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          _buildInfoCards(theme, cs, isDark, currentEvent),
          SizedBox(height: 20.h),

          // Attendees
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildAttendeesSection(theme, cs, currentEvent),
          ),

          // About
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildAboutSection(theme, cs, currentEvent),
          ),

          SizedBox(height: 16.h),

          // Tags
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildTags(cs, isDark, currentEvent),
          ),
        ],
      ),
    );
  }

  // ─── Quick Stats Row ───────────────────────────────────────────────────────

  Widget _buildQuickStats(
    ThemeData theme,
    ColorScheme cs,
    bool isDark,
    Map<String, dynamic> currentEvent,
  ) {
    return Row(
      children: [
        _StatPill(
          icon: Icons.people_alt_rounded,
          label: '${currentEvent["attendees"] ?? 0} going',
          cs: cs,
          isDark: isDark,
        ),
        SizedBox(width: 8.w),
        _StatPill(
          icon: Icons.confirmation_num_rounded,
          label: (currentEvent["price"] == "Free"
              ? "Free"
              : "₹${currentEvent["price"]}"),
          cs: cs,
          isDark: isDark,
          color: cs.primary,
        ),
      ],
    );
  }

  // ─── Info Cards ────────────────────────────────────────────────────────────

  Widget _buildInfoCards(
    ThemeData theme,
    ColorScheme cs,
    bool isDark,
    Map<String, dynamic> currentEvent,
  ) {
    final bgColor = isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
        : cs.surfaceContainerLowest;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _InfoCard(
            icon: Icons.calendar_month_rounded,
            title: 'Date',
            subtitle: '${currentEvent["event_date"] ?? ""}',
            accent: cs.primary,
            bg: bgColor,
            theme: theme,
          ),
          SizedBox(width: 10.w),
          _InfoCard(
            icon: Icons.schedule_rounded,
            title: 'Time',
            subtitle: currentEvent["event_time"] ?? '—',
            accent: const Color(0xFF7C3AED),
            bg: bgColor,
            theme: theme,
          ),
          SizedBox(width: 10.w),
          _InfoCard(
            icon: Icons.location_on_rounded,
            title: 'Venue',
            subtitle: currentEvent["location"] ?? '—',
            accent: const Color(0xFF059669),
            bg: bgColor,
            theme: theme,
          ),
          SizedBox(width: 10.w),
          _InfoCard(
            icon: Icons.person_rounded,
            title: 'Host',
            subtitle: currentEvent["organizer"] ?? '—',
            accent: const Color(0xFFEA580C),
            bg: bgColor,
            theme: theme,
          ),
        ],
      ),
    );
  }

  // ─── Attendees Section ─────────────────────────────────────────────────────

  Widget _buildAttendeesSection(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> currentEvent,
  ) {
    final attendeesCount = currentEvent["attendees"] ?? 0;
    final List<dynamic> recentAttendees =
        currentEvent["recent_attendees"] ?? [];
    final displayCount = recentAttendees.isNotEmpty
        ? recentAttendees.length
        : (attendeesCount > 8 ? 8 : attendeesCount);

    if (attendeesCount == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attendees',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Be the first to RSVP!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendees',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            if (attendeesCount > displayCount)
              GestureDetector(
                onTap: () => HapticFeedback.selectionClick(),
                child: Text(
                  'View all',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 52.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: (40 + ((displayCount - 1) * 24.0)).clamp(40, 260).w,
                child: Stack(
                  children: List.generate(
                    displayCount,
                    (i) => Positioned(
                      left: (i * 24).w,
                      child: _AvatarBubble(
                        imageUrl: recentAttendees.length > i
                            ? recentAttendees[i]
                            : null,
                        index: i,
                      ),
                    ),
                  ),
                ),
              ),
              if (attendeesCount > displayCount) ...[
                SizedBox(width: 8.w),
                Text(
                  '+${attendeesCount - displayCount} more',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── About Section ─────────────────────────────────────────────────────────

  Widget _buildAboutSection(
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> currentEvent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this event',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          currentEvent["description"] ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.65,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  // ─── Tags ──────────────────────────────────────────────────────────────────

  Widget _buildTags(
    ColorScheme cs,
    bool isDark,
    Map<String, dynamic> currentEvent,
  ) {
    final tagsString = currentEvent["tags"]?.toString() ?? '';

    final tags = tagsString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: tags
          .map((tag) => _TagChip(label: '#$tag', cs: cs, isDark: isDark))
          .toList(),
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    Map<String, dynamic> currentEvent,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Price / availability badge
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (currentEvent["price"] == "Free"
                    ? "Free"
                    : "₹ ${currentEvent["price"]}"),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                'per person',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          // RSVP Button
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() => _isGoing = !_isGoing);
                  context.read<EventsBloc>().add(
                    RsvpToEvent(
                      widget.event['id'],
                      _isGoing ? 'going' : 'not_going',
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: _isGoing ? cs.primaryContainer : cs.primary,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: _isGoing
                        ? []
                        : [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _isGoing
                              ? Icons.check_circle_rounded
                              : Icons.celebration_rounded,
                          key: ValueKey(_isGoing),
                          color: _isGoing
                              ? cs.onPrimaryContainer
                              : cs.onPrimary,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _isGoing ? "You're Going!" : 'RSVP Now',
                          key: ValueKey(_isGoing),
                          style: TextStyle(
                            color: _isGoing
                                ? cs.onPrimaryContainer
                                : cs.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ──────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final bool isDark;
  final Color? color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.cs,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? cs.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.7)
            : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: c),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color bg;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.bg,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 17.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  final int index;
  final String? imageUrl;

  const _AvatarBubble({required this.index, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl?.isNotEmpty == true
              ? imageUrl!
              : 'https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/${index + 20}.jpg',
          fit: BoxFit.cover,
          semanticLabel: 'Attendee ${index + 1}',
          errorBuilder: (_, __, ___) => CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  final bool isDark;

  const _TagChip({required this.label, required this.cs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.primary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
