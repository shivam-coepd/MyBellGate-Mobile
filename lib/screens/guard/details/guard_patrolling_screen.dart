import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class GuardPatrollingScreen extends StatefulWidget {
  const GuardPatrollingScreen({super.key});

  @override
  State<GuardPatrollingScreen> createState() => _GuardPatrollingScreenState();
}

class _GuardPatrollingScreenState extends State<GuardPatrollingScreen> {
  final List<Map<String, dynamic>> _patrolRoutes = [
    {
      'id': 1,
      'name': 'Main Gate Route',
      'checkpoints': 5,
      'completed': 4,
      'status': 'In Progress',
      'lastPatrol': 'Today, 09:15 AM',
    },
    {
      'id': 2,
      'name': 'Tower A Route',
      'checkpoints': 8,
      'completed': 8,
      'status': 'Completed',
      'lastPatrol': 'Today, 08:30 AM',
    },
    {
      'id': 3,
      'name': 'Clubhouse Route',
      'checkpoints': 4,
      'completed': 0,
      'status': 'Pending',
      'lastPatrol': 'Yesterday, 05:45 PM',
    },
  ];

  final List<Map<String, dynamic>> _checkpoints = [
    {
      'id': 1,
      'name': 'Main Gate Entrance',
      'location': 'Main Entrance',
      'scanned': true,
      'time': '09:00 AM',
    },
    {
      'id': 2,
      'name': 'Parking Area',
      'location': 'Block A',
      'scanned': true,
      'time': '09:05 AM',
    },
    {
      'id': 3,
      'name': 'Garden Entrance',
      'location': 'Central Park',
      'scanned': true,
      'time': '09:10 AM',
    },
    {
      'id': 4,
      'name': 'Service Gate',
      'location': 'Rear Entrance',
      'scanned': true,
      'time': '09:15 AM',
    },
    {
      'id': 5,
      'name': 'Security Office',
      'location': 'Main Building',
      'scanned': false,
      'time': '-',
    },
  ];

  int _selectedRoute = 1;
  bool _isPatrolling = false;
  int _currentCheckpoint = 0;

  void _startPatrol() {
    setState(() {
      _isPatrolling = true;
      _currentCheckpoint = 0;
    });
  }

  void _scanCheckpoint(int id) {
    setState(() {
      for (var checkpoint in _checkpoints) {
        if (checkpoint['id'] == id) {
          checkpoint['scanned'] = true;
          checkpoint['time'] = 'Just now';
          break;
        }
      }
      _currentCheckpoint++;
    });

    if (_currentCheckpoint >= _checkpoints.length) {
      _completePatrol();
    }
  }

  void _completePatrol() {
    setState(() {
      _isPatrolling = false;
      _currentCheckpoint = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patrol completed successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Guard Patrolling'),
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
                  // Route Selection
                  const Text(
                    'Select Patrol Route',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: _patrolRoutes.map((route) {
                          return RadioListTile<int>(
                            title: Text(route['name']),
                            subtitle: Text('Last patrol: ${route['lastPatrol']}'),
                            value: route['id'],
                            groupValue: _selectedRoute,
                            onChanged: (value) {
                              setState(() {
                                _selectedRoute = value!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Patrol Status
                  const Text(
                    'Patrol Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Main Gate Route',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatusCard('Checkpoints', '5'),
                              _buildStatusCard('Completed', '4'),
                              _buildStatusCard('Pending', '1'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (!_isPatrolling)
                            ElevatedButton(
                              onPressed: _startPatrol,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Start Patrol',
                                style: TextStyle(color: AppTheme.onPrimary),
                              ),
                            )
                          else
                            Column(
                              children: [
                                const Text(
                                  'Current Patrol in Progress',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                LinearProgressIndicator(
                                  value: _currentCheckpoint / _checkpoints.length,
                                  backgroundColor: AppTheme.onBackgroundLight.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$_currentCheckpoint/${_checkpoints.length} checkpoints completed',
                                  style: const TextStyle(
                                    color: AppTheme.onBackgroundLight,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: _completePatrol,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.error,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  child: const Text(
                                    'End Patrol',
                                    style: TextStyle(color: AppTheme.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Checkpoints List
                  const Text(
                    'Checkpoints',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _checkpoints.length,
                    itemBuilder: (context, index) {
                      final checkpoint = _checkpoints[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: checkpoint['scanned']
                                      ? AppTheme.success.withValues(alpha: 0.2)
                                      : AppTheme.onBackgroundLight.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  checkpoint['scanned'] ? Icons.check : Icons.location_on,
                                  color: checkpoint['scanned'] ? AppTheme.success : AppTheme.onBackgroundLight,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      checkpoint['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      checkpoint['location'],
                                      style: const TextStyle(
                                        color: AppTheme.onBackgroundLight,
                                      ),
                                    ),
                                    if (checkpoint['scanned'])
                                      Text(
                                        'Scanned at: ${checkpoint['time']}',
                                        style: const TextStyle(
                                          color: AppTheme.success,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_isPatrolling && !_checkpoints[index]['scanned'])
                                ElevatedButton(
                                  onPressed: () => _scanCheckpoint(checkpoint['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                  ),
                                  child: const Text(
                                    'Scan',
                                    style: TextStyle(color: AppTheme.onPrimary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
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