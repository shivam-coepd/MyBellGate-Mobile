import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GuardBloc>().add(const LoadGuardAttendance());
  }

  void _markIn() {
    context.read<GuardBloc>().add(const MarkAttendance('in'));
  }

  void _markOut() {
    context.read<GuardBloc>().add(const MarkAttendance('out'));
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = DateTime.parse(ts.toString());
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return ts.toString();
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = DateTime.parse(ts.toString());
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return ts.toString();
    }
  }

  double _shiftProgress(Map<String, dynamic>? today) {
    if (today == null || today['in_time'] == null) return 0.0;
    try {
      final inTime = DateTime.parse(today['in_time'].toString());
      final now = DateTime.now();
      final elapsed = now.difference(inTime).inMinutes.clamp(0, 480);
      return elapsed / 480; // 8-hour shift = 480 min
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GuardBloc, GuardState>(
      listener: (context, state) async {
        if (state is AttendanceMarked) {
          AppSnackbar.show(
            context: context,
            message: state.type == 'in'
                ? 'Check-in marked successfully'
                : 'Check-out marked successfully',
            type: SnackBarType.success,
          );
          context.read<GuardBloc>().add(const LoadGuardAttendance());
        } else if (state is GuardError) {
          if (await AppInternetCheck().hasInternetConnection()) {
            AppSnackbar.show(
              context: context,
              message: "Can't load data now. Please try again later.",
              type: SnackBarType.error,
            );
          } else {
            AppInternetCheck.checkInternet(context: context);
          }
          // Reload even on error to keep UI consistent
          // context.read<GuardBloc>().add(const LoadGuardAttendance());
        }
      },
      builder: (context, state) {
        Map<String, dynamic>? today;
        List<Map<String, dynamic>> history = [];
        final isLoading = state is GuardLoading;

        if (state is AttendanceLoaded) {
          today = state.todayRecord;
          history = state.history;
        }

        final hasCheckedIn = today != null && today['in_time'] != null;
        final hasCheckedOut = today != null && today['out_time'] != null;
        final progress = _shiftProgress(today);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              if (await AppInternetCheck().hasInternetConnection()) {
                context.read<GuardBloc>().add(const LoadGuardAttendance());
              } else {
                AppInternetCheck.checkInternet(context: context);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
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
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      // _quickAction(
                      //   icon: Icons.directions_walk,
                      //   label: 'Patrolling',
                      //   color: AppTheme.primary,
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) => const GuardPatrollingScreen(),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(width: 16.w),
                      _quickAction(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan QR',
                        color: AppTheme.success,
                        onTap: () => AppSnackbar.show(
                          context: context,
                          message: 'Use Visitor Management > QR Scanner',
                          type: SnackBarType.info,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Today's Attendance
                  Text(
                    "Today's Attendance",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _statItem(
                                      'In Time',
                                      _formatTime(today?['in_time']),
                                    ),
                                    _statItem(
                                      'Out Time',
                                      _formatTime(today?['out_time']),
                                    ),
                                    _statItem(
                                      'Status',
                                      hasCheckedIn
                                          ? (hasCheckedOut ? 'Done' : 'Active')
                                          : 'Pending',
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                if (!hasCheckedIn)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _markIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.success,
                                        minimumSize: Size(
                                          double.infinity,
                                          48.h,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.login,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Mark Check-In',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                else if (!hasCheckedOut)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _markOut,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.error,
                                        minimumSize: Size(
                                          double.infinity,
                                          48.h,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Mark Check-Out',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppTheme.success,
                                        ),
                                        SizedBox(width: 8.w),
                                        const Text(
                                          'Shift completed for today',
                                          style: TextStyle(
                                            color: AppTheme.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Shift Progress
                  if (hasCheckedIn && !hasCheckedOut) ...[
                    Text(
                      'Shift Progress',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppTheme.onBackgroundLight
                                  .withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                              minHeight: 8,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}% of shift completed',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.onBackgroundLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Attendance History
                  Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (history.isEmpty)
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Center(
                          child: Text(
                            'No history available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(1.5),
                        },
                        border: TableBorder.all(
                          color: AppTheme.onBackgroundLight.withValues(
                            alpha: 0.15,
                          ),
                          width: 0.5,
                        ),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: AppTheme.primary),
                            children: [
                              _TableHeader('Date'),
                              _TableHeader('In'),
                              _TableHeader('Out'),
                              _TableHeader('Status'),
                            ],
                          ),
                          ...history.map(
                            (r) => TableRow(
                              children: [
                                _tableCell(_formatDate(r['date'])),
                                _tableCell(_formatTime(r['in_time'])),
                                _tableCell(_formatTime(r['out_time'])),
                                _tableCellStatus(r['status'] ?? 'present'),
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
        );
      },
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28.sp),
          ),
          SizedBox(height: 6.h),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppTheme.onBackgroundLight),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

Widget _tableCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}

Widget _tableCellStatus(String status) {
  Color color;
  switch (status) {
    case 'present':
      color = AppTheme.success;
      break;
    case 'absent':
      color = AppTheme.error;
      break;
    case 'half_day':
      color = AppTheme.warning;
      break;
    default:
      color = AppTheme.onBackgroundLight;
  }
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      status == 'half_day' ? 'Half' : _cap(status),
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
    ),
  );
}

String _cap(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
