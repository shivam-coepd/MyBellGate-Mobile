import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';

class UtilityVehicleTrackingScreen extends StatefulWidget {
  const UtilityVehicleTrackingScreen({super.key});

  @override
  State<UtilityVehicleTrackingScreen> createState() =>
      _UtilityVehicleTrackingScreenState();
}

class _UtilityVehicleTrackingScreenState
    extends State<UtilityVehicleTrackingScreen> {
  String? _statusFilter; // null = all, 'inside', 'exited'

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    context.read<GuardBloc>().add(
      LoadVehicles(status: _statusFilter, limit: 50),
    );
  }

  void _showAddVehicleSheet() {
    final typeCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) => BlocListener<GuardBloc, GuardState>(
        listener: (_, state) {
          if (state is VehicleEntryAdded) {
            Navigator.pop(sheetCtx);
            AppSnackbar.show(
              context: context,
              message: 'Vehicle entry logged',
              type: SnackBarType.success,
            );
            _load();
          } else if (state is GuardError) {
            AppSnackbar.show(
              context: context,
              message: 'Failed to log vehicle entry',
              type: SnackBarType.error,
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Vehicle Entry',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: typeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type *',
                      hintText: 'e.g. Water Tanker, Garbage Truck',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: numberCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Number *',
                      hintText: 'e.g. MH02AB1234',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: driverCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Driver Phone *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Enter valid phone'
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: purposeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Purpose *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<GuardBloc, GuardState>(
                    builder: (bbCtx, state) => ElevatedButton(
                      onPressed: state is GuardLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                bbCtx.read<GuardBloc>().add(
                                  AddVehicleEntry(
                                    vehicleType: typeCtrl.text.trim(),
                                    vehicleNumber: numberCtrl.text.trim(),
                                    driverName: driverCtrl.text.trim(),
                                    driverPhone: phoneCtrl.text.trim(),
                                    purpose: purposeCtrl.text.trim(),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: Size(double.infinity, 50.h),
                      ),
                      child: state is GuardLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Log Entry',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _markExit(Map<String, dynamic> entry) {
    final id = int.tryParse(entry['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVehicleEntryStatus(id, 'exited'));
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Tracking'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              setState(() => _statusFilter = v);
              _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(value: 'inside', child: Text('Inside')),
              const PopupMenuItem(value: 'exited', child: Text('Exited')),
            ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: BlocConsumer<GuardBloc, GuardState>(
        listener: (context, state) {
          if (state is VehicleEntryStatusUpdated) {
            AppSnackbar.show(
              context: context,
              message: 'Vehicle marked as ${state.newStatus}',
              type: SnackBarType.info,
            );
            _load();
          } else if (state is GuardError) {
            AppSnackbar.show(
              context: context,
              message: 'Failed to update vehicle status',
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          final vehicles = state is VehiclesLoaded
              ? state.vehicles
              : <Map<String, dynamic>>[];
          final isLoading = state is GuardLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehicles.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (await AppInternetCheck().hasInternetConnection()) {
                  _load();
                } else {
                  if (context.mounted) {
                    AppInternetCheck.checkInternet(context: context);
                  }
                }
              },
              child: ListView(
                children: [
                  SizedBox(height: 120.h),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No vehicle entries found',
                          style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (await AppInternetCheck().hasInternetConnection()) {
                _load();
              } else {
                if (context.mounted) {
                  AppInternetCheck.checkInternet(context: context);
                }
              }
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: vehicles.length,
              itemBuilder: (_, i) =>
                  _buildVehicleCard(vehicles[i], Theme.of(context)),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVehicleSheet,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Entry', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> entry, ThemeData theme) {
    final status = entry['status'] ?? 'inside';
    final isInside = status == 'inside';
    final statusColor = isInside ? AppTheme.success : Colors.grey;
    final phone = entry['driver_phone'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: AppTheme.warning,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['vehicle_type'] ?? '',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        entry['vehicle_number'] ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14.sp),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '${entry['driver_name'] ?? ''}  •  ${entry['purpose'] ?? ''}',
                    style: TextStyle(fontSize: 12.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.login, size: 14.sp),
                SizedBox(width: 4.w),
                Text(
                  'Entry: ${_formatTime(entry['entry_time'])}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                if (!isInside) ...[
                  SizedBox(width: 12.w),
                  Icon(Icons.logout, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Exit: ${_formatTime(entry['exit_time'])}',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ],
            ),
            if (isInside) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  if (phone.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callDriver(phone),
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call Driver'),
                      ),
                    ),
                  if (phone.isNotEmpty) SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _markExit(entry),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                      ),
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Mark Exit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
