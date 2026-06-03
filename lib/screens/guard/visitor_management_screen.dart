import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/screens/guard/details/group_visitor_entry_screen.dart';
import 'package:mygate_coepd/screens/guard/details/vendor_access_screen.dart';
import 'package:mygate_coepd/screens/guard/details/utility_vehicle_tracking_screen.dart';
import 'package:mygate_coepd/screens/guard/details/qr_scanner_screen.dart';
import 'package:mygate_coepd/screens/guard/details/qr_generator_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';

class GuardVisitorManagementScreen extends StatefulWidget {
  const GuardVisitorManagementScreen({super.key});

  @override
  State<GuardVisitorManagementScreen> createState() =>
      _VisitorManagementScreenState();
}

class _VisitorManagementScreenState
    extends State<GuardVisitorManagementScreen> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Entered',
    'Exited',
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
      'label': 'Vehicle',
      'color': Colors.orange,
      'screen': 'vehicle_tracking',
    },
  ];

  // Map tab index to API status filter
  String? get _statusFilter {
    const map = {
      1: 'pending',
      2: 'approved',
      3: 'rejected',
      4: 'entered',
      5: 'exited',
    };
    return map[_selectedIndex];
  }

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  void _loadVisitors() {
    context.read<GuardBloc>().add(
      LoadVisitors(status: _statusFilter, limit: 50),
    );
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
    context.read<GuardBloc>().add(
      LoadVisitors(
        status: (() {
          const map = {
            1: 'pending',
            2: 'approved',
            3: 'rejected',
            4: 'entered',
            5: 'exited',
          };
          return map[index];
        })(),
        limit: 50,
      ),
    );
  }

  void _handleApprove(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'approved'));
  }

  void _handleReject(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'rejected'));
  }

  void _handleMarkEntered(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'entered'));
  }

  void _handleMarkExited(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'exited'));
  }

  void _navigateToScreen(String screen) async {
    switch (screen) {
      case 'qr_scanner':
        await _openQRScanner();
        break;
      case 'group_entry':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupVisitorEntryScreen()),
        );
        break;
      case 'vendor_access':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VendorAccessScreen()),
        );
        break;
      case 'vehicle_tracking':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UtilityVehicleTrackingScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _openQRScanner() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (!mounted) return;
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerScreen()),
      );
      if (result != null && mounted) {
        _processScannedVisitor(result);
      }
    } else {
      if (!mounted) return;
      _showPermissionDialog();
    }
  }

  void _processScannedVisitor(Map<String, dynamic> data) {
    _showAddVisitorForm(prefill: data);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

  void _showAddVisitorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Visitor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.purple),
              title: const Text('Scan QR Code'),
              onTap: () {
                Navigator.pop(context);
                _openQRScanner();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.blue),
              title: const Text('Generate QR Code'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRGeneratorScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Manual Entry'),
              onTap: () {
                Navigator.pop(context);
                _showAddVisitorForm();
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
      ),
    );
  }

  void _showAddVisitorForm({Map<String, dynamic>? prefill}) {
    final nameCtrl = TextEditingController(text: prefill?['name'] ?? '');
    final phoneCtrl = TextEditingController(text: prefill?['phone'] ?? '');
    final purposeCtrl = TextEditingController(text: prefill?['purpose'] ?? '');
    final residentIdCtrl = TextEditingController();
    String visitorType = 'guest';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => BlocListener<GuardBloc, GuardState>(
        listener: (ctx, state) {
          if (state is VisitorAdded) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Visitor added successfully'),
                backgroundColor: AppTheme.success,
              ),
            );
            _loadVisitors();
          } else if (state is GuardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Visitor',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Visitor Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.length < 10)
                        ? 'Enter valid phone'
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: purposeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Purpose *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: residentIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Resident ID *',
                      border: OutlineInputBorder(),
                      hintText: 'Enter resident ID',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Resident ID is required'
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  StatefulBuilder(
                    builder: (ctx, setStateSB) =>
                        DropdownButtonFormField<String>(
                          initialValue: visitorType,
                          decoration: const InputDecoration(
                            labelText: 'Visitor Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'guest',
                              child: Text('Guest'),
                            ),
                            DropdownMenuItem(
                              value: 'delivery',
                              child: Text('Delivery'),
                            ),
                            DropdownMenuItem(
                              value: 'service',
                              child: Text('Service'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (v) =>
                              setStateSB(() => visitorType = v ?? 'guest'),
                        ),
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<GuardBloc, GuardState>(
                    builder: (ctx, state) {
                      return ElevatedButton(
                        onPressed: state is GuardLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  ctx.read<GuardBloc>().add(
                                    AddVisitor(
                                      name: nameCtrl.text.trim(),
                                      phone: phoneCtrl.text.trim(),
                                      purpose: purposeCtrl.text.trim(),
                                      visitorType: visitorType,
                                      residentId: int.tryParse(
                                        residentIdCtrl.text.trim(),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          minimumSize: Size(double.infinity, 50.h),
                        ),
                        child: state is GuardLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Add Visitor',
                                style: TextStyle(color: Colors.white),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return Scaffold(
            body: BlocConsumer<GuardBloc, GuardState>(
              listener: (context, state) {
                if (state is VisitorStatusUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated to ${state.newStatus}'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                  _loadVisitors();
                } else if (state is GuardError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                List<Map<String, dynamic>> visitors = [];
                bool isLoading = false;

                if (state is GuardLoading) {
                  isLoading = true;
                } else if (state is VisitorsLoaded) {
                  visitors = state.visitors;
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadVisitors(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Actions
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                  onTap: () =>
                                      _navigateToScreen(action['screen']),
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

                        SizedBox(height: 20.h),

                        // Category Tabs
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: ChoiceChip(
                                label: Text(_categories[index]),
                                selected: _selectedIndex == index,
                                selectedColor: AppTheme.primary,
                                onSelected: (selected) {
                                  if (selected) _onTabChanged(index);
                                },
                              ),
                            ),
                          ),
                        ),

                        const Divider(),

                        // Visitor List
                        Expanded(
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : visitors.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64.sp,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'No visitors found',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: visitors.length,
                                  itemBuilder: (context, index) =>
                                      _buildVisitorCard(visitors[index]),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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

  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    final status = visitor['status'] ?? 'pending';
    final visitorType = (visitor['visitor_type'] ?? 'guest').toString();
    final residentName = visitor['resident_name'] ?? '';

    Color statusColor;
    switch (status) {
      case 'approved':
        statusColor = AppTheme.success;
        break;
      case 'rejected':
        statusColor = AppTheme.error;
        break;
      case 'entered':
        statusColor = AppTheme.primary;
        break;
      case 'exited':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = AppTheme.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: visitor['image_url'] != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: visitor['image_url'],
                            fit: BoxFit.cover,
                            width: 50.r,
                            height: 50.r,
                          ),
                        )
                      : Icon(
                          Icons.person,
                          color: AppTheme.primary,
                          size: 28.sp,
                        ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor['name'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        visitorType.toUpperCase(),
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                      if (residentName.isNotEmpty)
                        Text(
                          'For: $residentName',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (visitor['phone'] != null)
                        Text(
                          '${visitor['phone']}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (status == 'pending') ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleReject(visitor),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(visitor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'approved') ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMarkEntered(visitor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Mark Entered',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else if (status == 'entered') ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMarkExited(visitor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Mark Exited',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
