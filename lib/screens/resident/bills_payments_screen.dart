import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mygate_coepd/blocs/accounting/accounting_bloc.dart';
import 'package:mygate_coepd/models/invoice.dart';
import 'package:shimmer/shimmer.dart';

class BillsPaymentsScreen extends StatefulWidget {
  const BillsPaymentsScreen({super.key});
  @override
  State<BillsPaymentsScreen> createState() => _BillsPaymentsScreenState();
}

class _BillsPaymentsScreenState extends State<BillsPaymentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  String _selectedTab = 'bills';
  List<Invoice> _allInvoices = [];

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
      context.read<AccountingBloc>().add(const LoadInvoices());
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
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

  Map<String, dynamic> _paymentMethodType(String? s) {
    switch (s) {
      case 'upi':
        return {'name': 'UPI', 'color': Colors.blue};
      case 'net_banking':
        return {'name': 'Net Banking', 'color': Colors.purple};
      case 'credit_card':
        return {'name': 'Credit Card', 'color': Colors.orange};
      case 'debit_card':
        return {'name': 'Debit Card', 'color': Colors.red};
      case 'bank_transfer':
        return {'name': 'Bank Transfer', 'color': Colors.green};
      case 'cash':
        return {'name': 'Cash', 'color': Colors.grey};
      case 'cheque':
        return {'name': 'Cheque', 'color': Colors.grey};
      default:
        return {'name': 'Other', 'color': Colors.grey};
    }
  }

  void _showPaymentOptions(Invoice invoice) {
    String method = 'upi';
    final txnCtrl = TextEditingController();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Pay Invoice',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '₹${invoice.grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (invoice.dueDate != null)
                      Text(
                        'Due: ${invoice.dueDate}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(
                    value: 'net_banking',
                    child: Text('Net Banking'),
                  ),
                  DropdownMenuItem(
                    value: 'credit_card',
                    child: Text('Credit Card'),
                  ),
                  DropdownMenuItem(
                    value: 'debit_card',
                    child: Text('Debit Card'),
                  ),
                  DropdownMenuItem(
                    value: 'bank_transfer',
                    child: Text('Bank Transfer'),
                  ),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                ],
                onChanged: (v) => sSet(() => method = v ?? 'upi'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: txnCtrl,
                decoration: InputDecoration(
                  labelText: 'Transaction ID (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sCtx),
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sCtx);
                        context.read<AccountingBloc>().add(
                          ProcessPayment(
                            invoiceId: invoice.id,
                            amount: invoice.grandTotal,
                            paymentMethod: method,
                            transactionId: txnCtrl.text.trim().isNotEmpty
                                ? txnCtrl.text.trim()
                                : null,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text('Pay Now', style: TextStyle(fontSize: 14.sp)),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountingBloc, AccountingState>(
      listener: (ctx, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Payment successful! Receipt: ${state.receiptNumber}',
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _selectedTab = 'history';
          });
          context.read<AccountingBloc>().add(const LoadInvoices());
        } else if (state is AccountingError) {
          log('error in bills payment:${state.message}');
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
          title: const Text('Bills & Payments'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<AccountingBloc, AccountingState>(
          builder: (ctx, state) {
            if (state is AccountingLoading) {
              return const _BillsShimmer();
            }
            if (state is AccountingError) {
              log('error:${state.message}');
              return _errorWidget(
                state.message,
                () => ctx.read<AccountingBloc>().add(const LoadInvoices()),
              );
            }
            if (state is InvoicesLoaded) {
              _allInvoices = state.invoices;
            }

            final pending = _allInvoices
                .where((i) => i.status != 'paid' && i.status != 'cancelled')
                .toList();
            final paid = _allInvoices.where((i) => i.status == 'paid').toList();
            final totalDue = pending.fold<double>(
              0,
              (s, i) => s + i.grandTotal,
            );
            final overdue = pending.where((i) => i.status == 'overdue').length;

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                ctx.read<AccountingBloc>().add(const LoadInvoices());
              },
              child: Column(
                children: [
                  // Tab row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedTab = 'bills'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTab == 'bills'
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardTheme.color,
                              foregroundColor: _selectedTab == 'bills'
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Bills',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                setState(() => _selectedTab = 'history'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _selectedTab == 'history'
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardTheme.color,
                              foregroundColor: _selectedTab == 'history'
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Payment History',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),

                  if (_selectedTab == 'bills') ...[
                    // Summary cards
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        spacing: 10.w,
                        children: [
                          Expanded(
                            child: _summaryCard(
                              'Total Due',
                              '₹${totalDue.toStringAsFixed(2)}',
                              '${pending.length} bill${pending.length == 1 ? '' : 's'}',
                              Colors.red,
                              Icons.warning,
                            ),
                          ),
                          Expanded(
                            child: _summaryCard(
                              'Overdue',
                              '$overdue',
                              overdue > 0
                                  ? 'Needs attention'
                                  : 'You\'re on track',
                              Colors.orange,
                              Icons.schedule,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Expanded(
                      child: pending.isEmpty
                          ? _emptyWidget(
                              'No Pending Bills',
                              'All your bills are paid! 🎉',
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: pending.length,
                              itemBuilder: (_, i) =>
                                  _invoiceCard(pending[i], showPayButton: true),
                            ),
                    ),
                  ] else ...[
                    Expanded(
                      child: paid.isEmpty
                          ? _emptyWidget(
                              'No Payment History',
                              'Paid bills will appear here.',
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: paid.length,
                              itemBuilder: (_, i) =>
                                  _invoiceCard(paid[i], showPayButton: false),
                            ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    String sub,
    Color color,
    IconData icon,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.06),
              color.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 14.sp),
                ),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              sub,
              style: TextStyle(color: Colors.grey, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceCard(Invoice inv, {required bool showPayButton}) {
    final sc = _statusColor(inv.status);
    final pm = _paymentMethodType(inv.paymentMethod);
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.invoiceNumber,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        inv.invoiceDate,
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey),
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
                    inv.statusLabel,
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
            if (inv.flatNumber != null)
              Row(
                children: [
                  Icon(Icons.home, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 5.w),
                  Text(
                    inv.flatNumber!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
            if (inv.dueDate != null)
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 13.sp, color: Colors.grey),
                  SizedBox(width: 5.w),
                  Text(
                    'Due: ${inv.dueDate}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${inv.grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (showPayButton && inv.status != 'paid')
                  ElevatedButton(
                    onPressed: () => _showPaymentOptions(inv),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                    ),
                    child: Text('Pay Now', style: TextStyle(fontSize: 13.sp)),
                  ),
                if (!showPayButton)
                  if (inv.paymentMethod != null)
                    Text(
                      'Paid via ${pm['name']}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: pm['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
            Icons.account_balance_wallet_outlined,
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

class _BillsShimmer extends StatelessWidget {
  const _BillsShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab row shimmer
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Summary cards shimmer
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Invoice card shimmers
            ...List.generate(
              4,
              (_) => Padding(
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14.h,
                                  width: 120.w,
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
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                      Container(
                        height: 12.h,
                        width: 140.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 20.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            height: 36.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
