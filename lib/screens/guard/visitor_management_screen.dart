import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/screens/guard/details/group_visitor_entry_screen.dart';
import 'package:mygate_coepd/screens/guard/details/vendor_access_screen.dart';
import 'package:mygate_coepd/screens/guard/details/utility_vehicle_tracking_screen.dart';
import 'package:mygate_coepd/screens/guard/details/qr_scanner_screen.dart';
import 'package:mygate_coepd/screens/guard/details/qr_generator_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() =>
      _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> {
  int _selectedIndex = 0;
  bool _isOffline = false;

  final List<Map<String, dynamic>> _visitors = [
    {
      'id': 1,
      'name': 'John Doe',
      'type': 'QR Scanned',
      'flat': 'A-101',
      'time': '10:30 AM',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
      'status': 'approved',
      'phone': '+91 9876543210',
      'purpose': 'Delivery',
      'qrScanned': true,
    },
    {
      'id': 2,
      'name': 'Rahul Kumar',
      'type': 'Delivery',
      'flat': 'A-101',
      'time': '10:15 AM',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
      'status': 'pending',
    },
    {
      'id': 3,
      'name': 'Jane Smith',
      'type': 'QR Scanned',
      'flat': 'B-203',
      'time': '10:05 AM',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
      'status': 'pending',
      'phone': '+91 8765432109',
      'purpose': 'Guest Visit',
      'qrScanned': true,
    },
    {
      'id': 4,
      'name': 'Amit Patel',
      'type': 'Service',
      'flat': 'C-105',
      'time': '9:45 AM',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
      'status': 'rejected',
    },
  ];

  final List<Map<String, dynamic>> _frequentVisitors = [
    {
      'id': 1,
      'name': 'School Bus',
      'type': 'Transport',
      'vehicle': 'MH-01 AB 1234',
      'frequency': 'Daily',
      'image':
          'https://images.unsplash.com/photo-1541899481282-d53b200c8f53?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Milkman',
      'type': 'Service',
      'vehicle': 'NA',
      'frequency': 'Daily',
      'image':
          'https://images.unsplash.com/photo-1541899481282-d53b200c8f53?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 3,
      'name': 'Water Tanker',
      'type': 'Utility',
      'vehicle': 'MH-02 CD 5678',
      'frequency': 'Weekly',
      'image':
          'https://images.unsplash.com/photo-1541899481282-d53b200c8f53?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final List<String> _categories = [
    'All Visitors',
    'Pending Approval',
    'Approved',
    'Rejected',
    'Frequent Visitors',
    'Group Entry',
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.qr_code_scanner,
      'label': 'QR Scanner',
      'color': Colors.purple,
      'screen': 'qr_scanner',
    },
    {
      'icon': Icons.group,
      'label': 'Group Entry',
      'color': Colors.blue,
      'screen': 'group_entry',
    },
    {
      'icon': Icons.build,
      'label': 'Vendor Access',
      'color': Colors.green,
      'screen': 'vendor_access',
    },
    {
      'icon': Icons.directions_car,
      'label': 'Vehicle Tracking',
      'color': Colors.orange,
      'screen': 'vehicle_tracking',
    },
  ];

  void _handleApprove(int id) {
    setState(() {
      final visitorIndex = _visitors.indexWhere((v) => v['id'] == id);
      if (visitorIndex != -1) {
        _visitors[visitorIndex]['status'] = 'approved';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visitor approved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleReject(int id) {
    setState(() {
      final visitorIndex = _visitors.indexWhere((v) => v['id'] == id);
      if (visitorIndex != -1) {
        _visitors[visitorIndex]['status'] = 'rejected';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visitor rejected'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddVisitorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Visitor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.purple,
                ),
                title: const Text('Scan QR Code'),
                subtitle: const Text('Scan visitor QR code'),
                onTap: () {
                  Navigator.pop(context);
                  _openQRScanner();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.blue),
                title: const Text('Generate QR Code (Demo)'),
                subtitle: const Text('Create demo QR codes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRGeneratorScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('Manual Entry'),
                subtitle: const Text('Add visitor manually'),
                onTap: () {
                  Navigator.pop(context);
                  // Manual entry form would go here
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToScreen(String screen) async {
    switch (screen) {
      case 'qr_scanner':
        await _openQRScanner();
        break;
      case 'group_entry':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GroupVisitorEntryScreen(),
          ),
        );
        break;
      case 'vendor_access':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VendorAccessScreen()),
        );
        break;
      case 'vehicle_tracking':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UtilityVehicleTrackingScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _openQRScanner() async {
    // Check camera permission
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );

      if (result != null) {
        _processScannedVisitor(result);
      }
    } else {
      _showPermissionDialog();
    }
  }

  void _processScannedVisitor(Map<String, dynamic> visitorData) {
    // Add scanned visitor to the list
    setState(() {
      _visitors.insert(0, {
        'id': _visitors.length + 1,
        'name': visitorData['name'],
        'type': 'QR Scanned',
        'flat': 'Scanning...',
        'time': DateTime.now().toString().substring(11, 16),
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
        'status': 'pending',
        'phone': visitorData['phone'],
        'purpose': visitorData['purpose'],
        'qrScanned': true,
      });
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Visitor ${visitorData['name']} scanned successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
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
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            body: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h),
              child: SingleChildScrollView(
                // physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offline Banner
                    if (_isOffline)
                      Container(
                        padding: EdgeInsets.all(10.w),
                        color: Colors.amber,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.wifi_off, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Offline Mode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isOffline = false;
                                });
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 15.w,
                        mainAxisSpacing: 15.h,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: _quickActions.length,
                      itemBuilder: (context, index) {
                        final action = _quickActions[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToScreen(action['screen']),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: action['color'],
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: action['color'].withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10.w,
                                      offset: Offset(0, 5.h),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  action['icon'],
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              action['label'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),

                    // Category Tabs
                    SizedBox(height: 20.h),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: ChoiceChip(
                              label: Text(_categories[index]),
                              selected: _selectedIndex == index,
                              selectedColor: AppTheme.primary,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedIndex = selected ? index : 0;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    // Visitor Lists
                    _selectedIndex == 4
                        ? _buildFrequentVisitorsList()
                        : _buildVisitorList(),
                  ],
                ),
              ),
            ),

            // Floating Action Button
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _showAddVisitorDialog,
              backgroundColor: AppTheme.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Visitor',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildVisitorList() {
    return ListView.builder(
      // padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _visitors.length,
      itemBuilder: (context, index) {
        final visitor = _visitors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundImage: CachedNetworkImageProvider(
                        visitor['image'],
                      ),
                    ),
                    SizedBox(width: 15.w),
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
                          const SizedBox(height: 5),
                          Text(
                            visitor['type'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'For: ${visitor['flat']} • ${visitor['time']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (visitor['qrScanned'] == true) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 14.sp,
                                  color: Colors.purple,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'QR Scanned',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (visitor['phone'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${visitor['phone']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          if (visitor['purpose'] != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Purpose: ${visitor['purpose']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: visitor['status'] == 'approved'
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : visitor['status'] == 'rejected'
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              visitor['status'].toString().toUpperCase(),
                              style: TextStyle(
                                color: visitor['status'] == 'approved'
                                    ? Colors.green
                                    : visitor['status'] == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (visitor['status'] == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _handleReject(visitor['id']);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _handleApprove(visitor['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrequentVisitorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _frequentVisitors.length,
      itemBuilder: (context, index) {
        final visitor = _frequentVisitors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(visitor['image']),
            ),
            title: Text(
              visitor['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${visitor['type']} • ${visitor['vehicle']}'),
                Text('Frequency: ${visitor['frequency']}'),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Quick entry action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: const Text('Entry', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}
