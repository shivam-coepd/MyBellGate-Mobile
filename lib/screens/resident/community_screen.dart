import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/blocs/community/community_bloc.dart';
import 'package:mygate_coepd/models/community_post.dart';
import 'package:mygate_coepd/models/marketplace_item.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(LoadCommunityData());

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _currentIndex == 0 ? 'Search posts...' : 'Search marketplace...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Tab bar
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _currentIndex = 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex == 0
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardTheme.color,
                      foregroundColor: _currentIndex == 0
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('Feed', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentIndex == 1
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardTheme.color,
                      foregroundColor: _currentIndex == 1
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Marketplace',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content based on selected tab
          Expanded(
            child: BlocBuilder<CommunityBloc, CommunityState>(
              builder: (context, state) {
                if (state is CommunityLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommunityError) {
                  return Center(child: Text(state.message));
                } else if (state is CommunityLoaded) {
          if (_currentIndex == 0) {
            final posts = state.posts.where((post) {
              return _searchTerm.isEmpty ||
                  post.content.toLowerCase().contains(_searchTerm) ||
                  post.userName.toLowerCase().contains(_searchTerm);
            }).toList();
            
            final authState = context.read<AuthBloc>().state;
            final currentUserId = (authState is Authenticated) ? int.tryParse(authState.user.id) : null;
            
            return _buildFeed(posts, currentUserId);
          } else {
                    final items = state.marketplaceItems.where((item) {
                      return _searchTerm.isEmpty ||
                          item.title.toLowerCase().contains(_searchTerm) ||
                          item.sellerName.toLowerCase().contains(_searchTerm);
                    }).toList();
                    return _buildMarketplace(items);
                  }
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed(List<CommunityPost> posts, int? currentUserId) {
    return posts.isEmpty
        ? _buildEmptyFeedState()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (0.1 * index).clamp(0.0, 1.0),
                      (0.3 + (0.1 * index)).clamp(0.0, 1.0),
                      curve: Curves.elasticOut,
                    ),
                  ),
                ),
                child: Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).cardTheme.color ?? Colors.white,
                          (Theme.of(context).cardTheme.color ?? Colors.white).withValues(alpha: 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info with gradient background
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                Theme.of(context).primaryColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.r),
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2.w,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20.r,
                                  backgroundImage: post.userAvatar != null
                                      ? CachedNetworkImageProvider(post.userAvatar!)
                                      : null,
                                  child: post.userAvatar == null ? const Icon(Icons.person) : null,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    Text(
                                      (post.unit != null && post.unit!.isNotEmpty) ? post.unit! : 'No unit',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (currentUserId == post.userId)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Post'),
                                        content: const Text('Are you sure you want to delete this post?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              context.read<CommunityBloc>().add(DeleteCommunityPost(post.id));
                                            },
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        // Post content
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            post.content,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                        // Post image
                        if (post.image != null && post.image!.isNotEmpty)
                          Container(
                            height: 200.h,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(post.image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 16.h),
                        // Post actions
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.read<CommunityBloc>().add(LikeCommunityPost(post.id)),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: post.hasLiked
                                        ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        size: 16.sp,
                                        color: post.hasLiked ? Theme.of(context).primaryColor : Colors.grey,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '${post.likesCount}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: post.hasLiked ? Theme.of(context).primaryColor : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      size: 16.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${post.commentsCount}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildMarketplace(List<MarketplaceItem> items) {
    return items.isEmpty
        ? _buildEmptyMarketplaceState()
        : GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (0.1 * index).clamp(0.0, 1.0),
                      (0.3 + (0.1 * index)).clamp(0.0, 1.0),
                      curve: Curves.elasticOut,
                    ),
                  ),
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item image
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                            color: Colors.grey.shade200,
                            image: item.image != null && item.image!.isNotEmpty
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(item.image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: item.image == null || item.image!.isEmpty
                              ? const Center(child: Icon(Icons.image, color: Colors.grey))
                              : null,
                        ),
                      ),
                      // Item details
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '₹${item.price}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006D77),
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${item.sellerName} • ${item.unit ?? ""}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
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
          );
  }

  void _showCreatePostDialog() {
    final TextEditingController postController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Create New Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: postController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'What would you like to share with the community?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (postController.text.trim().isNotEmpty) {
                        context.read<CommunityBloc>().add(
                              CreateCommunityPost(content: postController.text.trim()),
                            );
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyFeedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.groups, size: 50, color: Color(0xFF006D77)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Posts Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'There are no posts in the community feed'
                : 'No posts match your search',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMarketplaceState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.shopping_cart,
              size: 50,
              color: Color(0xFF006D77),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Items Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'There are no items in the marketplace'
                : 'No items match your search',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
