import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() =>
      _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen>
    with TickerProviderStateMixin {
  String _visitorView = 'upcoming';
  bool _showAddVisitor = false;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  MobileScannerController? _cameraController;

  final List<Map<String, dynamic>> _upcomingVisitors = [
    {
      'id': 1,
      'name': 'John Smith',
      'purpose': 'Delivery',
      'date': 'Today, 2:00 PM',
      'status': 'approved',
      'photo':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Sarah Johnson',
      'purpose': 'Guest',
      'date': 'Today, 5:30 PM',
      'status': 'pending',
      'photo':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 3,
      'name': 'Mike Williams',
      'purpose': 'Maintenance',
      'date': 'Tomorrow, 10:00 AM',
      'status': 'approved',
      'photo':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final List<Map<String, dynamic>> _visitorHistory = [
    {
      'id': 4,
      'name': 'David Brown',
      'purpose': 'Guest',
      'date': 'Yesterday, 7:00 PM',
      'entryTime': '7:02 PM',
      'exitTime': '9:45 PM',
      'photo':
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 5,
      'name': 'Emma Davis',
      'purpose': 'Delivery',
      'date': 'May 10, 11:30 AM',
      'entryTime': '11:32 AM',
      'exitTime': '11:40 AM',
      'photo':
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialize the camera controller for QR scanning
    _cameraController = MobileScannerController();

    // Start animations after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  Widget _renderVisitorStatus(String status) {
    switch (status) {
      case 'approved':
        return Row(
          children: [
            Icon(Icons.check_circle, size: 14.sp, color: Colors.green),
            SizedBox(width: 4.w),
            Text(
              'Approved',
              style: TextStyle(color: Colors.green, fontSize: 12.sp),
            ),
          ],
        );
      case 'pending':
        return Row(
          children: [
            Icon(Icons.access_time, size: 14.sp, color: Colors.orange),
            SizedBox(width: 4.w),
            Text(
              'Pending',
              style: TextStyle(color: Colors.orange, fontSize: 12.sp),
            ),
          ],
        );
      case 'denied':
        return Row(
          children: [
            Icon(Icons.cancel, size: 14.sp, color: Colors.red),
            SizedBox(width: 4.w),
            Text(
              'Denied',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search visitors...',
                        prefixIcon: Icon(Icons.search, size: 24.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, size: 24.sp),
                    onPressed: () {
                      _showFilterOptions();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _visitorView = 'upcoming'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _visitorView == 'upcoming'
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardTheme.color,
                      foregroundColor: _visitorView == 'upcoming'
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text('Upcoming', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _visitorView = 'history'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _visitorView == 'history'
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardTheme.color,
                      foregroundColor: _visitorView == 'history'
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
          SizedBox(height: 20.h),
          Expanded(
            child: _visitorView == 'upcoming'
                ? _buildUpcomingVisitors()
                : _buildVisitorHistory(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVisitorForm,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  Widget _buildUpcomingVisitors() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _upcomingVisitors.length,
      itemBuilder: (context, index) {
        final visitor = _upcomingVisitors[index];
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 * index,
                0.5 + (0.1 * index),
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
                    Theme.of(context).cardTheme.color!.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2.w,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 25.r,
                        backgroundImage: CachedNetworkImageProvider(
                          visitor['photo'],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visitor['name'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              visitor['purpose'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                visitor['date'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _renderVisitorStatus(visitor['status']),
                        SizedBox(height: 8.h),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                            size: 24.sp,
                          ),
                          onSelected: (value) {
                            if (value == 'details') {
                              _showVisitorDetails(visitor);
                            } else if (value == 'edit') {
                              _showEditVisitorDialog(visitor);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(visitor);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'details',
                              child: Text('View Details', style: TextStyle(fontSize: 14.sp)),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit', style: TextStyle(fontSize: 14.sp)),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(fontSize: 14.sp)),
                            ),
                          ],
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

  Widget _buildVisitorHistory() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _visitorHistory.length,
      itemBuilder: (context, index) {
        final visitor = _visitorHistory[index];
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.1 * index,
                0.5 + (0.1 * index),
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.r,
                    backgroundImage: CachedNetworkImageProvider(
                      visitor['photo'],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visitor['name'],
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          visitor['purpose'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          visitor['date'],
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              'In: ${visitor['entryTime']}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Out: ${visitor['exitTime']}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info, size: 24.sp),
                    onPressed: () {
                      _showVisitorDetails(visitor);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Visitors',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                children: [
                  FilterChip(
                    label: Text('Approved', style: TextStyle(fontSize: 14.sp)),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('Pending', style: TextStyle(fontSize: 14.sp)),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: Text('Denied', style: TextStyle(fontSize: 14.sp)),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                ],
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
                      onPressed: () {},
                      child: Text('Start Date', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Filters applied', style: TextStyle(fontSize: 14.sp))),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D77),
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
  }

  void _showAddVisitorForm() {
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
              Text(
                'Add New Visitor',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Visitor Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Purpose of Visit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Expected Date & Time',
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
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Visitor added successfully', style: TextStyle(fontSize: 14.sp)),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D77),
                      ),
                      child: Text('Add Visitor', style: TextStyle(fontSize: 14.sp)),
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

  void _showVisitorOptions(Map<String, dynamic> visitor) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Visitor Options',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: Icon(Icons.edit, size: 24.sp),
                title: Text('Edit Visitor', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditVisitorDialog(visitor);
                },
              ),
              ListTile(
                leading: Icon(Icons.qr_code, size: 24.sp),
                title: Text('Show QR Code', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showVisitorQRCode(visitor);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, size: 24.sp),
                title: Text('Delete Visitor', style: TextStyle(fontSize: 16.sp)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmation(visitor);
                },
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditVisitorDialog(Map<String, dynamic> visitor) {
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
              Text(
                'Edit Visitor',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: TextEditingController(text: visitor['name']),
                decoration: InputDecoration(
                  hintText: 'Visitor Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: TextEditingController(text: visitor['purpose']),
                decoration: InputDecoration(
                  hintText: 'Purpose of Visit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: TextEditingController(text: visitor['date']),
                decoration: InputDecoration(
                  hintText: 'Expected Date & Time',
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
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Visitor updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D77),
                      ),
                      child: Text('Save Changes', style: TextStyle(fontSize: 14.sp)),
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

  void _showVisitorDetails(Map<String, dynamic> visitor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Visitor Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider(visitor['photo']),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Name:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(visitor['name']),
                const SizedBox(height: 8),
                const Text(
                  'Purpose:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(visitor['purpose']),
                const SizedBox(height: 8),
                const Text(
                  'Date:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(visitor['date']),
                if (visitor.containsKey('entryTime'))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Entry Time:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(visitor['entryTime']),
                    ],
                  ),
                if (visitor.containsKey('exitTime'))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Exit Time:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(visitor['exitTime']),
                    ],
                  ),
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

  void _showDeleteConfirmation(Map<String, dynamic> visitor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Visitor'),
          content: Text('Are you sure you want to delete ${visitor['name']}?'),
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
                    content: Text('Visitor deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _scanQRCode() {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR scanning is not supported on web platform'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Scan Visitor QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: MobileScanner(
                  controller: _cameraController,
                  fit: BoxFit.contain,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _processScannedQRCode(barcode.rawValue!);
                        Navigator.of(context).pop();
                        return;
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _processScannedQRCode(String qrCode) {
    // Show a dialog with the scanned information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Visitor QR Code Scanned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Visitor Details:'),
              const SizedBox(height: 10),
              Text('QR Code: $qrCode'),
              const SizedBox(height: 10),
              const Text('Name: John Smith'),
              const Text('Purpose: Delivery'),
              const Text('Expected Time: 2:00 PM'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visitor entry approved'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Approve Entry'),
            ),
          ],
        );
      },
    );
  }

  void _showVisitorQRCode(Map<String, dynamic> visitor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Visitor QR Code',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // QR Code display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: 'Visitor:${visitor['id']}:${visitor['name']}',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                visitor['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                visitor['date'],
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Camera access is required to scan QR codes. Please grant permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }
}

class _QRScannerPage extends StatefulWidget {
  const _QRScannerPage();

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool flashOn = false;
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              controller.toggleTorch();
              setState(() {
                flashOn = !flashOn;
              });
            },
            icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasScanned ? 'QR Code Detected!' : 'Point camera at QR code',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.stop(),
                          child: const Text('Pause'),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.start(),
                          child: const Text('Resume'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (hasScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          hasScanned = true;
        });
        _processQRCode(barcode.rawValue!);
      }
    }
  }

  void _processQRCode(String qrData) {
    controller.stop();
    
    Navigator.pop(context, qrData);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
