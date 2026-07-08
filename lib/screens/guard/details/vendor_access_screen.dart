import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';

/// Vendor access is a "service" visitor type — integrates with the real visitors API.
class VendorAccessScreen extends StatefulWidget {
  const VendorAccessScreen({super.key});

  @override
  State<VendorAccessScreen> createState() => _VendorAccessScreenState();
}

class _VendorAccessScreenState extends State<VendorAccessScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GuardBloc>().add(
      const LoadVisitors(visitorType: 'service', limit: 50),
    );
  }

  void _showAddVendorSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final serviceCtrl = TextEditingController();
    final residentIdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) => BlocListener<GuardBloc, GuardState>(
        listener: (_, state) {
          if (state is VisitorAdded) {
            Navigator.pop(sheetCtx);
            AppSnackbar.show(
              context: context,
              message: 'Vendor added successfully',
              type: SnackBarType.success,
            );
            context.read<GuardBloc>().add(
              const LoadVisitors(visitorType: 'service', limit: 50),
            );
          } else if (state is GuardError) {
            AppSnackbar.show(
              context: context,
              message: 'Failed to add vendor',
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
                    'Add Vendor / Service Person',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vendor Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Enter valid phone'
                        : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: serviceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Service Type / Purpose *',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. Plumbing, Electrical, Cleaning',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: residentIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Resident ID *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Resident ID is required'
                        : null,
                  ),
                  SizedBox(height: 20.h),
                  BlocBuilder<GuardBloc, GuardState>(
                    builder: (bbCtx, state) => ElevatedButton(
                      onPressed: state is GuardLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                bbCtx.read<GuardBloc>().add(
                                  AddVisitor(
                                    name: nameCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    purpose: serviceCtrl.text.trim(),
                                    visitorType: 'service',
                                    residentId: int.tryParse(
                                      residentIdCtrl.text.trim(),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
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
                              'Add Vendor',
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

  void _handleApprove(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'approved'));
  }

  void _handleReject(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'rejected'));
  }

  void _handleMarkEntered(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'entered'));
  }

  void _handleMarkExited(Map<String, dynamic> visitor) {
    final id = int.tryParse(visitor['id']?.toString() ?? '');
    if (id == null) return;
    context.read<GuardBloc>().add(UpdateVisitorStatus(id, 'exited'));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      case 'entered':
        return AppTheme.primary;
      case 'exited':
        return Colors.grey;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Access'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GuardBloc>().add(
              const LoadVisitors(visitorType: 'service', limit: 50),
            ),
          ),
        ],
      ),
      body: BlocConsumer<GuardBloc, GuardState>(
        listener: (context, state) {
          if (state is VisitorStatusUpdated) {
            AppSnackbar.show(
              context: context,
              message: 'Status updated to ${state.newStatus}',
              type: SnackBarType.success,
            );
            context.read<GuardBloc>().add(
              const LoadVisitors(visitorType: 'service', limit: 50),
            );
          } else if (state is GuardError) {
            AppSnackbar.show(
              context: context,
              message: 'Failed to update status',
              type: SnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          final vendors = state is VisitorsLoaded
              ? state.visitors
              : <Map<String, dynamic>>[];
          final isLoading = state is GuardLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vendors.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                if (await AppInternetCheck().hasInternetConnection()) {
                  if (context.mounted) {
                    context.read<GuardBloc>().add(
                      const LoadVisitors(visitorType: 'service', limit: 50),
                    );
                  }
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
                          Icons.build_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No vendors found',
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
                if (context.mounted) {
                  context.read<GuardBloc>().add(
                    const LoadVisitors(visitorType: 'service', limit: 50),
                  );
                }
              } else {
                if (context.mounted) {
                  AppInternetCheck.checkInternet(context: context);
                }
              }
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: vendors.length,
              itemBuilder: (_, i) => _buildVendorCard(vendors[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVendorSheet,
        backgroundColor: AppTheme.success,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Vendor', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    final status = vendor['status'] ?? 'pending';
    final statusColor = _statusColor(status);
    final residentName = vendor['resident_name'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.build,
                    color: AppTheme.success,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor['name'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        vendor['purpose'] ?? '',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (residentName.isNotEmpty)
                        Text(
                          'For: $residentName',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (vendor['phone'] != null)
                        Text(
                          vendor['phone'],
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
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
            SizedBox(height: 12.h),
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleReject(vendor),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(vendor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'approved') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMarkEntered(vendor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                  ),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    'Mark Entered',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else if (status == 'entered') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleMarkExited(vendor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Mark Exited',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
