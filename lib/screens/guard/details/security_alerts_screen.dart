import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/guard/guard_bloc.dart';
import 'package:mygate_coepd/theme/app_theme.dart';
import 'package:mygate_coepd/widgets/app_internet_check.dart';

class SecurityAlertsScreen extends StatefulWidget {
  const SecurityAlertsScreen({super.key});

  @override
  State<SecurityAlertsScreen> createState() => _SecurityAlertsScreenState();
}

class _SecurityAlertsScreenState extends State<SecurityAlertsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Open', 'In Progress', 'Resolved'];
  final List<String?> _statusValues = [null, 'open', 'in_progress', 'resolved'];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    context.read<GuardBloc>().add(
          LoadSecurityAlerts(status: _statusValues[_selectedFilter], limit: 30),
        );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppTheme.error;
      case 'high':
        return Colors.deepOrange;
      case 'low':
        return AppTheme.success;
      default:
        return AppTheme.warning;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppTheme.success;
      case 'closed':
        return Colors.grey;
      case 'in_progress':
        return AppTheme.info;
      default:
        return AppTheme.warning;
    }
  }

  IconData _alertTypeIcon(String type) {
    switch (type) {
      case 'suspicious_activity':
        return Icons.visibility_off;
      case 'unauthorized_access':
        return Icons.no_encryption;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.warning_amber;
    }
  }

  String _alertTypeLabel(String type) {
    switch (type) {
      case 'suspicious_activity':
        return 'Suspicious Activity';
      case 'unauthorized_access':
        return 'Unauthorized Access';
      case 'emergency':
        return 'Emergency';
      default:
        return 'Other';
    }
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = DateTime.parse(ts.toString());
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month} $hour:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return ts.toString();
    }
  }

  void _showReportAlertSheet() {
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String alertType = 'suspicious_activity';
    String severity = 'medium';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetCtx) => BlocListener<GuardBloc, GuardState>(
        listener: (sheetCtx, state) {
          if (state is SecurityAlertReported) {
            Navigator.pop(sheetCtx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Security alert reported successfully'),
                backgroundColor: AppTheme.success,
              ),
            );
            _loadAlerts();
          } else if (state is GuardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
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
            child: StatefulBuilder(
              builder: (sbCtx, setSt) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Security Alert',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      initialValue: alertType,
                      decoration: const InputDecoration(
                        labelText: 'Alert Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'suspicious_activity',
                            child: Text('Suspicious Activity')),
                        DropdownMenuItem(
                            value: 'unauthorized_access',
                            child: Text('Unauthorized Access')),
                        DropdownMenuItem(
                            value: 'emergency', child: Text('Emergency')),
                        DropdownMenuItem(
                            value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setSt(() => alertType = v ?? alertType),
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      initialValue: severity,
                      decoration: const InputDecoration(
                        labelText: 'Severity',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(
                            value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(
                            value: 'critical', child: Text('Critical')),
                      ],
                      onChanged: (v) => setSt(() => severity = v ?? severity),
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: locationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    BlocBuilder<GuardBloc, GuardState>(
                      builder: (bbCtx, state) => ElevatedButton(
                        onPressed: state is GuardLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  bbCtx.read<GuardBloc>().add(
                                        ReportSecurityAlert(
                                          alertType: alertType,
                                          description: descCtrl.text.trim(),
                                          severity: severity,
                                          location: locationCtrl.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : locationCtrl.text.trim(),
                                        ),
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
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
                                'Report Alert',
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
      ),
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> alert) {
    String selectedStatus = alert['status'] ?? 'open';
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Update Alert Status'),
        content: StatefulBuilder(
          builder: (sbCtx, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['open', 'in_progress', 'resolved', 'closed']
                .map(
                  (s) => RadioListTile<String>(
                    title: Text(
                        s == 'in_progress' ? 'In Progress' : _cap(s)),
                    value: s,
                    groupValue: selectedStatus,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setSt(() => selectedStatus = v!),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              final id = int.tryParse(alert['id']?.toString() ?? '');
              if (id != null) {
                context
                    .read<GuardBloc>()
                    .add(UpdateAlertStatus(id, selectedStatus));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Alerts'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAlerts),
        ],
      ),
      body: BlocConsumer<GuardBloc, GuardState>(
        listener: (context, state) {
          if (state is AlertStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status updated to ${state.newStatus}'),
                backgroundColor: AppTheme.success,
              ),
            );
            _loadAlerts();
          } else if (state is GuardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final alerts = state is SecurityAlertsLoaded ? state.alerts : <Map<String, dynamic>>[];
          final isLoading = state is GuardLoading;

          return Column(
            children: [
              // Filter bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                child: SizedBox(
                  height: 40.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(_filters[i]),
                        selected: _selectedFilter == i,
                        selectedColor: AppTheme.primary,
                        onSelected: (sel) {
                          if (sel) {
                            setState(() => _selectedFilter = i);
                            _loadAlerts();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : alerts.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              if (await AppInternetCheck().hasInternetConnection()) {
                                _loadAlerts();
                              } else {
                                if (mounted) {
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
                                      Icon(Icons.shield,
                                          size: 64.sp, color: Colors.grey),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'No alerts found',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              if (await AppInternetCheck().hasInternetConnection()) {
                                _loadAlerts();
                              } else {
                                if (mounted) {
                                  AppInternetCheck.checkInternet(context: context);
                                }
                              }
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: alerts.length,
                              itemBuilder: (_, i) =>
                                  _buildAlertCard(alerts[i]),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showReportAlertSheet,
        backgroundColor: AppTheme.error,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label:
            const Text('Report Alert', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final severity = alert['severity'] ?? 'medium';
    final status = alert['status'] ?? 'open';
    final alertType = alert['alert_type'] ?? 'other';
    final sevColor = _severityColor(severity);
    final statColor = _statusColor(status);

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
                    color: sevColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    _alertTypeIcon(alertType),
                    color: sevColor,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _alertTypeLabel(alertType),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Wrap(
                        spacing: 6,
                        children: [
                          _chip(severity.toUpperCase(), sevColor),
                          _chip(
                            status == 'in_progress'
                                ? 'IN PROGRESS'
                                : status.toUpperCase(),
                            statColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showUpdateStatusDialog(alert),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              alert['description'] ?? '',
              style: TextStyle(fontSize: 14.sp),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (alert['location'] != null) ...[
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      alert['location'],
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (alert['reported_by_name'] != null)
                  Flexible(
                    child: Text(
                      'By: ${alert['reported_by_name']}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Text(
                  _formatTime(alert['created_at']),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
