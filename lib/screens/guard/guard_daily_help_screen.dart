import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/screens/guard/details/qr_scanner_screen.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class GuardDailyHelpScreen extends StatefulWidget {
  const GuardDailyHelpScreen({super.key});

  @override
  State<GuardDailyHelpScreen> createState() => _GuardDailyHelpScreenState();
}

class _GuardDailyHelpScreenState extends State<GuardDailyHelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HouseholdRepository _repository = HouseholdRepository();

  List<Map<String, dynamic>> _activeInsideList = [];
  List<Map<String, dynamic>> _allHelpers = [];
  List<Map<String, dynamic>> _logs = [];

  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _loading = true);
    try {
      final inside = await _repository.getActiveInsideHelpers();
      final helpers = await _repository.getDailyHelpers();
      final logs = await _repository.getDailyHelperLogs();

      if (mounted) {
        setState(() {
          _activeInsideList = inside;
          _allHelpers = helpers;
          _logs = logs;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppSnackbar.show(
          context: context,
          message: 'Error loading daily helpers: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _openScanAndProcess() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      AppSnackbar.show(
        context: context,
        message: 'Camera permission is required to scan QR',
        type: SnackBarType.error,
      );
      return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null && mounted) {
      final qrCode = result['qr_code']?.toString() ?? '';
      if (qrCode.isNotEmpty) {
        _processScannedCode(qrCode);
      }
    }
  }

  Future<void> _processScannedCode(String qrCode) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await _repository.scanDailyHelperQr(qrCode);
      if (mounted) Navigator.pop(context); // pop loading

      final action = res['action']?.toString() ?? 'recorded';
      final helper = res['helper'] as Map<String, dynamic>? ?? {};
      final name = helper['name'] ?? 'Worker';
      final flat = helper['flat_number'] ?? '';
      final service = helper['service_type'] ?? 'Help';

      _showScanSuccessDialog(
        action: action,
        name: name,
        service: service,
        flatNumber: flat,
      );

      _loadAllData();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading
        AppSnackbar.show(
          context: context,
          message: 'Scan Failed: ${e.toString().replaceFirst("Exception: ", "")}',
          type: SnackBarType.error,
        );
      }
    }
  }

  void _showScanSuccessDialog({
    required String action,
    required String name,
    required String service,
    required String flatNumber,
  }) {
    final isEntry = action == 'entered';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(
              isEntry ? Icons.login : Icons.logout,
              color: isEntry ? Colors.green : Colors.orange,
              size: 28.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              isEntry ? 'Entry Registered' : 'Exit Registered',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              '$service • Flat $flatNumber',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isEntry ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                isEntry
                    ? 'Worker has been checked IN at gate. Resident has been notified.'
                    : 'Worker has been checked OUT. Exit timestamp recorded.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isEntry ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEntry ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleManualExit(int logId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Manual Exit'),
        content: Text('Mark exit for $name without scanning QR?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Mark Exit'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _repository.manualExitHelper(logId);
        AppSnackbar.show(
          context: context,
          message: '$name marked as exited',
          type: SnackBarType.success,
        );
        _loadAllData();
      } catch (e) {
        AppSnackbar.show(
          context: context,
          message: 'Error: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Help & Static QR'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _openScanAndProcess,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Gate Pass',
          ),
          IconButton(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Inside (${_activeInsideList.length})'),
            Tab(text: 'All Helpers (${_allHelpers.length})'),
            const Tab(text: 'Scan Logs'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanAndProcess,
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR Pass'),
      ),
      body: _loading
          ? _buildDailyHelpListShimmer()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveInsideTab(),
                _buildAllHelpersTab(),
                _buildLogsTab(),
              ],
            ),
    );
  }

  Widget _buildActiveInsideTab() {
    if (_activeInsideList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 48.sp, color: Colors.green),
            SizedBox(height: 12.h),
            Text(
              'No daily helpers inside right now',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              'Scan a helper QR code to check them in',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _activeInsideList.length,
      itemBuilder: (context, index) {
        final item = _activeInsideList[index];
        final logId = int.tryParse(item['id']?.toString() ?? '') ?? 0;
        final name = item['helper_name'] ?? 'Helper';
        final phone = item['helper_phone'] ?? '';
        final service = item['service_type'] ?? 'Service';
        final flat = item['flat_number'] ?? '';
        final building = item['building_name'] ?? '';
        final entryTime = item['entry_time'] ?? '';

        String formattedTime = entryTime;
        try {
          final dt = DateTime.parse(entryTime);
          formattedTime = DateFormat('hh:mm a (dd MMM)').format(dt);
        } catch (_) {}

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'W',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$service • Flat ${building.isNotEmpty ? "$building - " : ""}$flat${phone.isNotEmpty ? " • $phone" : ""}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Entered: $formattedTime',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _handleManualExit(logId, name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllHelpersTab() {
    final filtered = _allHelpers.where((h) {
      final name = (h['name'] ?? '').toString().toLowerCase();
      final phone = (h['phone'] ?? '').toString();
      final flat = (h['flat_number'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || phone.contains(q) || flat.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(12.w),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by helper name, phone or flat...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No helpers found'))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final h = filtered[index];
                    final name = h['name'] ?? 'Helper';
                    final service = h['service_type'] ?? 'Service';
                    final phone = h['phone'] ?? '';
                    final flat = h['flat_number'] ?? '';
                    final isInside = h['current_status'] == 'inside';

                    return Card(
                      margin: EdgeInsets.only(bottom: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'H',
                            style: TextStyle(
                              color: Colors.purple.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('$service • Flat $flat\nPhone: $phone'),
                        isThreeLine: true,
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isInside
                                ? Colors.green.withOpacity(0.15)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            isInside ? 'Inside' : 'Outside',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isInside ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    if (_logs.isEmpty) {
      return const Center(child: Text('No scan logs recorded'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        final name = log['helper_name'] ?? 'Worker';
        final service = log['service_type'] ?? '';
        final flat = log['flat_number'] ?? '';
        final entryTime = log['entry_time'] ?? '';
        final exitTime = log['exit_time'] ?? '';
        final isInside = log['status'] == 'inside';

        return Card(
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          child: ListTile(
            leading: Icon(
              isInside ? Icons.login : Icons.logout,
              color: isInside ? Colors.green : Colors.grey,
            ),
            title: Text('$name ($service)', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Flat $flat\nIn: $entryTime\nOut: ${exitTime.isNotEmpty ? exitTime : "Inside"}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildDailyHelpListShimmer() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor =
        isDark ? const Color(0xFF334155) : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 15.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 160.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 100.w,
                          height: 11.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 60.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
