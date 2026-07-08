import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class OfflineModeScreen extends StatefulWidget {
  const OfflineModeScreen({super.key});

  @override
  State<OfflineModeScreen> createState() => _OfflineModeScreenState();
}

class _OfflineModeScreenState extends State<OfflineModeScreen> {
  bool _isOfflineMode = true;
  int _pendingSync = 5;
  final int _totalEntries = 12;

  final List<Map<String, dynamic>> _offlineEntries = [
    {
      'id': 1,
      'name': 'Rahul Kumar',
      'type': 'Delivery',
      'flat': 'A-101',
      'time': '10:15 AM',
      'status': 'pending',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'type': 'Guest',
      'flat': 'B-203',
      'time': '10:05 AM',
      'status': 'pending',
    },
    {
      'id': 3,
      'name': 'Amit Patel',
      'type': 'Service',
      'flat': 'C-105',
      'time': '9:45 AM',
      'status': 'pending',
    },
  ];

  void _syncData() {
    AppSnackbar.show(
      context: context,
      message: 'Syncing data with server...',
      type: SnackBarType.info,
    );

    // Simulate sync process
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _pendingSync = 0;
      });
      AppSnackbar.show(
        context: context,
        message: 'Data synced successfully!',
        type: SnackBarType.success,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(title: const Text('Offline Mode')),
            body: RefreshIndicator(
              onRefresh: () async {
                bool isConnected = await AppInternetCheck().hasInternetConnection();
                if (isConnected) {
                  if (context.mounted) {
                    AppSnackbar.show(
                      context: context,
                      message: 'Internet connection is active. Ready to sync!',
                      type: SnackBarType.success,
                    );
                  }
                } else {
                  if (context.mounted) {
                    AppInternetCheck.checkInternet(context: context);
                  }
                }
                if (mounted) setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offline Mode Status
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Offline Mode',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Switch(
                                value: _isOfflineMode,
                                onChanged: (value) {
                                  setState(() {
                                    _isOfflineMode = value;
                                  });
                                },
                                activeThumbColor: AppTheme.primary,
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: _isOfflineMode
                                  ? AppTheme.secondary.withValues(alpha: 0.2)
                                  : AppTheme.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isOfflineMode ? Icons.wifi_off : Icons.wifi,
                                  color: _isOfflineMode
                                      ? AppTheme.secondary
                                      : AppTheme.success,
                                  size: 30.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isOfflineMode
                                            ? 'Offline Mode Active'
                                            : 'Online Mode Active',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: _isOfflineMode
                                              ? AppTheme.secondary
                                              : AppTheme.success,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(
                                        _isOfflineMode
                                            ? 'Data will be synced when connection is restored'
                                            : 'All data is being synced in real-time',
                                        style: TextStyle(fontSize: 13.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Sync Status
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sync Status',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusCard(
                                'Total Entries',
                                _totalEntries.toString(),
                              ),
                              _buildStatusCard(
                                'Pending Sync',
                                _pendingSync.toString(),
                              ),
                              _buildStatusCard(
                                'Synced',
                                (_totalEntries - _pendingSync).toString(),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          if (_pendingSync > 0)
                            ElevatedButton(
                              onPressed: _syncData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Sync Now',
                                style: TextStyle(color: AppTheme.onPrimary),
                              ),
                            )
                          else
                            const Center(
                              child: Text(
                                'All data synced successfully!',
                                style: TextStyle(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Offline Entries
                  Text(
                    'Offline Entries',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _offlineEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _offlineEntries[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 15.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry['name'],
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondary.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Pending Sync',
                                      style: TextStyle(
                                        color: AppTheme.secondary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                '${entry['type']} • ${entry['flat']}',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'Entry Time: ${entry['time']}',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              SizedBox(height: 15.h),
                              Text(
                                'Details:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                '• Photo captured: Yes\n'
                                '• Temperature: 36.8°C\n'
                                '• Mask compliance: Yes\n'
                                '• Approved by: Self',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),
                  // Offline Mode Info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline Mode Features',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Text(
                            '• Continue logging entries without internet connection\n'
                            '• All data is stored locally on device\n'
                            '• Automatic sync when connection is restored\n'
                            '• No data loss during network issues\n'
                            '• Real-time functionality resumes when online',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildStatusCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        SizedBox(height: 5.h),
        Text(label),
      ],
    );
  }
}
