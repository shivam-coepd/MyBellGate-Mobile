// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/screens/guard/details/guard_patrolling_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isOffline = false;
  final int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  final List<Map<String, dynamic>> _patrolRoutes = [
    {
      'id': 1,
      'name': 'Main Gate Route',
      'checkpoints': 5,
      'completed': 4,
      'status': 'In Progress',
    },
    {
      'id': 2,
      'name': 'Tower A Route',
      'checkpoints': 8,
      'completed': 8,
      'status': 'Completed',
    },
    {
      'id': 3,
      'name': 'Clubhouse Route',
      'checkpoints': 4,
      'completed': 0,
      'status': 'Pending',
    },
  ];

  final List<Map<String, dynamic>> _attendanceRecords = [
    {
      'date': '2023-06-01',
      'shift': 'Morning',
      'inTime': '08:00 AM',
      'outTime': '04:00 PM',
      'status': 'Present',
    },
    {
      'date': '2023-06-02',
      'shift': 'Morning',
      'inTime': '08:05 AM',
      'outTime': '04:05 PM',
      'status': 'Present',
    },
    {
      'date': '2023-06-03',
      'shift': 'Morning',
      'inTime': '08:00 AM',
      'outTime': '04:00 PM',
      'status': 'Present',
    },
    {
      'date': '2023-06-04',
      'shift': 'Off',
      'inTime': '-',
      'outTime': '-',
      'status': 'Off',
    },
  ];

  final List<Map<String, dynamic>> _shifts = [
    {'id': 1, 'name': 'Morning', 'time': '08:00 AM - 04:00 PM'},
    {'id': 2, 'name': 'Evening', 'time': '04:00 PM - 12:00 AM'},
    {'id': 3, 'name': 'Night', 'time': '12:00 AM - 08:00 AM'},
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.directions_walk,
      'label': 'Patrolling',
      'color': AppTheme.primary,
    },
    {'icon': Icons.qr_code_scanner, 'label': 'Scan QR', 'color': AppTheme.success},
  ];

  void _markAttendance() {
    // Logic to mark attendance
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance marked successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _scanQRCode() {
    // Logic to scan QR code for patrol
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanning QR code...'),
        backgroundColor: AppTheme.primary,
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
                child: Column(
                  spacing: 20.0,
                  children: [
                    // Offline Banner
                    if (_isOffline)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.wifi_off, color: AppTheme.onPrimary),
                                SizedBox(width: 10),
                                Text(
                                  'Offline Mode',
                                  style: TextStyle(
                                    color: AppTheme.onPrimary,
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
                                color: AppTheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Quick Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (
                              int index = 0;
                              index < _quickActions.length;
                              index++
                            )
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                ),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (index == 0) {
                                          // _navigateToPatrolling();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const GuardPatrollingScreen(),
                                            ),
                                          );
                                        } else {
                                          _scanQRCode();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: _quickActions[index]['color'],
                                          borderRadius: BorderRadius.circular(
                                            16.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  _quickActions[index]['color']
                                                      .withValues(alpha: 0.3),
                                              blurRadius: 10.w,
                                              offset: Offset(0, 5.h),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _quickActions[index]['icon'],
                                          color: AppTheme.onPrimary,
                                          size: 30.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      _quickActions[index]['label'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Attendance Summary Card
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text(
                                  'Today\'s Attendance',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildAttendanceStat('In Time', '08:00 AM'),
                                    _buildAttendanceStat('Out Time', '-'),
                                    _buildAttendanceStat('Status', 'Present'),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: _markAttendance,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    minimumSize: Size(
                                      double.infinity,
                                      50.h,
                                    ),
                                  ),
                                  child: const Text(
                                    'Mark Attendance',
                                    style: TextStyle(
                                      color: AppTheme.onPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Shift Information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Shift',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                const Text(
                                  'Morning Shift',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text('08:00 AM - 04:00 PM'),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: 0.5,
                                  backgroundColor: AppTheme.onBackgroundLight.withValues(alpha: 0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppTheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                const Text('50% of shift completed'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Patrol Routes
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Patrol Routes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GuardPatrollingScreen(),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _patrolRoutes.length,
                          itemBuilder: (context, index) {
                            final route = _patrolRoutes[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 15.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          route['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                route['status'] == 'Completed'
                                                ? AppTheme.success.withValues(alpha: 0.2)
                                                : route['status'] ==
                                                      'In Progress'
                                                ? AppTheme.secondary.withValues(alpha: 0.2)
                                                : AppTheme.onBackgroundLight.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          child: Text(
                                            route['status'],
                                            style: TextStyle(
                                              color:
                                                  route['status'] == 'Completed'
                                                  ? AppTheme.success
                                                  : route['status'] ==
                                                        'In Progress'
                                                  ? AppTheme.secondary
                                                  : AppTheme.onBackgroundLight,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${route['completed']}/${route['checkpoints']} checkpoints completed',
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value:
                                          route['completed'] /
                                          route['checkpoints'],
                                      backgroundColor: AppTheme.onBackgroundLight.withValues(alpha: 0.3),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppTheme.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () {
                                              // View details
                                            },
                                            child: const Text('Details'),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _scanQRCode,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primary,
                                            ),
                                            child: const Text(
                                              'Scan QR',
                                              style: TextStyle(
                                                color: AppTheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Attendance History
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(1),
                                },
                                border: TableBorder.all(
                                  color: AppTheme.onBackgroundLight.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                    ),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'Date',
                                          style: TextStyle(
                                            color: AppTheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'In',
                                          style: TextStyle(
                                            color: AppTheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'Out',
                                          style: TextStyle(
                                            color: AppTheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'Status',
                                          style: TextStyle(
                                            color: AppTheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ..._attendanceRecords.map(
                                    (record) => TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(record['date']),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(record['inTime']),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(record['outTime']),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            record['status'],
                                            style: TextStyle(
                                              color:
                                                  record['status'] == 'Present'
                                                  ? AppTheme.success
                                                  : record['status'] == 'Off'
                                                  ? AppTheme.onBackgroundLight
                                                  : AppTheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildAttendanceStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.onBackgroundLight, fontSize: 14)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
