import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing data with server...'),
        backgroundColor: AppTheme.primary,
      ),
    );

    // Simulate sync process
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _pendingSync = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data synced successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Offline Mode'),
              actions: [
                IconButton(
                  onPressed: () {
                    // Refresh action
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Offline Mode Status
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Offline Mode',
                                style: TextStyle(
                                  fontSize: 18,
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
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: _isOfflineMode
                                  ? AppTheme.secondary.withValues(alpha: 0.2)
                                  : AppTheme.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isOfflineMode ? Icons.wifi_off : Icons.wifi,
                                  color: _isOfflineMode ? AppTheme.secondary : AppTheme.success,
                                  size: 30,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isOfflineMode
                                            ? 'Offline Mode Active'
                                            : 'Online Mode Active',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _isOfflineMode ? AppTheme.secondary : AppTheme.success,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _isOfflineMode
                                            ? 'Data will be synced when connection is restored'
                                            : 'All data is being synced in real-time',
                                        style: const TextStyle(
                                          color: AppTheme.onBackgroundLight,
                                        ),
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
                  const SizedBox(height: 20),
                  // Sync Status
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sync Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusCard('Total Entries', _totalEntries.toString()),
                              _buildStatusCard('Pending Sync', _pendingSync.toString()),
                              _buildStatusCard(
                                'Synced',
                                (_totalEntries - _pendingSync).toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  // Offline Entries
                  const Text(
                    'Offline Entries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _offlineEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _offlineEntries[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Pending Sync',
                                      style: TextStyle(
                                        color: AppTheme.secondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${entry['type']} • ${entry['flat']}',
                                style: const TextStyle(
                                  color: AppTheme.onBackgroundLight,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Entry Time: ${entry['time']}',
                                style: const TextStyle(
                                  color: AppTheme.onBackgroundLight,
                                ),
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                'Details:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                '• Photo captured: Yes\n'
                                '• Temperature: 36.8°C\n'
                                '• Mask compliance: Yes\n'
                                '• Approved by: Self',
                                style: TextStyle(
                                  color: AppTheme.onBackgroundLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Offline Mode Info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offline Mode Features',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
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
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.onBackgroundLight,
          ),
        ),
      ],
    );
  }
}