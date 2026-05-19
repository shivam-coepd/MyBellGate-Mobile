import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'requests';
  final bool _showNewRequest = false;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredActiveRequests = [];
  List<Map<String, dynamic>> _filteredRequestHistory = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'id': 1,
      'name': 'Plumbing',
      'icon': Icons.water_damage,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'name': 'Electrical',
      'icon': Icons.electrical_services,
      'color': Colors.orange,
    },
    {
      'id': 3,
      'name': 'Carpentry',
      'icon': Icons.construction,
      'color': Colors.brown,
    },
    {
      'id': 4,
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.green,
    },
    {'id': 5, 'name': 'Security', 'icon': Icons.security, 'color': Colors.red},
    {
      'id': 6,
      'name': 'Other',
      'icon': Icons.miscellaneous_services,
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _activeRequests = [
    {
      'id': 1,
      'title': 'Leaking Tap in Kitchen',
      'category': 'Plumbing',
      'status': 'In Progress',
      'date': 'May 10, 2023',
      'assignedTo': 'Raj Kumar',
      'image':
          'https://images.unsplash.com/photo-1584432411103-09445f0b0d7d?auto=format&fit=crop&q=80&w=100&h=100',
      'description':
          'Kitchen tap is leaking continuously and needs immediate attention.',
    },
    {
      'id': 2,
      'title': 'Faulty Light Switch',
      'category': 'Electrical',
      'status': 'Pending',
      'date': 'May 12, 2023',
      'assignedTo': 'Not Assigned',
      'image':
          'https://images.unsplash.com/photo-1594787311429-9f55e88945b3?auto=format&fit=crop&q=80&w=100&h=100',
      'description': 'Light switch in the living room is not working properly.',
    },
  ];

  final List<Map<String, dynamic>> _requestHistory = [
    {
      'id': 3,
      'title': 'Broken Door Handle',
      'category': 'Carpentry',
      'status': 'Completed',
      'date': 'May 5, 2023',
      'assignedTo': 'Amit Sharma',
      'image':
          'https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?auto=format&fit=crop&q=80&w=100&h=100',
      'description': 'Main entrance door handle was broken and has been fixed.',
    },
    {
      'id': 4,
      'title': 'Monthly Cleaning',
      'category': 'Cleaning',
      'status': 'Completed',
      'date': 'April 28, 2023',
      'assignedTo': 'CleanCo Services',
      'image':
          'https://images.unsplash.com/photo-1581578021424-ebdc007b8d4d?auto=format&fit=crop&q=80&w=100&h=100',
      'description': 'Monthly deep cleaning of the apartment completed.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredActiveRequests = _activeRequests;
    _filteredRequestHistory = _requestHistory;
    _searchController.addListener(_filterRequests);

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

  void _filterRequests() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();

      _filteredActiveRequests = _activeRequests.where((request) {
        return searchTerm.isEmpty ||
            request['title'].toLowerCase().contains(searchTerm) ||
            request['category'].toLowerCase().contains(searchTerm) ||
            request['status'].toLowerCase().contains(searchTerm);
      }).toList();

      _filteredRequestHistory = _requestHistory.where((request) {
        return searchTerm.isEmpty ||
            request['title'].toLowerCase().contains(searchTerm) ||
            request['category'].toLowerCase().contains(searchTerm) ||
            request['status'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRequests);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
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
        title: Text(
          'Services Management',
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 3));
        },
        child: Column(
          children: [
            // Tab Selection
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          setState(() => _selectedTab = 'requests'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 'requests'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardTheme.color,
                        foregroundColor: _selectedTab == 'requests'
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Active Requests',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selectedTab = 'history'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 'history'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardTheme.color,
                        foregroundColor: _selectedTab == 'history'
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('History', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                spacing: 20.w,
                children: _serviceCategories.map((category) {
                  return _buildServiceCategoryItem(category);
                }).toList(),
              ),
            ),
            SizedBox(height: 16.h),
            // Requests List
            Expanded(
              child: _selectedTab == 'requests'
                  ? _buildActiveRequests()
                  : _buildRequestHistory(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewRequestForm,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  Widget _buildServiceCategoryItem(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // handle click
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ICON CONTAINER
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: category['color'].withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: category['color'].withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Icon(
              category['icon'],
              color: category['color'],
              size: 24.sp,
            ),
          ),

          SizedBox(height: 4.h),

          /// LABEL
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 70.w),
            child: Text(
              category['name'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRequests() {
    return _filteredActiveRequests.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 70.h),
            itemCount: _filteredActiveRequests.length,
            itemBuilder: (context, index) {
              final request = _filteredActiveRequests[index];
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
                  elevation: 4,
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
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: _getServiceColor(
                                    request['category'],
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: _getServiceColor(
                                      request['category'],
                                    ).withValues(alpha: 0.3),
                                    width: 1.w,
                                  ),
                                ),
                                child: Icon(
                                  _getServiceIcon(request['category']),
                                  color: _getServiceColor(request['category']),
                                  size: 24.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request['title'],
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getServiceColor(
                                          request['category'],
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        request['category'],
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: _getServiceColor(
                                            request['category'],
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                  color: _getStatusColor(request['status']),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  request['status'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
                                request['date'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Icon(
                                Icons.person,
                                size: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                request['assignedTo'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            request['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  _showRequestDetails(request);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                child: Text(
                                  'View Details',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              ElevatedButton(
                                onPressed: () {
                                  _showEditRequestDialog(request);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                child: Text(
                                  'Edit',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildRequestHistory() {
    return _filteredRequestHistory.isEmpty
        ? _buildEmptyHistoryState()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _filteredRequestHistory.length,
            itemBuilder: (context, index) {
              final request = _filteredRequestHistory[index];
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
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: _getServiceColor(
                                  request['category'],
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                _getServiceIcon(request['category']),
                                color: _getServiceColor(request['category']),
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request['title'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    request['category'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.sp,
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
                                color: _getStatusColor(request['status']),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                request['status'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info, size: 24.sp),
                              onPressed: () {
                                _showRequestDetails(request);
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              request['date'],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Icon(Icons.person, size: 16.sp, color: Colors.grey),
                            SizedBox(width: 8.w),
                            Text(
                              request['assignedTo'],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildEmptyState() {
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
              Icons.checklist,
              size: 50,
              color: Color(0xFF006D77),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Active Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'You don\'t have any active service requests'
                : 'No active requests match your search',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showNewRequestDialog(),
            child: const Text('Create New Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
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
              Icons.history,
              size: 50,
              color: Color(0xFF006D77),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Request History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'You don\'t have any service request history'
                : 'No history matches your search',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String category) {
    for (var service in _serviceCategories) {
      if (service['name'] == category) {
        return service['color'];
      }
    }
    return Colors.grey;
  }

  IconData _getServiceIcon(String category) {
    for (var service in _serviceCategories) {
      if (service['name'] == category) {
        return service['icon'];
      }
    }
    return Icons.help;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showSearchBar() {
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
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search service requests...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
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

  void _showFilterOptions() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Service Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  FilterChip(
                    label: const Text('Pending'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('In Progress'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Completed'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _serviceCategories.map((category) {
                  return FilterChip(
                    label: Text(category['name']),
                    selected: false,
                    onSelected: (selected) {},
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Date Range',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start Date'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('End Date'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filters applied')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D77),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNewRequestDialog() {
    String? selectedCategory = _serviceCategories[0]['name'];

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
                  const Text(
                    'Create New Service Request',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Request Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    value: selectedCategory,
                    items: _serviceCategories.map<DropdownMenuItem<String>>((
                      category,
                    ) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Service request created successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006D77),
                          ),
                          child: const Text('Submit Request'),
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

  void _showRequestOptions(Map<String, dynamic> request) {
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
                'Service Request Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRequestDetails(request);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('Edit Request'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditRequestDialog(request);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel Request'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCancelConfirmation(request);
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

  void _showCancelConfirmation(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Service Request'),
          content: Text(
            'Are you sure you want to cancel the service request "${request['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Update request status to cancelled
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service request cancelled')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Service Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getServiceColor(
                          request['category'],
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getServiceIcon(request['category']),
                        color: _getServiceColor(request['category']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            request['category'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request['status']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request['status'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  request['description'],
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      request['date'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Assigned to: ${request['assignedTo']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                if (request['image'] != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: request['image'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEditRequestDialog(Map<String, dynamic> request) {
    String? selectedCategory = request['category'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                  Text(
                    'Edit Service Request',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: TextEditingController(text: request['title']),
                    decoration: InputDecoration(
                      hintText: 'Request Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      ),
                    ),
                    value: selectedCategory,
                    items: _serviceCategories.map<DropdownMenuItem<String>>((
                      category,
                    ) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(
                          category['name'],
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: TextEditingController(
                      text: request['description'] ?? '',
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Service request updated successfully',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006D77),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 14.sp),
                          ),
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

  void _showNewRequestForm() {
    String? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                  Text(
                    'New Service Request',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Request Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      ),
                    ),
                    value: selectedCategory,
                    items: _serviceCategories.map<DropdownMenuItem<String>>((
                      category,
                    ) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(
                          category['name'],
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Service request submitted successfully',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006D77),
                          ),
                          child: Text(
                            'Submit Request',
                            style: TextStyle(fontSize: 14.sp),
                          ),
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
}
