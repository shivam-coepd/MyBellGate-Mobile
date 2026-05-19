import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VendorAccessScreen extends StatefulWidget {
  const VendorAccessScreen({super.key});

  @override
  State<VendorAccessScreen> createState() => _VendorAccessScreenState();
}

class _VendorAccessScreenState extends State<VendorAccessScreen> {
  final List<Map<String, dynamic>> _vendors = [
    {
      'id': 1,
      'name': 'Rajesh Plumbing',
      'service': 'Plumber',
      'flat': 'A-101',
      'time': '10:15 AM',
      'status': 'pending',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
    },
    {
      'id': 2,
      'name': 'Suresh Electrical',
      'service': 'Electrician',
      'flat': 'B-203',
      'time': '09:30 AM',
      'status': 'approved',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100&h=100',
    },
  ];

  final _nameController = TextEditingController();
  final _serviceController = TextEditingController();
  final _flatController = TextEditingController();

  void _showAddVendorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Vendor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _serviceController,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _flatController,
                decoration: const InputDecoration(
                  labelText: 'Flat Number',
                ),
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
                if (_nameController.text.isNotEmpty &&
                    _serviceController.text.isNotEmpty &&
                    _flatController.text.isNotEmpty) {
                  setState(() {
                    _vendors.add({
                      'id': _vendors.length + 1,
                      'name': _nameController.text,
                      'service': _serviceController.text,
                      'flat': _flatController.text,
                      'time': 'Just now',
                      'status': 'pending',
                      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100&h=100',
                    });
                  });
                  _nameController.clear();
                  _serviceController.clear();
                  _flatController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vendor added successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _requestApproval(int id) {
    setState(() {
      for (var vendor in _vendors) {
        if (vendor['id'] == id) {
          vendor['status'] = 'requested';
          break;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Approval request sent to resident!'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _callResident(int id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling resident...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serviceController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Vendor Access'),
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
                  itemCount: _vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = _vendors[index];
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
                                  backgroundImage: CachedNetworkImageProvider(vendor['image']),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendor['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        vendor['service'],
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                      Text(
                                        'For: ${vendor['flat']} • ${vendor['time']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.onBackgroundLight,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: vendor['status'] == 'approved'
                                              ? AppTheme.success.withValues(alpha: 0.2)
                                              : vendor['status'] == 'requested'
                                                  ? AppTheme.secondary.withValues(alpha: 0.2)
                                                  : AppTheme.onBackgroundLight.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Text(
                                          vendor['status'].toString().toUpperCase(),
                                          style: TextStyle(
                                            color: vendor['status'] == 'approved'
                                                ? AppTheme.success
                                                : vendor['status'] == 'requested'
                                                    ? AppTheme.secondary
                                                    : AppTheme.onBackgroundLight,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if (vendor['status'] == 'pending')
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _callResident(vendor['id']),
                                      child: const Text('Call Resident'),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _requestApproval(vendor['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                      ),
                                      child: const Text(
                                        'Request Approval',
                                        style: TextStyle(color: AppTheme.onPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (vendor['status'] == 'requested')
                              const Center(
                                child: Text(
                                  'Waiting for resident approval...',
                                  style: TextStyle(
                                    color: AppTheme.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              const Center(
                                child: Text(
                                  'Entry approved',
                                  style: TextStyle(
                                    color: AppTheme.success,
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
                // Floating Action Button
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: FloatingActionButton(
                    onPressed: _showAddVendorDialog,
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