import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/theme/app_theme.dart';

class UtilityVehicleTrackingScreen extends StatefulWidget {
  const UtilityVehicleTrackingScreen({super.key});

  @override
  State<UtilityVehicleTrackingScreen> createState() => _UtilityVehicleTrackingScreenState();
}

class _UtilityVehicleTrackingScreenState extends State<UtilityVehicleTrackingScreen> {
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 1,
      'type': 'Water Tanker',
      'vehicleNumber': 'MH-02 AB 1234',
      'driverName': 'Raj Kumar',
      'contact': '9876543210',
      'entryTime': '09:00 AM',
      'exitTime': '10:30 AM',
      'status': 'exited',
    },
    {
      'id': 2,
      'type': 'Garbage Truck',
      'vehicleNumber': 'MH-03 CD 5678',
      'driverName': 'Suresh Patel',
      'contact': '9876543211',
      'entryTime': '08:30 AM',
      'exitTime': '-',
      'status': 'inside',
    },
    {
      'id': 3,
      'type': 'School Bus',
      'vehicleNumber': 'MH-04 EF 9012',
      'driverName': 'Mahesh Sharma',
      'contact': '9876543212',
      'entryTime': '07:00 AM',
      'exitTime': '03:00 PM',
      'status': 'scheduled',
    },
  ];

  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _contactController = TextEditingController();

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Vehicle Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vehicleTypeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  hintText: 'e.g., Water Tanker, Garbage Truck',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  hintText: 'e.g., MH-02 AB 1234',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _driverNameController,
                decoration: const InputDecoration(
                  labelText: 'Driver Name',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                ),
                keyboardType: TextInputType.phone,
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
                if (_vehicleTypeController.text.isNotEmpty &&
                    _vehicleNumberController.text.isNotEmpty &&
                    _driverNameController.text.isNotEmpty &&
                    _contactController.text.isNotEmpty) {
                  setState(() {
                    _vehicles.add({
                      'id': _vehicles.length + 1,
                      'type': _vehicleTypeController.text,
                      'vehicleNumber': _vehicleNumberController.text,
                      'driverName': _driverNameController.text,
                      'contact': _contactController.text,
                      'entryTime': 'Just now',
                      'exitTime': '-',
                      'status': 'inside',
                    });
                  });
                  _vehicleTypeController.clear();
                  _vehicleNumberController.clear();
                  _driverNameController.clear();
                  _contactController.clear();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vehicle entry added successfully!'),
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

  void _markExit(int id) {
    setState(() {
      for (var vehicle in _vehicles) {
        if (vehicle['id'] == id) {
          vehicle['exitTime'] = 'Just now';
          vehicle['status'] = 'exited';
          break;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vehicle exit marked successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _driverNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Utility Vehicle Tracking'),
              actions: [
                IconButton(
                  onPressed: () {
                    // Refresh action
                  },
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: () {
                    // Filter action
                  },
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
            body: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _vehicles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vehicle['type'],
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: vehicle['status'] == 'inside'
                                        ? AppTheme.success.withValues(alpha: 0.2)
                                        : vehicle['status'] == 'exited'
                                            ? AppTheme.onBackgroundLight.withValues(alpha: 0.2)
                                            : AppTheme.secondary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    vehicle['status'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: vehicle['status'] == 'inside'
                                          ? AppTheme.success
                                          : vehicle['status'] == 'exited'
                                              ? AppTheme.onBackgroundLight
                                              : AppTheme.secondary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Vehicle: ${vehicle['vehicleNumber']}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Driver: ${vehicle['driverName']}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Contact: ${vehicle['contact']}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Entry Time',
                                      style: TextStyle(
                                        color: AppTheme.onBackgroundLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      vehicle['entryTime'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Exit Time',
                                      style: TextStyle(
                                        color: AppTheme.onBackgroundLight,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      vehicle['exitTime'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if (vehicle['status'] == 'inside')
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // Call driver
                                      },
                                      child: const Text('Call Driver'),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _markExit(vehicle['id']),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary,
                                      ),
                                      child: const Text(
                                        'Mark Exit',
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
                    onPressed: _showAddVehicleDialog,
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