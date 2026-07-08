import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

class GuardCallingScreen extends StatefulWidget {
  const GuardCallingScreen({super.key});

  @override
  State<GuardCallingScreen> createState() => _GuardCallingScreenState();
}

class _GuardCallingScreenState extends State<GuardCallingScreen> {
  final List<Map<String, dynamic>> _guards = [
    {
      'id': 1,
      'name': 'Raj Kumar',
      'position': 'Main Gate',
      'status': 'online',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Suresh Patel',
      'position': 'Tower A',
      'status': 'online',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 3,
      'name': 'Mahesh Sharma',
      'position': 'Clubhouse',
      'status': 'offline',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 4,
      'name': 'Vikram Singh',
      'position': 'Service Gate',
      'status': 'online',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final List<Map<String, dynamic>> _recentCalls = [
    {
      'id': 1,
      'name': 'Suresh Patel',
      'position': 'Tower A',
      'time': '10:30 AM',
      'duration': '5 min',
      'type': 'outgoing',
      'image':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Raj Kumar',
      'position': 'Main Gate',
      'time': '09:15 AM',
      'duration': '3 min',
      'type': 'incoming',
      'image':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  void _callGuard(int id) {
    final guard = _guards.firstWhere((g) => g['id'] == id);
    AppSnackbar.show(context: context, message: 'Calling ${guard['name']}...');
  }

  void _sendMessage(int id) {
    final guard = _guards.firstWhere((g) => g['id'] == id);
    AppSnackbar.show(
      context: context,
      message: 'Sending message to ${guard['name']}...',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Guard Communication'),
              actions: [
                IconButton(
                  onPressed: () {
                    // Refresh action
                  },
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () {
                    // Search action
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                if (await AppInternetCheck().hasInternetConnection()) {
                  if (mounted) setState(() {});
                } else {
                  if (context.mounted) {
                    AppInternetCheck.checkInternet(context: context);
                  }
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active Guards
                    const Text(
                      'Active Guards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _guards.length,
                      itemBuilder: (context, index) {
                        final guard = _guards[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                            guard['image'],
                                          ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: guard['status'] == 'online'
                                              ? AppTheme.success
                                              : AppTheme.onBackgroundLight,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.onPrimary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        guard['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        guard['position'],
                                        style: const TextStyle(
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (guard['status'] == 'online')
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _callGuard(guard['id']),
                                        icon: const Icon(
                                          Icons.call,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _sendMessage(guard['id']),
                                        icon: const Icon(
                                          Icons.message,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  const Text(
                                    'Offline',
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
                    // Recent Calls
                    const Text(
                      'Recent Calls',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentCalls.length,
                      itemBuilder: (context, index) {
                        final call = _recentCalls[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                call['image'],
                              ),
                            ),
                            title: Text(
                              call['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${call['position']} • ${call['duration']}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(call['time']),
                                const SizedBox(height: 5),
                                Icon(
                                  call['type'] == 'outgoing'
                                      ? Icons.call_made
                                      : Icons.call_received,
                                  color: call['type'] == 'outgoing'
                                      ? AppTheme.success
                                      : AppTheme.primary,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Quick Actions
                    const Text(
                      'Quick Actions',
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildQuickAction(
                                  Icons.volume_up,
                                  'Emergency',
                                  AppTheme.primary,
                                  () {
                                    AppSnackbar.show(
                                      context: context,
                                      message:
                                          'Emergency alert sent to all guards!',
                                      type: SnackBarType.error,
                                    );
                                  },
                                ),
                                _buildQuickAction(
                                  Icons.group,
                                  'Group Call',
                                  AppTheme.primary,
                                  () {
                                    AppSnackbar.show(
                                      context: context,
                                      message: 'Initiating group call...',
                                      type: SnackBarType.info,
                                    );
                                  },
                                ),
                                _buildQuickAction(
                                  Icons.broadcast_on_personal,
                                  'Broadcast',
                                  AppTheme.primary,
                                  () {
                                    AppSnackbar.show(
                                      context: context,
                                      message: 'Broadcast message sent!',
                                      type: SnackBarType.info,
                                    );
                                  },
                                ),
                              ],
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

  Widget _buildQuickAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
