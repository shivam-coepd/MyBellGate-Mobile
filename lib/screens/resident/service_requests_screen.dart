import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/helpdesk/helpdesk_bloc.dart';
import 'package:mygate_coepd/models/ticket.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:mygate_coepd/widgets/app_error_widget.dart';
import 'package:shimmer/shimmer.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});
  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  String _selectedTab = 'active';

  // Form controllers for new ticket
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'general';
  String _priority = 'medium';

  final _serviceCategories = [
    {
      'id': 'plumbing',
      'name': 'Plumbing',
      'icon': Icons.water_damage,
      'color': Colors.blue,
    },
    {
      'id': 'electrical',
      'name': 'Electrical',
      'icon': Icons.electrical_services,
      'color': Colors.orange,
    },
    {
      'id': 'carpentry',
      'name': 'Carpentry',
      'icon': Icons.construction,
      'color': Colors.brown,
    },
    {
      'id': 'cleaning',
      'name': 'Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.green,
    },
    {
      'id': 'security',
      'name': 'Security',
      'icon': Icons.security,
      'color': Colors.red,
    },
    {
      'id': 'general',
      'name': 'General',
      'icon': Icons.miscellaneous_services,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animCtrl.forward();
      context.read<HelpdeskBloc>().add(const LoadTickets());
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  Color _categoryColor(String cat) {
    for (var c in _serviceCategories) {
      if (c['id'] == cat ||
          c['name'].toString().toLowerCase() == cat.toLowerCase()) {
        return c['color'] as Color;
      }
    }
    return Colors.grey;
  }

  IconData _categoryIcon(String cat) {
    for (var c in _serviceCategories) {
      if (c['id'] == cat ||
          c['name'].toString().toLowerCase() == cat.toLowerCase()) {
        return c['icon'] as IconData;
      }
    }
    return Icons.help;
  }

  void _showNewTicketForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _category = 'general';
    _priority = 'medium';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sCtx, sSet) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'New Service Request',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    hintText: 'e.g. Leaking tap in kitchen',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Describe the issue in detail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items:
                      [
                            'general',
                            'maintenance',
                            'security',
                            'billing',
                            'plumbing',
                            'electrical',
                            'carpentry',
                            'cleaning',
                          ]
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c[0].toUpperCase() + c.substring(1)),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => sSet(() => _category = v ?? 'general'),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'low', child: const Text('🟢 Low')),
                    DropdownMenuItem(
                      value: 'medium',
                      child: const Text('🟡 Medium'),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: const Text('🟠 High'),
                    ),
                    DropdownMenuItem(
                      value: 'urgent',
                      child: const Text('🔴 Urgent'),
                    ),
                  ],
                  onChanged: (v) => sSet(() => _priority = v ?? 'medium'),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sCtx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(sCtx);
                            context.read<HelpdeskBloc>().add(
                              CreateTicket(
                                title: _titleCtrl.text.trim(),
                                description: _descCtrl.text.trim(),
                                category: _category,
                                priority: _priority,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HelpdeskBloc, HelpdeskState>(
      listener: (ctx, state) {
        if (state is TicketCreated) {
          AppSnackbar.show(
            context: context,
            message: 'Service request submitted!',
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
          context.read<HelpdeskBloc>().add(const LoadTickets());
        } else if (state is TicketUpdated) {
          AppSnackbar.show(
            context: context,
            message: 'Ticket updated!',
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
          context.read<HelpdeskBloc>().add(const LoadTickets());
        } else if (state is TicketDeleted) {
          AppSnackbar.show(
            context: context,
            message: 'Ticket deleted!',
            type: SnackBarType.error,
            position: SnackBarPosition.top,
          );
          context.read<HelpdeskBloc>().add(const LoadTickets());
        } else if (state is TicketStatusUpdated) {
          AppSnackbar.show(
            context: context,
            message: 'Status updated!',
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
          context.read<HelpdeskBloc>().add(const LoadTickets());
        } else if (state is CommentAdded) {
          AppSnackbar.show(
            context: context,
            message: 'Comment added!',
            type: SnackBarType.success,
            position: SnackBarPosition.top,
          );
          context.read<HelpdeskBloc>().add(const LoadTickets());
        } else if (state is HelpdeskError) {
          log("HelpdeskError: ${state.message}");
          AppSnackbar.show(
            context: context,
            message: state.message,
            type: SnackBarType.error,
            position: SnackBarPosition.top,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Service Requests'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'service_requests_fab',
          onPressed: _showNewTicketForm,
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add, size: 24.sp),
        ),
        body: Column(
          children: [
            // Tab row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedTab = 'active');
                        context.read<HelpdeskBloc>().add(const LoadTickets());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 'active'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardTheme.color,
                        foregroundColor: _selectedTab == 'active'
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Active', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedTab = 'history');
                        context.read<HelpdeskBloc>().add(
                          const LoadTickets(status: 'resolved'),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 'history'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardTheme.color,
                        foregroundColor: _selectedTab == 'history'
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('History', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Ticket list
            Expanded(
              child: BlocBuilder<HelpdeskBloc, HelpdeskState>(
                builder: (ctx, state) {
                  if (state is HelpdeskLoading) {
                    return const _TicketListShimmer();
                  }
                  if (state is HelpdeskError) {
                    return AppErrorWidget(
                      message: state.message,
                      title: 'Request Failed',
                      icon: Icons.support_agent_outlined,
                      onRetry: () => ctx.read<HelpdeskBloc>().add(const LoadTickets()),
                    );
                  }

                  // Determine the event to fire based on active tab
                  final refreshEvent = _selectedTab == 'history'
                      ? const LoadTickets(status: 'resolved')
                      : const LoadTickets();

                  if (state is TicketsLoaded) {
                    final tickets = _selectedTab == 'active'
                        ? state.tickets
                              .where(
                                (t) =>
                                    t.status == 'open' ||
                                    t.status == 'in_progress',
                              )
                              .toList()
                        : state.tickets
                              .where(
                                (t) =>
                                    t.status == 'resolved' ||
                                    t.status == 'closed',
                              )
                              .toList();

                    if (tickets.isEmpty) {
                      // Wrap empty state in a scrollable so RefreshIndicator works
                      return RefreshIndicator(
                        onRefresh: () async =>
                            ctx.read<HelpdeskBloc>().add(refreshEvent),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 80.h),
                            _emptyWidget(
                              _selectedTab == 'active'
                                  ? 'No Active Requests'
                                  : 'No History',
                              _selectedTab == 'active'
                                  ? 'Tap + to create a new service request'
                                  : 'Resolved requests appear here.',
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async =>
                          ctx.read<HelpdeskBloc>().add(refreshEvent),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          bottom: 80.h,
                        ),
                        itemCount: tickets.length,
                        itemBuilder: (_, i) => _ticketCard(tickets[i]),
                      ),
                    );
                  }
                  return const _TicketListShimmer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketCard(Ticket t) {
    final sc = _statusColor(t.status);
    final cc = _categoryColor(t.category);
    final ci = _categoryIcon(t.category);
    final isActive = t.status == 'open' || t.status == 'in_progress';

    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _showTicketActions(t),
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
                      color: cc.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: cc.withValues(alpha: 0.3)),
                    ),
                    child: Icon(ci, color: cc, size: 22.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: cc.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            t.category[0].toUpperCase() +
                                t.category.substring(1),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: cc,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: sc,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      t.statusLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                t.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.tag, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    '#${t.ticketNumber}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                  Icon(Icons.flag, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    t.priorityLabel,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                  Icon(Icons.access_time, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    t.createdAt?.substring(0, 10) ?? '',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  if (t.commentCount > 0) ...[
                    SizedBox(width: 12.w),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 13.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${t.commentCount}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              if (t.assignedToName != null) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "Assigned to: ",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    Text(
                      t.assignedToName!,
                      style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                    ),
                  ],
                ),
              ],
              // Action buttons — only shown for active (open / in_progress) tickets
              if (isActive) ...[
                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // Edit — open tickets only
                    if (t.status == 'open') ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditTicketForm(t),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 16.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    // Resolve
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<HelpdeskBloc>().add(
                          UpdateTicketStatus(t.id, 'resolved'),
                        ),
                        icon: Icon(
                          Icons.check_circle_outline,
                          size: 16.sp,
                          color: Colors.green,
                        ),
                        label: Text(
                          'Resolve',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.green,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    // Delete — open tickets only
                    if (t.status == 'open') ...[
                      SizedBox(width: 8.w),
                      OutlinedButton(
                        onPressed: () => _confirmDelete(t),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 12.w,
                          ),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketActions(Ticket t) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.h),
            // Edit — only for open tickets
            if (t.status == 'open')
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Edit Ticket'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTicketForm(t);
                },
              ),
            // Close ticket
            if (t.status == 'open' || t.status == 'in_progress')
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                title: const Text('Mark as Resolved'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<HelpdeskBloc>().add(
                    UpdateTicketStatus(t.id, 'resolved'),
                  );
                },
              ),
            // Add comment
            ListTile(
              leading: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.blue,
              ),
              title: const Text('Add Comment'),
              onTap: () {
                Navigator.pop(context);
                _showAddCommentDialog(t);
              },
            ),
            // Delete — only for open tickets
            if (t.status == 'open')
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Ticket',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(t);
                },
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _showEditTicketForm(Ticket t) {
    final titleCtrl = TextEditingController(text: t.title);
    final descCtrl = TextEditingController(text: t.description);
    String category = t.category;
    String priority = t.priority;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sCtx, sSet) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 20.h,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Edit Ticket',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items:
                      [
                            'general',
                            'maintenance',
                            'security',
                            'billing',
                            'plumbing',
                            'electrical',
                            'carpentry',
                            'cleaning',
                            'other',
                          ]
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c[0].toUpperCase() + c.substring(1)),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => sSet(() => category = v ?? category),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'low', child: const Text('🟢 Low')),
                    DropdownMenuItem(
                      value: 'medium',
                      child: const Text('🟡 Medium'),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: const Text('🟠 High'),
                    ),
                    DropdownMenuItem(
                      value: 'urgent',
                      child: const Text('🔴 Urgent'),
                    ),
                  ],
                  onChanged: (v) => sSet(() => priority = v ?? priority),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sCtx),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(sCtx);
                            context.read<HelpdeskBloc>().add(
                              UpdateTicket(
                                t.id,
                                title: titleCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                category: category,
                                priority: priority,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text('Save', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCommentDialog(Ticket t) {
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: commentCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write your comment...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = commentCtrl.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<HelpdeskBloc>().add(AddTicketComment(t.id, text));
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Ticket t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: Text(
          'Are you sure you want to delete ticket #${t.ticketNumber}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HelpdeskBloc>().add(DeleteTicket(t.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  Widget _emptyWidget(String t, String s) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Icon(
            Icons.checklist,
            size: 48.sp,
            color: const Color(0xFF006D77),
          ),
        ),
        SizedBox(height: 18.h),
        Text(
          t,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          s,
          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _TicketListShimmer extends StatelessWidget {
  const _TicketListShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
        itemCount: 5,
        itemBuilder: (_, _) => Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: icon + title + status badge
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            height: 12.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 60.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // Description lines
                Container(
                  height: 12.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 12.h,
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 10.h),
                // Meta row: ticket#, priority, date
                Row(
                  children: List.generate(
                    3,
                    (i) => [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        width: 50.w,
                        height: 11.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                  ).expand((e) => e).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
