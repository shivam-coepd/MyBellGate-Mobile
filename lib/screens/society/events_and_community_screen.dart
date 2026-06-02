import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mygate_coepd/services/s3_upload_service.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showFab) setState(() => _showFab = false);
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showFab) setState(() => _showFab = true);
    }
  }

  void _handleSegmentTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedSegment = index);
    _tabController.animateTo(index);
  }

  void _showCreatePostSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Community Management',
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        // foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Column(
          children: [
            _buildSegmentedControl(theme),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  EventsSectionWidget(scrollController: _scrollController),
                  CommunityFeedSectionWidget(
                    scrollController: _scrollController,
                  ),
                  PollsSectionWidget(scrollController: _scrollController),
                ],
              ),
            ),
          ],
        ),
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
  final List<Map<String, dynamic>> _posts = [
    {
      "id": 1,
      "type": "post",
      "author": "Priya Sharma",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1b618025b-1765165480659.png",
      "authorAvatarLabel":
          "Woman with long black hair wearing a red top smiling at camera",
      "timestamp": "2 hours ago",
      "content":
          "Great news! The new children's play area is now open. Thank you to the maintenance team for the wonderful work. My kids are absolutely loving it! 🎉",
      "images": [
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1d8ad7d26-1766018948634.png",
          "semanticLabel":
              "Colorful playground with slides, swings, and climbing equipment in a residential area",
        },
      ],
      "likes": 45,
      "comments": 12,
      "shares": 3,
      "isLiked": false,
      "category": "Announcement",
    },
    {
      "id": 2,
      "type": "discussion",
      "author": "Rajesh Kumar",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16d43d804-1765703781841.png",
      "authorAvatarLabel":
          "Man with short black hair and glasses wearing a blue shirt",
      "timestamp": "5 hours ago",
      "content":
          "Does anyone know if the swimming pool will be open this weekend? Planning a family gathering and would love to use the facility.",
      "images": [],
      "likes": 23,
      "comments": 18,
      "shares": 1,
      "isLiked": true,
      "category": "Question",
    },
    {
      "id": 3,
      "type": "announcement",
      "author": "Society Committee",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10df5a971-1765003957966.png",
      "authorAvatarLabel":
          "Professional woman in formal attire with short brown hair",
      "timestamp": "1 day ago",
      "content":
          "Important Notice: Water supply will be interrupted tomorrow from 10 AM to 2 PM for maintenance work. Please store water accordingly. We apologize for any inconvenience.",
      "images": [],
      "likes": 89,
      "comments": 34,
      "shares": 15,
      "isLiked": false,
      "category": "Important",
    },
    {
      "id": 4,
      "type": "post",
      "author": "Anita Desai",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_19147d633-1765716447945.png",
      "authorAvatarLabel":
          "Elderly woman with gray hair wearing traditional Indian attire",
      "timestamp": "2 days ago",
      "content":
          "Wonderful Diwali celebration organized by our society! The decorations were beautiful and the cultural program was amazing. Looking forward to more such events.",
      "images": [
        {
          "url": "https://images.unsplash.com/photo-1729986918572-8311fedf08a1",
          "semanticLabel":
              "Beautiful Diwali decorations with colorful lights, diyas, and rangoli patterns",
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_12cc8ed01-1765289716212.png",
          "semanticLabel":
              "Group of people in traditional Indian clothing celebrating Diwali festival",
        },
      ],
      "likes": 156,
      "comments": 42,
      "shares": 8,
      "isLiked": true,
      "category": "Social",
    },
  ];

  void _handleLike(int postId) {
    HapticFeedback.lightImpact();
    setState(() {
      final post = _posts.firstWhere((p) => p["id"] == postId);
      post["isLiked"] = !post["isLiked"];
      post["likes"] = post["isLiked"] ? post["likes"] + 1 : post["likes"] - 1;
    });
  }

  void _handleComment(int postId) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsBottomSheet(postId: postId),
    );
  }

  void _handleShare(Map<String, dynamic> post) {
    HapticFeedback.mediumImpact();
    // ignore: deprecated_member_use
    Share.share(
      '${post["author"]}: ${post["content"]}',
      subject: 'Community Post',
    );
    setState(() {
      post["shares"] = post["shares"] + 1;
    });
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Post reported. Our team will review it.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.inverseSurface,
                  behavior: SnackBarBehavior.floating,
                ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        HapticFeedback.lightImpact();
      },
      child: ListView.builder(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post, theme);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, ThemeData theme) {
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
          _buildPostHeader(post, theme),
          _buildPostContent(post, theme),
          if ((post["images"] as List).isNotEmpty)
            _buildPostImages(post, theme),
          _buildPostActions(post, theme),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post, ThemeData theme) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: Image.network(
            post["authorAvatar"],
            width: 36.w,
            height: 36.w,
            fit: BoxFit.cover,
            semanticLabel: post["authorAvatarLabel"],
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
                      post["author"],
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
                      color: post["category"] == "Important"
                          ? theme.colorScheme.error.withValues(alpha: 0.12)
                          : theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      post["category"],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: post["category"] == "Important"
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.3.h),
              Text(
                post["timestamp"],
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
              _handleReport(post["id"]);
            }
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          itemBuilder: (context) => [
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

  Widget _buildPostContent(Map<String, dynamic> post, ThemeData theme) {
    return Text(
      post["content"],
      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
    );
  }

  Widget _buildPostImages(Map<String, dynamic> post, ThemeData theme) {
    final images = post["images"] as List;

    return SizedBox(
      height: images.length > 1 ? 80.h : 130.h,
      child: images.length == 1
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r.r),
              child: Image.network(
                images[0]["url"],
                width: double.infinity,
                height: 30.h,
                fit: BoxFit.cover,
                semanticLabel: images[0]["semanticLabel"],
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  width: 80.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      images[index]["url"],
                      // width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                      semanticLabel: images[index]["semanticLabel"],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPostActions(Map<String, dynamic> post, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          _buildActionButton(
            Icon(
              Icons.favorite_border_outlined,
              color: post["isLiked"]
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            '${post["likes"]}',
            () => _handleLike(post["id"]),
            theme,
          ),
          SizedBox(width: 4.w),
          _buildActionButton(
            Icon(
              Icons.comment,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            '${post["comments"]}',
            () => _handleComment(post["id"]),
            theme,
          ),
          SizedBox(width: 4.w),
          _buildActionButton(
            Icon(
              Icons.share,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            '${post["shares"]}',
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
  final List<Map<String, dynamic>> _comments = [
    {
      "author": "Amit Patel",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e771e724-1763294071742.png",
      "avatarLabel": "Man with short black hair wearing a green shirt",
      "comment": "This is wonderful news! Thanks for sharing.",
      "timestamp": "1 hour ago",
    },
    {
      "author": "Sneha Reddy",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1b618025b-1765165480659.png",
      "avatarLabel": "Woman with long brown hair wearing a blue top",
      "comment": "Great initiative by the society committee!",
      "timestamp": "30 minutes ago",
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_commentController.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _comments.insert(0, {
        "author": "You",
        "avatar":
            "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
        "avatarLabel": "Your profile photo",
        "comment": _commentController.text.trim(),
        "timestamp": "Just now",
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 0.1.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.network(
                          comment["avatar"],
                          width: 10.w,
                          height: 10.w,
                          fit: BoxFit.cover,
                          semanticLabel: comment["avatarLabel"],
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment["author"],
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              comment["comment"],
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              comment["timestamp"],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    onPressed: _postComment,
                  ),
                ],
              ),
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

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];
  bool _isUploadingImages = false;
  String _postType = 'post'; // post, poll, announcement
  String _privacySetting = 'public'; // public, residents_only
  bool _isCreatingPoll = false;
  final List<TextEditingController> _pollOptions = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _s3 = S3UploadService();

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

      // Cap at 4 images total
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image upload failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
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

  void _togglePollCreation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isCreatingPoll = !_isCreatingPoll;
      if (_isCreatingPoll) {
        _postType = 'poll';
        _selectedImages.clear();
      } else {
        _postType = 'post';
      }
    });
  }

  void _addPollOption() {
    if (_pollOptions.length < 6) {
      HapticFeedback.lightImpact();
      setState(() {
        _pollOptions.add(TextEditingController());
      });
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
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please write something to post',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onInverseSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.inverseSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isUploadingImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, images are still uploading...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    // _uploadedImageUrls now contains the S3 public URLs ready to send to backend
    Navigator.pop(context);

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCreatingPoll
              ? 'Poll created successfully!'
              : 'Post created successfully!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContentInput(theme),
                  if (!_isCreatingPoll && _selectedImages.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    _buildImagePreview(theme),
                  ],
                  if (_isCreatingPoll) ...[
                    SizedBox(height: 2.h),
                    _buildPollOptions(theme),
                  ],
                  SizedBox(height: 2.h),
                  _buildPrivacySelector(theme),
                ],
              ),
            ),
          ),
          _buildBottomActions(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          Text(
            _isCreatingPoll ? 'Create Poll' : 'Create Post',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: _createPost,
            child: Text(
              'Post',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput(ThemeData theme) {
    return TextField(
      controller: _contentController,
      maxLines: _isCreatingPoll ? 3 : 6,
      decoration: InputDecoration(
        hintText: _isCreatingPoll
            ? 'Ask a question...'
            : 'What\'s on your mind?',
        border: InputBorder.none,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 2.w),
                width: 35.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    _selectedImages[index].path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 1.h,
                right: 3.w,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPollOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Poll Options',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...List.generate(_pollOptions.length, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: 1.5.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pollOptions[index],
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Icon(
                          Icons.radio_button_unchecked,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_pollOptions.length > 2) ...[
                  SizedBox(width: 2.w),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    onPressed: () => _removePollOption(index),
                  ),
                ],
              ],
            ),
          );
        }),
        if (_pollOptions.length < 6)
          TextButton.icon(
            onPressed: _addPollOption,
            icon: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
            label: Text(
              'Add Option',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacySelector(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            _privacySetting == 'public' ? Icons.public : Icons.people,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _privacySetting == 'public' ? 'Public' : 'Residents Only',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              HapticFeedback.lightImpact();
              setState(() => _privacySetting = value);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'public',
                child: Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Public', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'residents_only',
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Residents Only', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
            child: Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            _buildActionButton(
              Icon(
                Icons.photo_library,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              'Photos',
              _isCreatingPoll ? null : _pickImages,
              theme,
            ),
            SizedBox(width: 2.w),
            _buildActionButton(
              Icon(Icons.poll, color: theme.colorScheme.secondary, size: 24),
              'Poll',
              _togglePollCreation,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    Widget icon,
    String label,
    VoidCallback? onTap,
    ThemeData theme,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: onTap == null
                ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  )
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 2.w),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: onTap == null
                      ? theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        )
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
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
  final List<Map<String, dynamic>> _events = [
    {
      "id": 1,
      "title": "Annual Society Day Celebration",
      "date": "2025-01-15",
      "time": "6:00 PM - 10:00 PM",
      "location": "Community Hall, Block A",
      "coverImage":
          "https://img.rocket.new/generatedImages/rocket_gen_img_188fc72e0-1765792683654.png",
      "semanticLabel":
          "Colorful balloons and decorations in a festive community hall with people celebrating",
      "organizer": "Society Committee",
      "organizerAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_188fc72e0-1765792683654.png",
      "organizerAvatarLabel":
          "Professional photo of a woman with shoulder-length brown hair wearing a blue blazer",
      "attendees": 156,
      "rsvpStatus": "going",
      "description":
          "Join us for our annual celebration featuring cultural performances, dinner, and entertainment for all ages. Special performances by local artists and fun activities for children.",
      "category": "Social",
    },
    {
      "id": 2,
      "title": "Yoga & Wellness Workshop",
      "date": "2025-01-08",
      "time": "7:00 AM - 9:00 AM",
      "location": "Garden Area",
      "coverImage":
          "https://images.unsplash.com/photo-1594298332319-c04674dbbe3c",
      "semanticLabel":
          "Group of people practicing yoga poses on mats in a peaceful outdoor garden setting at sunrise",
      "organizer": "Health Committee",
      "organizerAvatar":
          "https://images.unsplash.com/photo-1594298332319-c04674dbbe3c",
      "organizerAvatarLabel":
          "Headshot of a man with short black hair and beard wearing a white t-shirt",
      "attendees": 45,
      "rsvpStatus": "interested",
      "description":
          "Start your day with rejuvenating yoga sessions led by certified instructors. Suitable for all levels from beginners to advanced practitioners.",
      "category": "Health",
    },
    {
      "id": 3,
      "title": "Kids Art & Craft Competition",
      "date": "2025-01-20",
      "time": "4:00 PM - 6:00 PM",
      "location": "Activity Center",
      "coverImage":
          "https://images.unsplash.com/photo-1691256257482-ac753cb26509",
      "semanticLabel":
          "Children sitting at tables with colorful art supplies, paints, and craft materials creating artwork",
      "organizer": "Parents Association",
      "organizerAvatar":
          "https://images.unsplash.com/photo-1691256257482-ac753cb26509",
      "organizerAvatarLabel":
          "Smiling woman with long dark hair wearing a yellow top",
      "attendees": 78,
      "rsvpStatus": null,
      "description":
          "Encourage creativity in children with our art competition. Categories for different age groups with exciting prizes and certificates for all participants.",
      "category": "Kids",
    },
    {
      "id": 4,
      "title": "Security Awareness Meeting",
      "date": "2025-01-12",
      "time": "8:00 PM - 9:30 PM",
      "location": "Conference Room",
      "coverImage":
          "https://images.unsplash.com/photo-1672917187338-7f81ecac3d3f",
      "semanticLabel":
          "Professional meeting room with people seated around a conference table discussing security matters",
      "organizer": "Security Team",
      "organizerAvatar":
          "https://images.unsplash.com/photo-1672917187338-7f81ecac3d3f",
      "organizerAvatarLabel":
          "Man in security uniform with short gray hair and serious expression",
      "attendees": 92,
      "rsvpStatus": "going",
      "description":
          "Important meeting to discuss enhanced security measures and protocols. All residents are encouraged to attend and share their concerns.",
      "category": "Important",
    },
  ];

  void _handleRSVP(int eventId, String status) {
    HapticFeedback.lightImpact();
    setState(() {
      final event = _events.firstWhere((e) => e["id"] == eventId);
      if (event["rsvpStatus"] == status) {
        event["rsvpStatus"] = null;
        event["attendees"] = (event["attendees"] as int) - 1;
      } else {
        if (event["rsvpStatus"] != null) {
          event["attendees"] = (event["attendees"] as int) - 1;
        }
        event["rsvpStatus"] = status;
        event["attendees"] = (event["attendees"] as int) + 1;
      }
    });

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == 'going'
              ? 'You\'re going to this event!'
              : 'Marked as interested',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleShare(Map<String, dynamic> event) {
    HapticFeedback.mediumImpact();
    // ignore: deprecated_member_use
    Share.share(
      'Join me at ${event["title"]} on ${event["date"]} at ${event["time"]}. Location: ${event["location"]}',
      subject: event["title"],
    );
  }

  void _handleAddToCalendar(Map<String, dynamic> event) {
    HapticFeedback.lightImpact();
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Event added to calendar',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleGetDirections(Map<String, dynamic> event) {
    HapticFeedback.lightImpact();
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening directions to ${event["location"]}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _EventDetailScreen(event: event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        HapticFeedback.lightImpact();
      },
      child: ListView.builder(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return _buildEventCard(event, theme);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, ThemeData theme) {
    return Slidable(
      key: ValueKey(event["id"]),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _handleShare(event),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: Icons.share,
            label: 'Share',
            borderRadius: BorderRadius.circular(16.r),
          ),
          SlidableAction(
            onPressed: (_) => _handleAddToCalendar(event),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.calendar_today,
            label: 'Calendar',
            borderRadius: BorderRadius.circular(16.r),
          ),
        ],
      ),
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildEventImage(Map<String, dynamic> event, ThemeData theme) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            event["coverImage"],
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
              event["category"],
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
            event["title"],
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
          '${event["date"]} • ${event["time"]}',
          theme,
        ),
        _buildDetailRow(
          Icon(
            Icons.location_on,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          event["location"],
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
            event["organizerAvatar"],
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
                event["organizer"],
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${event["attendees"]} attending',
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
}

/// Event detail screen with full information
class _EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const _EventDetailScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 30.h,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                event["coverImage"],
                width: double.infinity,
                height: 30.h,
                fit: BoxFit.cover,
                semanticLabel: event["semanticLabel"],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["title"],
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildInfoCard(theme),
                  SizedBox(height: 2.h),
                  Text(
                    'About Event',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    event["description"],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildAttendeesList(theme),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(context, theme),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            'Date & Time',
            '${event["date"]}\n${event["time"]}',
            theme,
          ),
          Divider(height: 3.h),
          _buildInfoRow(
            Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),
            'Location',
            event["location"],
            theme,
          ),
          Divider(height: 3.h),
          _buildInfoRow(
            Icon(Icons.person, color: theme.colorScheme.primary, size: 20),
            'Organizer',
            event["organizer"],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    Widget icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        icon,
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendeesList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendees',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${event["attendees"]} going',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 10.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.r),
                  child: Image.network(
                    'https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/${index + 20}.jpg',
                    width: 10.w,
                    height: 10.w,
                    fit: BoxFit.cover,
                    semanticLabel: 'Profile photo of attendee ${index + 1}',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
                child: const Text('RSVP Going'),
              ),
            ),
            SizedBox(width: 3.w),
            OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                // ignore: deprecated_member_use
                Share.share(
                  'Join me at ${event["title"]} on ${event["date"]}!',
                  subject: event["title"],
                );
              },
              style: OutlinedButton.styleFrom(padding: EdgeInsets.all(1.8.h)),
              child: Icon(
                Icons.share,
                color: theme.colorScheme.primary,
                size: 20,
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
  final List<Map<String, dynamic>> _polls = [
    {
      "id": 1,
      "question": "What time should the gym be open on weekends?",
      "author": "Fitness Committee",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_19254133b-1765314260906.png",
      "authorAvatarLabel": "Man in fitness attire with short hair",
      "timestamp": "2 days ago",
      "totalVotes": 234,
      "hasVoted": false,
      "selectedOption": null,
      "options": [
        {"text": "6 AM - 10 PM", "votes": 89},
        {"text": "7 AM - 9 PM", "votes": 78},
        {"text": "8 AM - 8 PM", "votes": 45},
        {"text": "Keep current timings", "votes": 22},
      ],
      "endsIn": "2 days",
      "status": "active",
    },
    {
      "id": 2,
      "question": "Should we organize a monthly movie night?",
      "author": "Entertainment Committee",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_12fd58c5c-1765764673574.png",
      "authorAvatarLabel": "Woman with curly hair wearing casual attire",
      "timestamp": "1 week ago",
      "totalVotes": 312,
      "hasVoted": true,
      "selectedOption": 0,
      "options": [
        {"text": "Yes, every month", "votes": 198},
        {"text": "Yes, but quarterly", "votes": 76},
        {"text": "No, not interested", "votes": 38},
      ],
      "endsIn": "5 days",
      "status": "active",
    },
    {
      "id": 3,
      "question": "Preferred timing for society meetings?",
      "author": "Society Committee",
      "authorAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_18365d8c3-1765084089359.png",
      "authorAvatarLabel": "Elderly man in formal attire with glasses",
      "timestamp": "2 weeks ago",
      "totalVotes": 456,
      "hasVoted": true,
      "selectedOption": 1,
      "options": [
        {"text": "Weekday evenings (7-9 PM)", "votes": 156},
        {"text": "Weekend mornings (10 AM-12 PM)", "votes": 189},
        {"text": "Weekend evenings (6-8 PM)", "votes": 111},
      ],
      "endsIn": "Ended",
      "status": "closed",
    },
  ];

  void _handleVote(int pollId, int optionIndex) {
    HapticFeedback.mediumImpact();
    setState(() {
      final poll = _polls.firstWhere((p) => p["id"] == pollId);

      if (poll["hasVoted"]) {
        // Remove previous vote
        final previousOption = poll["selectedOption"];
        if (previousOption != null) {
          (poll["options"] as List)[previousOption]["votes"]--;
          poll["totalVotes"]--;
        }
      }

      // Add new vote
      (poll["options"] as List)[optionIndex]["votes"]++;
      poll["totalVotes"]++;
      poll["hasVoted"] = true;
      poll["selectedOption"] = optionIndex;
    });

    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your vote has been recorded!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        HapticFeedback.lightImpact();
      },
      child: ListView.builder(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: _polls.length,
        itemBuilder: (context, index) {
          final poll = _polls[index];
          return _buildPollCard(poll, theme);
        },
      ),
    );
  }

  Widget _buildPollCard(Map<String, dynamic> poll, ThemeData theme) {
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

  Widget _buildPollHeader(Map<String, dynamic> poll, ThemeData theme) {
    return Row(
      spacing: 10.w,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.network(
            poll["authorAvatar"],
            width: 36.w,
            height: 36.w,
            fit: BoxFit.cover,
            semanticLabel: poll["authorAvatarLabel"],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poll["author"],
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.3.h),
              Text(
                poll["timestamp"],
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
            color: poll["status"] == "active"
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            spacing: 4.w,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                poll["status"] == "active"
                    ? Icons.access_time
                    : Icons.check_circle,
                color: poll["status"] == "active"
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 14,
              ),
              Text(
                poll["endsIn"],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: poll["status"] == "active"
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollQuestion(Map<String, dynamic> poll, ThemeData theme) {
    return Text(
      poll["question"],
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPollOptions(Map<String, dynamic> poll, ThemeData theme) {
    final options = poll["options"] as List;
    final totalVotes = poll["totalVotes"] as int;
    final hasVoted = poll["hasVoted"] as bool;
    final selectedOption = poll["selectedOption"];

    return Column(
      children: List.generate(options.length, (index) {
        final option = options[index];
        final votes = option["votes"] as int;
        final percentage = totalVotes > 0 ? (votes / totalVotes * 100) : 0.0;
        final isSelected = hasVoted && selectedOption == index;
    
        return GestureDetector(
          onTap: poll["status"] == "active"
              ? () => _handleVote(poll["id"], index)
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
                        option["text"],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
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
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
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
                      width: hasVoted ? (percentage / 100 * 100).w : 0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ]
                              : [
                                  theme.colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  theme.colorScheme.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        right: 2.w,
                        top: 0,
                        bottom: 0,
                        child: Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.onPrimary,
                          size: 16,
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

  Widget _buildPollFooter(Map<String, dynamic> poll, ThemeData theme) {
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
                '${poll["totalVotes"]} votes',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (poll["hasVoted"])
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
}
