import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/accounting/accounting_bloc.dart';
import 'package:mygate_coepd/models/invoice.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<_TabInfo> _tabs = [
    _TabInfo('All', null),
    _TabInfo('Pending', 'sent'),
    _TabInfo('Paid', 'paid'),
    _TabInfo('Overdue', 'overdue'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        context.read<AccountingBloc>().add(
          LoadInvoices(status: _tabs[_tabCtrl.index].status),
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountingBloc>().add(const LoadInvoices());
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'partially_paid':
        return Colors.orange;
      case 'sent':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'paid':
        return Icons.check_circle_outline;
      case 'overdue':
        return Icons.error_outline;
      case 'partially_paid':
        return Icons.pending_outlined;
      case 'sent':
        return Icons.send_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  String _formatDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return d;
    }
  }

  void _showInvoiceDetail(Invoice invoice) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollCtrl,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '#${invoice.invoiceNumber}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(
                        invoice.status,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(invoice.status),
                          size: 14,
                          color: _statusColor(invoice.status),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          invoice.statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(invoice.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _detailRow(
                theme,
                'Invoice Date',
                _formatDate(invoice.invoiceDate),
              ),
              if (invoice.dueDate != null)
                _detailRow(theme, 'Due Date', _formatDate(invoice.dueDate!)),
              if (invoice.flatNumber != null)
                _detailRow(theme, 'Flat', invoice.flatNumber!),
              SizedBox(height: 16.h),
              Divider(),
              if (invoice.items.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  'Items',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                ...invoice.items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.chargeHeadName ??
                                    item.description ??
                                    'Charge',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (item.description != null &&
                                  item.chargeHeadName != null)
                                Text(
                                  item.description!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${item.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
              ],
              _detailRow(
                theme,
                'Subtotal',
                '₹${invoice.totalAmount.toStringAsFixed(2)}',
              ),
              if (invoice.totalGst > 0)
                _detailRow(
                  theme,
                  'GST',
                  '₹${invoice.totalGst.toStringAsFixed(2)}',
                ),
              if (invoice.totalDiscount > 0)
                _detailRow(
                  theme,
                  'Discount',
                  '- ₹${invoice.totalDiscount.toStringAsFixed(2)}',
                ),
              if (invoice.arrearsAmount > 0)
                _detailRow(
                  theme,
                  'Arrears',
                  '₹${invoice.arrearsAmount.toStringAsFixed(2)}',
                ),
              if (invoice.fineAmount > 0)
                _detailRow(
                  theme,
                  'Late Fine',
                  '₹${invoice.fineAmount.toStringAsFixed(2)}',
                ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '₹${invoice.grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'Notes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  invoice.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              if (invoice.status != 'paid' && invoice.status != 'cancelled')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showPaymentOptions(invoice);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay Now'),
                  ),
                ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(Invoice invoice) {
    String method = 'UPI';
    final txnCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sCtx, sSet) => Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 24.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: 16.h),
              Text(
                'Pay ₹${invoice.grandTotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16.h),
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8.h),
              ...['UPI', 'Card', 'Net Banking'].map(
                (m) => RadioListTile<String>(
                  title: Text(m),
                  value: m,
                  groupValue: method,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) => sSet(() => method = v!),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: txnCtrl,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID (optional)',
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    context.read<AccountingBloc>().add(
                      ProcessPayment(
                        invoiceId: invoice.id,
                        amount: invoice.grandTotal,
                        paymentMethod: method.toLowerCase(),
                        transactionId: txnCtrl.text.isNotEmpty
                            ? txnCtrl.text
                            : null,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Payment submitted successfully!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: const Text('Confirm Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order History'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search by invoice number...',
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
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
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),

          // Content
          Expanded(
            child: BlocBuilder<AccountingBloc, AccountingState>(
              builder: (ctx, state) {
                if (state is AccountingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AccountingError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 12.h),
                          Text(state.message, textAlign: TextAlign.center),
                          SizedBox(height: 12.h),
                          ElevatedButton(
                            onPressed: () => ctx.read<AccountingBloc>().add(
                              LoadInvoices(
                                status: _tabs[_tabCtrl.index].status,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is InvoicesLoaded) {
                  var invoices = state.invoices;
                  if (_searchQuery.isNotEmpty) {
                    invoices = invoices
                        .where(
                          (inv) =>
                              inv.invoiceNumber.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              (inv.flatNumber?.toLowerCase().contains(
                                    _searchQuery,
                                  ) ??
                                  false),
                        )
                        .toList();
                  }
                  if (invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No matching invoices'
                                : 'No invoices found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Your invoices will appear here',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Summary card
                  final totalAmount = invoices.fold(
                    0.0,
                    (s, i) => s + i.grandTotal,
                  );
                  final paidCount = invoices
                      .where((i) => i.status == 'paid')
                      .length;
                  final pendingCount = invoices
                      .where(
                        (i) => i.status != 'paid' && i.status != 'cancelled',
                      )
                      .length;

                  return RefreshIndicator(
                    onRefresh: () async => ctx.read<AccountingBloc>().add(
                      LoadInvoices(status: _tabs[_tabCtrl.index].status),
                    ),
                    child: ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        // Summary
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                ),
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _summaryItem(
                                  theme,
                                  'Total',
                                  '₹${totalAmount.toStringAsFixed(0)}',
                                  Icons.account_balance_wallet_outlined,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              Expanded(
                                child: _summaryItem(
                                  theme,
                                  'Paid',
                                  '$paidCount',
                                  Icons.check_circle_outline,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              Expanded(
                                child: _summaryItem(
                                  theme,
                                  'Pending',
                                  '$pendingCount',
                                  Icons.pending_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Invoice list
                        ...invoices.map(
                          (invoice) => _invoiceCard(theme, invoice),
                        ),
                      ],
                    ),
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'No invoices yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _invoiceCard(ThemeData theme, Invoice invoice) {
    final color = _statusColor(invoice.status);
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showInvoiceDetail(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _statusIcon(invoice.status),
                  color: color,
                  size: 22,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${invoice.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatDate(invoice.invoiceDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (invoice.flatNumber != null)
                      Text(
                        invoice.flatNumber!,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${invoice.grandTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      invoice.statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String label;
  final String? status;
  _TabInfo(this.label, this.status);
}
