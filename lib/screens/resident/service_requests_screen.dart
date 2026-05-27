import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/helpdesk/helpdesk_bloc.dart';
import 'package:mygate_coepd/models/ticket.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});
  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
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
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
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
        builder: (sCtx, sSet) => Padding(
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
                  value: _category,
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
                  value: _priority,
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Service request submitted!'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<HelpdeskBloc>().add(const LoadTickets());
        } else if (state is HelpdeskError) {
          log("HelpdeskError: ${state.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Service Requests',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
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
            SizedBox(height: 12.h),
            // Category quick-filters
            SizedBox(
              height: 72.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: _serviceCategories.map((cat) {
                  final color = cat['color'] as Color;
                  final icon = cat['icon'] as IconData;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 16.w),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: color, size: 22.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          cat['name'].toString(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 8.h),
            // Ticket list
            Expanded(
              child: BlocBuilder<HelpdeskBloc, HelpdeskState>(
                builder: (ctx, state) {
                  if (state is HelpdeskLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is HelpdeskError)
                    return _errorWidget(
                      state.message,
                      () => ctx.read<HelpdeskBloc>().add(const LoadTickets()),
                    );
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
                    if (tickets.isEmpty)
                      return _emptyWidget(
                        _selectedTab == 'active'
                            ? 'No Active Requests'
                            : 'No History',
                        _selectedTab == 'active'
                            ? 'Tap + to create a new service request'
                            : 'Resolved requests appear here.',
                      );
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ctx.read<HelpdeskBloc>().add(const LoadTickets()),
                      child: ListView.builder(
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
                  return const Center(child: CircularProgressIndicator());
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
    return Card(
      margin: EdgeInsets.only(bottom: 14.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
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
                          t.category[0].toUpperCase() + t.category.substring(1),
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
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
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
                if (t.assignedToName != null) ...[
                  const Spacer(),
                  Icon(Icons.person, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    t.assignedToName!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget(String msg, VoidCallback retry) => Center(
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56.sp, color: Colors.red),
          SizedBox(height: 14.h),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(height: 18.h),
          ElevatedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

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
