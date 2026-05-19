import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TemperatureMaskScreen extends StatefulWidget {
  const TemperatureMaskScreen({super.key});

  @override
  State<TemperatureMaskScreen> createState() => _TemperatureMaskScreenState();
}

class _TemperatureMaskScreenState extends State<TemperatureMaskScreen> {
  final List<Map<String, dynamic>> _visitors = [
    {
      'id': 1,
      'name': 'Rahul Kumar',
      'type': 'Delivery',
      'flat': 'A-101',
      'temperature': '36.8°C',
      'mask': true,
      'time': '10:15 AM',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Priya Sharma',
      'type': 'Guest',
      'flat': 'B-203',
      'temperature': '37.2°C',
      'mask': true,
      'time': '10:05 AM',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 3,
      'name': 'Amit Patel',
      'type': 'Service',
      'flat': 'C-105',
      'temperature': '36.5°C',
      'mask': false,
      'time': '9:45 AM',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final _temperatureController = TextEditingController();
  String _selectedVisitor = '';
  bool _maskCompliance = true;

  void _showCaptureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Capture Temperature & Mask'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Visitor',
                ),
                items: _visitors.map((visitor) {
                  return DropdownMenuItem(
                    value: visitor['id'].toString(),
                    child: Text(visitor['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVisitor = value!;
                  });
                },
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                  hintText: 'e.g., 36.8',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Mask Compliance:'),
                  Switch(
                    value: _maskCompliance,
                    onChanged: (value) {
                      setState(() {
                        _maskCompliance = value;
                      });
                    },
                    activeThumbColor: AppTheme.primary,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedVisitor.isNotEmpty && _temperatureController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Temperature and mask status captured successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Temperature & Mask Check'),
              actions: [
                IconButton(
                  onPressed: () {
                    // Refresh action
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            body: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _visitors.length,
                  itemBuilder: (context, index) {
                    final visitor = _visitors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(visitor['image']),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        visitor['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        visitor['type'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                      Text(
                                        'For: ${visitor['flat']} • ${visitor['time']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(
                                        Icons.thermostat,
                                        color: AppTheme.primary,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        visitor['temperature'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const Text(
                                        'Temperature',
                                        style: TextStyle(
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(
                                        visitor['mask'] ? Icons.masks : Icons.masks_outlined,
                                        color: visitor['mask'] ? AppTheme.success : AppTheme.error,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        visitor['mask'] ? 'Wearing Mask' : 'No Mask',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: visitor['mask'] ? AppTheme.success : AppTheme.error,
                                        ),
                                      ),
                                      const Text(
                                        'Compliance',
                                        style: TextStyle(
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // View history
                                    },
                                    child: const Text('View History'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _showCaptureDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                    ),
                                    child: const Text(
                                      'Update',
                                      style: TextStyle(color: AppTheme.onPrimary),
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
                // Floating Action Button
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: FloatingActionButton(
                    onPressed: _showCaptureDialog,
                    backgroundColor: AppTheme.primary,
                    child: const Icon(Icons.add, color: AppTheme.onPrimary),
                  ),
                ),
              ],
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