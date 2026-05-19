import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPosts = [];
  List<Map<String, dynamic>> _filteredMarketplaceItems = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

final List<Map<String, dynamic>> _posts = [
  {
    'id': 1,
    'user': {
      'name': 'John Doe',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'A-101',
    },
    'content': 'Just moved to our new apartment! The community here is amazing. Looking forward to meeting everyone.',
    'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&q=80&w=800&h=600',
    'time': '2 hours ago',
    'likes': 24,
    'comments': 8,
  },
  {
    'id': 2,
    'user': {
      'name': 'Sarah Johnson',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'B-203',
    },
    'content': 'Lost my cat yesterday near the community garden. He\'s orange with white paws. Name: Ginger. Please help!',
    // 'image': 'https://images.unsplash.com/photo-1596854407944-bf87f6130000?auto=format&fit=crop&q=80&w=800&h=600',
    'time': '5 hours ago',
    'likes': 38,
    'comments': 15,
  },
  {
    'id': 3,
    'user': {
      'name': 'Mike Williams',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'C-405',
    },
    'content': 'Community garage sale this weekend! Saturday & Sunday 9AM–4PM at the clubhouse parking.',
    'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&q=80&w=800&h=600',
    'time': '1 day ago',
    'likes': 56,
    'comments': 22,
  },
  {
    'id': 4,
    'user': {
      'name': 'Anita Desai',
      'avatar': 'https://images.unsplash.com/photo-1580489940927-6c2e4d0c4e7b?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'D-602',
    },
    'content': 'Yoga session every morning at 6:30 AM near the pool area. Everyone is welcome! Bring your mat.',
    'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=800&h=600',
    'time': '2 days ago',
    'likes': 45,
    'comments': 19,
  },
  {
    'id': 5,
    'user': {
      'name': 'Rahul Mehta',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'E-801',
    },
    'content': 'Found a set of keys near Tower B lift. Has a blue keychain with car logo. Owner please collect from security.',
    'image': 'https://images.unsplash.com/photo-1761991432834-5446634d194f?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHx0b3BpYy1mZWVkfDZ8TThqVmJMYlRSd3N8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=60&w=600',
    'time': '3 hours ago',
    'likes': 12,
    'comments': 5,
  },
  {
    'id': 6,
    'user': {
      'name': 'Priya Sharma',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'A-305',
    },
    'content': 'Diwali potluck party this Friday at the clubhouse! Bring one dish. Theme: Traditional sweets & snacks.',
    'image': 'https://images.unsplash.com/photo-1738225734433-9fb17ed770a4?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8VHJhZGl0aW9uYWwlMjBzd2VldHMlMjAlMjYlMjBzbmFja3N8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600',
    'time': '4 days ago',
    'likes': 78,
    'comments': 34,
  },
  {
    'id': 7,
    'user': {
      'name': 'Vikram Singh',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'F-110',
    },
    'content': 'Anyone up for weekend cricket? We need 3 more players. Ground booked Sunday 7 AM.',
    'image': 'https://images.unsplash.com/photo-1685541001104-91fe7ae1d8e1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8QW55b25lJTIwdXAlMjBmb3IlMjB3ZWVrZW5kJTIwY3JpY2tldCUzRiUyMFdlJTIwbmVlZCUyMDMlMjBtb3JlJTIwcGxheWVycy4lMjBHcm91bmQlMjBib29rZWQlMjBTdW5kYXklMjA3JTIwQU0uJyUyQ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=600',
    'time': '12 hours ago',
    'likes': 29,
    'comments': 11,
  },
  {
    'id': 8,
    'user': {
      'name': 'Neha Kapoor',
      'avatar': 'https://images.unsplash.com/photo-1581404914446-6d8f7b4e0e9b?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'B-507',
    },
    'content': 'Kids art exhibition tomorrow at the community hall. Proud parent moment! All residents invited.',
    // 'image': 'https://images.unsplash.com/photo-1513366884929-cf02d33ebba3?auto=format&fit=crop&q=80&w=800&h=600',
    'time': '1 day ago',
    'likes': 67,
    'comments': 28,
  },
  {
    'id': 9,
    'user': {
      'name': 'Amit Verma',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'G-204',
    },
    'content': 'Water supply will be off tomorrow from 10 AM to 2 PM for maintenance. Please store water.',
    'image': 'https://images.unsplash.com/photo-1557074310-7116e1117372?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8V2F0ZXIlMjBzdXBwbHklMjB3aWxsJTIwYmUlMjBvZmYlMjB0b21vcnJvdyUyMGZyb20lMjAxMCUyMEFNJTIwdG8lMjAyJTIwUE0lMjBmb3IlMjBtYWludGVuYW5jZS4lMjBQbGVhc2UlMjBzdG9yZSUyMHdhdGV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600',
    'time': '6 hours ago',
    'likes': 5,
    'comments': 3,
  },
  {
    'id': 10,
    'user': {
      'name': 'Sonia Reddy',
      'avatar': 'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?auto=format&fit=crop&q=80&w=100&h=100',
      'unit': 'C-709',
    },
    'content': 'Selling homemade pickles & papads! DM for flavors and prices. Fresh batch ready!',
    // 'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&q=80&w=800&h=600',
    'time': '8 hours ago',
    'likes': 41,
    'comments': 20,
  },
];

final List<Map<String, dynamic>> _marketplaceItems = [
  {
    'id': 1,
    'title': '3-Seater Leather Sofa',
    'price': '₹18,000',
    'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?auto=format&fit=crop&q=80&w=600&h=600',
    'user': 'John Smith',
    'unit': 'A-101',
  },
  {
    'id': 2,
    'title': 'Mountain Bicycle (Hero)',
    'price': '₹7,500',
    'image': 'https://images.unsplash.com/photo-1560557336-7f28872591de?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8TW91bnRhaW4lMjBCaWN5Y2xlJTIwKEhlcm8pJTVDfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
    'user': 'Priya Sharma',
    'unit': 'B-203',
  },
  {
    'id': 3,
    'title': 'Microwave + OTG Combo',
    'price': '₹9,500',
    'image': 'https://images.unsplash.com/photo-1649264191712-15b7b6ab2345?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8TWljcm93YXZlJTIwJTJCJTIwT1RHJTIwQ29tYm98ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600',
    'user': 'Raj Patel',
    'unit': 'C-405',
  },
  {
    'id': 4,
    'title': 'Dining Table 6 Chairs',
    'price': '₹22,000',
    'image': 'https://plus.unsplash.com/premium_photo-1726812198035-82a66af2f26a?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8RGluaW5nJTIwVGFibGUlMjA2JTIwQ2hhaXJzfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
    'user': 'Kavita Rao',
    'unit': 'D-602',
  },
  {
    'id': 5,
    'title': 'iPhone 13 128GB (Midnight)',
    'price': '₹42,000',
    'image': 'https://images.unsplash.com/photo-1674345498787-4aee9709fe6c?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fGlQaG9uZSUyMDEzJTIwMTI4R0IlMjAoTWlkbmlnaHQpfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
    'user': 'Arjun Malhotra',
    'unit': 'E-901',
  },
  {
    'id': 6,
    'title': 'Wooden Study Table + Chair',
    'price': '₹6,800',
    'image': 'https://images.unsplash.com/photo-1646775814663-95874b77fd4f?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8V29vZGVuJTIwU3R1ZHklMjBUYWJsZSUyMCUyQiUyMENoYWlyfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=600',
    'user': 'Meera Nair',
    'unit': 'F-305',
  },
  {
    'id': 7,
    'title': '32-inch LED Smart TV (Sony)',
    'price': '₹14,999',
    'image': 'https://images.unsplash.com/photo-1615210230840-69c07c13b4d1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8MzItaW5jaCUyMExFRCUyMFNtYXJ0JTIwVFZ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600',
    'user': 'Vikram Singh',
    'unit': 'B-507',
  },
  {
    'id': 8,
    'title': 'Kids Play Tent House',
    'price': '₹2,200',
    'image': 'https://images.unsplash.com/photo-1721687335590-2e845e641770?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8S2lkcyUyMFBsYXklMjBUZW50JTIwSG91c2V8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=600',
    'user': 'Neha Kapoor',
    'unit': 'G-110',
  },
];

  @override
  void initState() {
    super.initState();
    _filteredPosts = _posts;
    _filteredMarketplaceItems = _marketplaceItems;
    _searchController.addListener(_filterContent);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  void _filterContent() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();
      
      if (_currentIndex == 0) {
        // Filter posts
        _filteredPosts = _posts.where((post) {
          return searchTerm.isEmpty || 
              post['content'].toLowerCase().contains(searchTerm) ||
              post['user']['name'].toLowerCase().contains(searchTerm) ||
              post['user']['unit'].toLowerCase().contains(searchTerm);
        }).toList();
      } else {
        // Filter marketplace items
        _filteredMarketplaceItems = _marketplaceItems.where((item) {
          return searchTerm.isEmpty || 
              item['title'].toLowerCase().contains(searchTerm) ||
              item['user'].toLowerCase().contains(searchTerm) ||
              item['unit'].toLowerCase().contains(searchTerm);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterContent);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                    child: Text('Marketplace', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              ],
            ),
          ),
          // Content based on selected tab
          Expanded(
            child: _currentIndex == 0 ? _buildFeed() : _buildMarketplace(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return _filteredPosts.isEmpty
        ? _buildEmptyFeedState()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _filteredPosts.length,
            itemBuilder: (context, index) {
              final post = _filteredPosts[index];
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      0.1 * index,
                      0.3 + (0.1 * index),
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
                          Theme.of(context).cardTheme.color!,
                          Theme.of(context).cardTheme.color!.withValues(alpha: 0.95),
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
                                  backgroundImage:
                                      CachedNetworkImageProvider(post['user']['avatar']),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['user']['name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    Text(
                                      post['user']['unit'],
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  post['time'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Post content
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Text(
                            post['content'],
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        // Post image
                        if (post['image'] != null)
                          Container(
                            height: 200.h,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(post['image']),
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up,
                                      size: 16.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${post['likes']}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
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
                                      '${post['comments']}',
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

  Widget _buildMarketplace() {
    return _filteredMarketplaceItems.isEmpty
        ? _buildEmptyMarketplaceState()
        : GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.8,
            ),
            itemCount: _filteredMarketplaceItems.length,
            itemBuilder: (context, index) {
              final item = _filteredMarketplaceItems[index];
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      0.1 * index,
                      0.3 + (0.1 * index),
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
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(item['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Item details
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item['price'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF006D77),
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${item['user']} • ${item['unit']}',
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

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String hintText = _currentIndex == 0
            ? 'Search community posts...'
            : 'Search marketplace items...';
            
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
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                  ),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePostDialog() {
    final TextEditingController postController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'Post title (optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
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
                            Navigator.of(context).pop();
                            _createPost(
                              titleController.text.trim(),
                              postController.text.trim(),
                            );
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
      },
    );
  }

  void _createPost(String title, String content) {
    // Create a new post object
    final newPost = {
      'id': _posts.length + 1,
      'user': {
        'name': 'John Doe',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=100&h=100',
        'unit': 'A-101',
      },
      'content': content,
      'title': title,
      'time': 'Just now',
      'likes': 0,
      'comments': 0,
    };

    // Add to posts list
    setState(() {
      _posts.insert(0, newPost);
      _filterContent(); // Refresh filtered list
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully'),
      ),
    );
  }

  void _showPostOptions(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
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
                'Post Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.thumb_up, color: Colors.blue),
                title: const Text('Like'),
                onTap: () {
                  Navigator.of(context).pop();
                  _likePost(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.comment, color: Colors.green),
                title: const Text('Comment'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCommentDialog(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.orange),
                title: const Text('Share'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sharePost(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.red),
                title: const Text('Report'),
                onTap: () {
                  Navigator.of(context).pop();
                  _reportPost(post);
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _likePost(Map<String, dynamic> post) {
    setState(() {
      // Find and update the post
      for (var i = 0; i < _posts.length; i++) {
        if (_posts[i]['id'] == post['id']) {
          _posts[i] = Map<String, dynamic>.from(_posts[i])
            ..['likes'] = post['likes'] + 1;
          break;
        }
      }
      _filterContent(); // Refresh filtered list
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Liked post'),
      ),
    );
  }

  void _showCommentDialog(Map<String, dynamic> post) {
    final TextEditingController _commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: _commentController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Write your comment...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_commentController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _addComment(post, _commentController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Comment'),
            ),
          ],
        );
      },
    );
  }

  void _addComment(Map<String, dynamic> post, String comment) {
    setState(() {
      // Find and update the post
      for (var i = 0; i < _posts.length; i++) {
        if (_posts[i]['id'] == post['id']) {
          _posts[i] = Map<String, dynamic>.from(_posts[i])
            ..['comments'] = post['comments'] + 1;
          break;
        }
      }
      _filterContent(); // Refresh filtered list
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment added'),
      ),
    );
  }

  void _sharePost(Map<String, dynamic> post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post shared'),
      ),
    );
  }

  void _reportPost(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: const Text('Are you sure you want to report this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Report'),
            ),
          ],
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
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.groups,
              size: 50,
              color: Color(0xFF006D77),
            ),
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
              color: Theme.of(context).cardTheme.color,
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