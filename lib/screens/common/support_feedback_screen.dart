import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/auth/auth_bloc.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';
import 'package:mygate_coepd/blocs/helpdesk/helpdesk_bloc.dart';
import 'package:mygate_coepd/models/ticket.dart';
import 'package:mygate_coepd/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportFeedbackScreen extends StatefulWidget {
  const SupportFeedbackScreen({super.key});

  @override
  State<SupportFeedbackScreen> createState() => _SupportFeedbackScreenState();
}

class _SupportFeedbackScreenState extends State<SupportFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HelpdeskBloc>().add(const LoadTickets());
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openCall() async {
    final uri = Uri(scheme: 'tel', path: '+911800123456');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@mygatebell.com',
      query: 'subject=Support Request&body=Hi MyGateBell Support,',
    );
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  void _showRaiseTicketSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'general';
    String priority = 'medium';
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, sSet) => Container(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Raise a Ticket',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Describe your issue and our team will get back to you',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'Brief summary of your issue',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: descCtrl,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Provide details about your issue...',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final cat in [
                        'general',
                        'maintenance',
                        'security',
                        'billing',
                        'other',
                      ])
                        ChoiceChip(
                          label: Text(cat[0].toUpperCase() + cat.substring(1)),
                          selected: category == cat,
                          selectedColor: theme.colorScheme.primary.withValues(
                            alpha: 0.2,
                          ),
                          onSelected: (v) =>
                              v ? sSet(() => category = cat) : null,
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      for (final p in ['low', 'medium', 'high', 'urgent'])
                        ChoiceChip(
                          label: Text(p[0].toUpperCase() + p.substring(1)),
                          selected: priority == p,
                          selectedColor: p == 'urgent'
                              ? Colors.red.withValues(alpha: 0.2)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                          onSelected: (v) =>
                              v ? sSet(() => priority = p) : null,
                        ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<HelpdeskBloc>().add(
                            CreateTicket(
                              title: titleCtrl.text,
                              description: descCtrl.text,
                              category: category,
                              priority: priority,
                            ),
                          );
                          Navigator.pop(ctx);
                          AppSnackbar.show(
                            context: context,
                            message: 'Ticket raised successfully!',
                            type: SnackBarType.success,
                          );
                        }
                      },
                      child: const Text('Submit Ticket'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox.shrink(); // Or show loading/unauthenticated drawer
        }

        final user = state.user;
        final userRole = user.role;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Support & Feedback'),
          ),
          body: Column(
            children: [
              // Quick actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    _quickAction(
                      theme,
                      Icons.call_outlined,
                      'Call Us',
                      _openCall,
                    ),
                    SizedBox(width: 12.w),
                    _quickAction(
                      theme,
                      Icons.email_outlined,
                      'Email Us',
                      _openEmail,
                    ),
                    SizedBox(width: 12.w),
                    if (userRole == 'resident')
                      _quickAction(
                        theme,
                        Icons.add_comment_outlined,
                        'Raise Ticket',
                        _showRaiseTicketSheet,
                      ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabCtrl,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                dividerColor: theme.colorScheme.primary,
                indicatorWeight: 3,
                tabs: [
                  const Tab(text: 'FAQ'),
                  // Tab(text: 'My Tickets'),
                  if (userRole == 'resident') const Tab(text: 'My Tickets'),
                  const Tab(text: 'Feedback'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildFaqTab(theme),
                    // _buildTicketsTab(theme),
                    if (userRole == 'resident') _buildTicketsTab(theme),
                    _buildFeedbackTab(theme),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickAction(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTab(ThemeData theme) {
    final faqs = [
      {
        'q': 'How do I add a family member?',
        'a':
            'Go to Profile > Household section > tap "Add" > select "Family Member". Fill in the name, relationship, and phone number. You can also import from your contacts.',
      },
      {
        'q': 'How do I approve a visitor entry?',
        'a':
            'When a guard logs a visitor, you receive a push notification. Open the notification or go to Visitors screen to Approve or Deny the entry. You can also pre-approve expected visitors.',
      },
      {
        'q': 'How do I pay my society bills?',
        'a':
            'Go to Bills & Payments from the home screen. You will see all your invoices. Tap on any unpaid invoice and select a payment method (UPI, Card, or Net Banking) to pay.',
      },
      {
        'q': 'What is Flash Approval?',
        'a':
            'Flash Approvals allow visitors to be auto-approved if you have pre-registered them. This speeds up entry at the gate without requiring manual confirmation each time.',
      },
      {
        'q': 'How do I book an amenity?',
        'a':
            'Go to Amenities from the home screen. Browse available amenities, select a date and time slot, and confirm your booking. Some amenities may require approval from the society admin.',
      },
      {
        'q': 'How do I change my password?',
        'a':
            'Go to Profile > Security & Privacy > Change Password. Enter your current password and set a new strong password with at least 8 characters.',
      },
      {
        'q': 'How do I raise a maintenance complaint?',
        'a':
            'Go to Support & Feedback > Raise Ticket. Select "Maintenance" category and describe your issue. Our team will respond within 24 hours.',
      },
      {
        'q': 'Can I add multiple properties?',
        'a':
            'Yes! Go to Profile > Manage Flats > Add New Property to register another flat or property in the same or different society.',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: faqs.length,
      itemBuilder: (ctx, i) => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ExpansionTileTheme(
          data: const ExpansionTileThemeData(
            shape: Border(),
            collapsedShape: Border(),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
            childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
            title: Text(
              faqs[i]['q']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            children: [
              Text(
                faqs[i]['a']!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsTab(ThemeData theme) {
    return BlocConsumer<HelpdeskBloc, HelpdeskState>(
      listener: (ctx, state) {
        if (state is TicketCreated) {
          ctx.read<HelpdeskBloc>().add(const LoadTickets());
        }
      },
      builder: (ctx, state) {
        if (state is HelpdeskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TicketsLoaded) {
          final tickets = state.tickets;
          if (tickets.isEmpty) {
            return _emptyState(
              theme,
              Icons.confirmation_number_outlined,
              'No tickets yet',
              'Raise a ticket to get help from our support team',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ctx.read<HelpdeskBloc>().add(const LoadTickets()),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: tickets.length,
              itemBuilder: (ctx, i) => _ticketCard(theme, tickets[i]),
            ),
          );
        }
        if (state is HelpdeskError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 12.h),
                Text(state.message, textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                ElevatedButton(
                  onPressed: () =>
                      ctx.read<HelpdeskBloc>().add(const LoadTickets()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return _emptyState(
          theme,
          Icons.confirmation_number_outlined,
          'No tickets yet',
          'Raise a ticket to get help from our support team',
        );
      },
    );
  }

  Widget _ticketCard(ThemeData theme, Ticket t) {
    Color statusColor;
    switch (t.status) {
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'closed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              t.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ticketMeta(theme, Icons.tag, t.ticketNumber),
                // SizedBox(width: 10.w),
                _ticketMeta(theme, Icons.category_outlined, t.category),
                // SizedBox(width: 10.w),
                _ticketMeta(theme, Icons.flag_outlined, t.priorityLabel),
                // Spacer(),
                if (t.createdAt != null)
                  Text(
                    _formatDate(t.createdAt!),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketMeta(ThemeData theme, IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 3.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildFeedbackTab(ThemeData theme) {
    int rating = 0;
    final feedbackCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (ctx, sSet) => SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Rate Your Experience',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Help us improve by sharing your feedback',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => sSet(() => rating = i + 1),
                    child: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      size: 36,
                      color: i < rating ? Colors.amber : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Additional Feedback',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: feedbackCtrl,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Tell us what you like or what could be improved...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Quick Tags',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final tag in [
                  'Easy to use',
                  'Fast performance',
                  'Great design',
                  'Needs improvement',
                  'Bugs found',
                ])
                  ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      feedbackCtrl.text = feedbackCtrl.text.isEmpty
                          ? tag
                          : '${feedbackCtrl.text}, $tag';
                    },
                  ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: rating == 0
                    ? null
                    : () {
                        AppSnackbar.show(
                          context: context,
                          message: 'Thank you for your feedback!',
                          type: SnackBarType.success,
                        );
                        sSet(() {
                          rating = 0;
                          feedbackCtrl.clear();
                        });
                      },
                child: const Text('Submit Feedback'),
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: TextButton.icon(
                onPressed: () => AppSnackbar.show(
                  context: context,
                  message: 'Thank you for rating us!',
                  type: SnackBarType.success,
                ),
                icon: Icon(Icons.star_border, color: theme.colorScheme.primary),
                label: Text(
                  'Rate us on Play Store',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
