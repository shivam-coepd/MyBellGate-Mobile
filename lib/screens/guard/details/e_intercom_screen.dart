import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EIntercomScreen extends StatefulWidget {
  const EIntercomScreen({super.key});

  @override
  State<EIntercomScreen> createState() => _EIntercomScreenState();
}

class _EIntercomScreenState extends State<EIntercomScreen> {
  final List<Map<String, dynamic>> _residents = [
    {
      'id': 1,
      'name': 'Rajesh Kumar',
      'flat': 'A-101',
      'phone': '9876543210',
      'status': 'online',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'flat': 'B-203',
      'phone': '9876543211',
      'status': 'busy',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 3,
      'name': 'Amit Patel',
      'flat': 'C-105',
      'phone': '9876543212',
      'status': 'offline',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final List<Map<String, dynamic>> _recentCalls = [
    {
      'id': 1,
      'residentName': 'Rajesh Kumar',
      'flat': 'A-101',
      'time': '10:30 AM',
      'duration': '2 min',
      'status': 'connected',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'residentName': 'Priya Sharma',
      'flat': 'B-203',
      'time': '09:45 AM',
      'duration': '1 min',
      'status': 'missed',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  void _callResident(int id) {
    final resident = _residents.firstWhere((r) => r['id'] == id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${resident['name']}...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _sendIVR(int id) {
    final resident = _residents.firstWhere((r) => r['id'] == id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending IVR call to ${resident['name']}...'),
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
            appBar: AppBar(
              title: const Text('E-Intercom'),
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
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Residents List
                  const Text(
                    'Residents',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _residents.length,
                    itemBuilder: (context, index) {
                      final resident = _residents[index];
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
                                    backgroundImage: CachedNetworkImageProvider(resident['image']),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: resident['status'] == 'online'
                                            ? AppTheme.success
                                            : resident['status'] == 'busy'
                                                ? AppTheme.secondary
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resident['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Flat: ${resident['flat']}',
                                      style: const TextStyle(
                                        color: AppTheme.onBackgroundLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () => _callResident(resident['id']),
                                    icon: const Icon(Icons.call, color: AppTheme.primary),
                                  ),
                                  IconButton(
                                    onPressed: () => _sendIVR(resident['id']),
                                    icon: const Icon(Icons.voicemail, color: AppTheme.primary),
                                  ),
                                ],
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
                            backgroundImage: CachedNetworkImageProvider(call['image']),
                          ),
                          title: Text(
                            call['residentName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Flat: ${call['flat']} • ${call['duration']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(call['time']),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: call['status'] == 'connected'
                                      ? AppTheme.success.withValues(alpha: 0.2)
                                      : AppTheme.error.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  call['status'],
                                  style: TextStyle(
                                    color: call['status'] == 'connected'
                                        ? AppTheme.success
                                        : AppTheme.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                            'Offline Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'In offline scenarios, IVR calls are automatically triggered to residents for approvals.',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(Icons.info, color: AppTheme.primary),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'IVR calls will be sent to primary and secondary numbers.',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
}