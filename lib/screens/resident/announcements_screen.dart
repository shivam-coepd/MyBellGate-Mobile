import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  int _selectedAnnouncement = -1;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredAnnouncements = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = ['All', 'Important', 'Event', 'Amenity', 'Maintenance'];

  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 1,
      'title': 'Water Supply Interruption',
      'date': 'Today, 10:00 AM - 2:00 PM',
      'description':
          'Due to maintenance work, there will be a water supply interruption from 10:00 AM to 2:00 PM today. We apologize for any inconvenience caused.',
      'image':
          'https://images.unsplash.com/photo-1536566482680-fca31930a0bd?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Important',
      'tagColor': Colors.red,
    },
    {
      'id': 2,
      'title': 'Annual General Meeting',
      'date': 'May 15, 6:00 PM',
      'description':
          'All residents are requested to attend the Annual General Meeting on May 15th at 6:00 PM in the community hall. Please bring your ID cards.',
      'image':
          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Event',
      'tagColor': Colors.blue,
    },
    {
      'id': 3,
      'title': 'New Gym Equipment',
      'date': 'Starting Next Week',
      'description':
          'We have installed new equipment in the community gym. The gym will be closed for one day for final setup and testing.',
      'image':
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Amenity',
      'tagColor': Colors.green,
    },
    {
      'id': 4,
      'title': 'Elevator Maintenance',
      'date': 'May 20, 9:00 AM - 5:00 PM',
      'description':
          'Elevator maintenance will be performed on May 20th from 9:00 AM to 5:00 PM. During this time, the elevator will be out of service.',
      'image':
          'https://images.unsplash.com/photo-1581091226033-d5c48150dbaa?auto=format&fit=crop&q=80&w=400&h=300',
      'tag': 'Maintenance',
      'tagColor': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredAnnouncements = _announcements;
    _searchController.addListener(_filterAnnouncements);
    
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

  void _filterAnnouncements() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();
      
      _filteredAnnouncements = _announcements.where((announcement) {
        bool matchesCategory = _selectedCategory == 'All' || 
            announcement['tag'] == _selectedCategory;
        
        bool matchesSearch = searchTerm.isEmpty || 
            announcement['title'].toLowerCase().contains(searchTerm) ||
            announcement['description'].toLowerCase().contains(searchTerm);
        
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterAnnouncements);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements', style: TextStyle(fontSize: 18.sp)),
        actions: [
          ScaleTransition(
            scale: _fadeAnimation,
            child: IconButton(
              icon: Icon(Icons.search, size: 24.sp),
              onPressed: _showSearchBar,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          // Category Filter
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              height: 50.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: _categories.map<Widget>((category) {
                  final isSelected = _selectedCategory == category;
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.1 * _categories.indexOf(category),
                          0.3 + (0.1 * _categories.indexOf(category)),
                          curve: Curves.elasticOut,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = category;
                        _filterAnnouncements();
                      }),
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Announcements List
          Expanded(
            child: _filteredAnnouncements.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      return _buildAnnouncementItem(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(int index) {
    final announcement = _filteredAnnouncements[index];
    final isSelected = _selectedAnnouncement == announcement['id'];
    
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
      child: GestureDetector(
        onTap: () => setState(() => _selectedAnnouncement = 
          _selectedAnnouncement == announcement['id'] ? -1 : announcement['id']),
        child: Card(
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
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
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: announcement['image'],
                        height: 150.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 150.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16.r),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: announcement['tagColor'],
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: announcement['tagColor'].withValues(alpha: 0.3),
                              blurRadius: 4.w,
                              offset: Offset(0, 2.h),
                            ),
                          ],
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
                      bottom: 10.h,
                      left: 10.w,
                      child: Text(
                        announcement['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              announcement['date'],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          if (!isSelected)
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey.shade600,
                              size: 24.sp,
                            )
                          else
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.grey.shade600,
                              size: 24.sp,
                            ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      if (isSelected)
                        Text(
                          announcement['description'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
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
    );
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search announcements...',
                  prefixIcon: Icon(Icons.search, size: 24.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                  ),
                  child: Text('Search', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    String selectedCategory = _selectedCategory;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Filter Announcements',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    children: _categories.map<Widget>((category) {
                      return FilterChip(
                        label: Text(category, style: TextStyle(fontSize: 14.sp)),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? category : 'All';
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Date Range',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Show date picker for start date
                          },
                          child: Text('Start Date', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Show date picker for end date
                          },
                          child: Text('End Date', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedCategory = selectedCategory;
                              _filterAnnouncements();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Filters applied', style: TextStyle(fontSize: 14.sp)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: Text('Apply', style: TextStyle(fontSize: 14.sp)),
                        ),
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

  void _showAnnouncementDetails(Map<String, dynamic> announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(announcement['title'], style: TextStyle(fontSize: 18.sp)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: announcement['tagColor'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    announcement['tag'],
                    style: TextStyle(
                      color: announcement['tagColor'],
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: announcement['image'],
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      announcement['date'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  announcement['description'],
                  style: TextStyle(
                    height: 1.5,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  void _shareAnnouncement(Map<String, dynamic> announcement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${announcement['title']}"', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  void _bookmarkAnnouncement(Map<String, dynamic> announcement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmarking "${announcement['title']}"', style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
              Icons.notifications,
              size: 50.sp,
              color: const Color(0xFF006D77),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No announcements found',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Text(
            _searchController.text.isEmpty
                ? 'There are no announcements in this category'
                : 'No announcements match your search',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}