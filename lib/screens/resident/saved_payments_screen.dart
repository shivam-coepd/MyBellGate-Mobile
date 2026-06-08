import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SavedPaymentsScreen extends StatefulWidget {
  const SavedPaymentsScreen({super.key});

  @override
  State<SavedPaymentsScreen> createState() => _SavedPaymentsScreenState();
}

class _SavedPaymentsScreenState extends State<SavedPaymentsScreen> {
  final List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: '1', type: 'upi', label: 'Google Pay',
      detail: 'user@okaxis', isDefault: true,
      icon: Icons.g_mobiledata, color: const Color(0xFF4285F4),
    ),
    _PaymentMethod(
      id: '2', type: 'upi', label: 'PhonePe',
      detail: '9876543210@ybl', isDefault: false,
      icon: Icons.phone_android, color: const Color(0xFF5F259F),
    ),
    _PaymentMethod(
      id: '3', type: 'card', label: 'HDFC Debit Card',
      detail: '•••• •••• •••• 4521', isDefault: false,
      icon: Icons.credit_card, color: const Color(0xFF004C8F),
    ),
    _PaymentMethod(
      id: '4', type: 'card', label: 'SBI Credit Card',
      detail: '•••• •••• •••• 8834', isDefault: false,
      icon: Icons.credit_card, color: const Color(0xFF1A3E72),
    ),
    _PaymentMethod(
      id: '5', type: 'bank', label: 'Axis Bank Account',
      detail: 'Savings •••• 6789', isDefault: false,
      icon: Icons.account_balance, color: const Color(0xFF97144D),
    ),
  ];

  void _showSnackBar(String msg, {Color? bg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddPaymentSheet() {
    final theme = Theme.of(context);
    String selectedType = 'upi';
    final labelCtrl = TextEditingController();
    final detailCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, sSet) => Container(
          padding: EdgeInsets.only(
            left: 24.w, right: 24.w, top: 20.h,
            bottom: MediaQuery.of(sCtx).viewInsets.bottom + 24.h,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
              )),
              SizedBox(height: 20.h),
              Text('Add Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: 20.h),
              Text('Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  for (final t in ['upi', 'card', 'bank'])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => sSet(() => selectedType = t),
                        child: Container(
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: selectedType == t
                                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedType == t ? theme.colorScheme.primary : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                t == 'upi' ? Icons.account_balance_wallet_outlined
                                    : t == 'card' ? Icons.credit_card_outlined
                                    : Icons.account_balance_outlined,
                                color: selectedType == t ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                t == 'upi' ? 'UPI' : t == 'card' ? 'Card' : 'Bank',
                                style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500,
                                  color: selectedType == t ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: labelCtrl,
                decoration: InputDecoration(
                  labelText: selectedType == 'upi' ? 'App Name'
                      : selectedType == 'card' ? 'Card Name'
                      : 'Bank Name',
                  hintText: selectedType == 'upi' ? 'e.g. Google Pay, PhonePe'
                      : selectedType == 'card' ? 'e.g. HDFC Debit Card'
                      : 'e.g. Axis Bank',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: detailCtrl,
                decoration: InputDecoration(
                  labelText: selectedType == 'upi' ? 'UPI ID'
                      : selectedType == 'card' ? 'Card Number (last 4)'
                      : 'Account Number (last 4)',
                  hintText: selectedType == 'upi'
                      ? 'e.g. user@okaxis'
                      : selectedType == 'card' ? 'e.g. 4521' : 'e.g. 6789',
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (labelCtrl.text.isEmpty || detailCtrl.text.isEmpty) {
                      _showSnackBar('Please fill in all fields');
                      return;
                    }
                    final display = selectedType == 'upi'
                        ? detailCtrl.text
                        : selectedType == 'card'
                        ? '•••• •••• •••• ${detailCtrl.text}'
                        : 'Savings •••• ${detailCtrl.text}';
                    setState(() {
                      _methods.add(_PaymentMethod(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        type: selectedType,
                        label: labelCtrl.text,
                        detail: display,
                        isDefault: _methods.isEmpty,
                        icon: selectedType == 'upi' ? Icons.account_balance_wallet_outlined
                            : selectedType == 'card' ? Icons.credit_card : Icons.account_balance,
                        color: theme.colorScheme.primary,
                      ));
                    });
                    Navigator.pop(ctx);
                    _showSnackBar('Payment method added', bg: Colors.green);
                  },
                  child: const Text('Add Payment Method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove Payment Method'),
        content: const Text('Are you sure you want to remove this payment method?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _methods.removeWhere((m) => m.id == id));
              _showSnackBar('Payment method removed');
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _setDefault(String id) {
    setState(() {
      for (var m in _methods) {
        m = _PaymentMethod(
          id: m.id, type: m.type, label: m.label,
          detail: m.detail, icon: m.icon, color: m.color,
          isDefault: m.id == id,
        );
        final idx = _methods.indexWhere((e) => e.id == m.id);
        _methods[idx] = m;
      }
    });
    _showSnackBar('Default payment method updated', bg: Colors.green);
  }

  void _showOptions(String id, bool isDefault) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              margin: EdgeInsets.only(top: 14.h), width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: Colors.grey[500], borderRadius: BorderRadius.circular(30)),
            )),
            SizedBox(height: 12.h),
            if (!isDefault)
              ListTile(
                leading: Icon(Icons.star_outline, color: Theme.of(context).colorScheme.primary),
                title: const Text('Set as Default'),
                onTap: () { Navigator.pop(ctx); _setDefault(id); },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remove', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(ctx); _showDeleteConfirm(id); },
            ),
            SizedBox(height: 8.h),
          ],
        ),
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
        title: const Text('Saved Payments'),
      ),
      body: _methods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card_off_outlined, size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  SizedBox(height: 16.h),
                  Text('No payment methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  SizedBox(height: 6.h),
                  Text('Add a payment method for quick checkout',
                      style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant)),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: _showAddPaymentSheet,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Payment Method'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Summary
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                        theme.colorScheme.primary.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: theme.colorScheme.primary, size: 28),
                      SizedBox(width: 14.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_methods.length} payment method${_methods.length == 1 ? '' : 's'} saved',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Default: ${_methods.firstWhere((m) => m.isDefault, orElse: () => _methods.first).label}',
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Grouped by type
                Text('UPI', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
                SizedBox(height: 8.h),
                ..._methods.where((m) => m.type == 'upi').map((m) => _paymentCard(theme, m)),

                if (_methods.any((m) => m.type == 'card')) ...[
                  SizedBox(height: 16.h),
                  Text('CARDS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
                  SizedBox(height: 8.h),
                  ..._methods.where((m) => m.type == 'card').map((m) => _paymentCard(theme, m)),
                ],

                if (_methods.any((m) => m.type == 'bank')) ...[
                  SizedBox(height: 16.h),
                  Text('BANK ACCOUNTS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
                  SizedBox(height: 8.h),
                  ..._methods.where((m) => m.type == 'bank').map((m) => _paymentCard(theme, m)),
                ],

                SizedBox(height: 24.h),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _paymentCard(ThemeData theme, _PaymentMethod m) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOptions(m.id, m.isDefault),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(m.icon, color: m.color, size: 22),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(m.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        if (m.isDefault) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Default', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green)),
                          ),
                        ],
                      ],
                    ),
                    Text(m.detail, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String id;
  final String type;
  final String label;
  final String detail;
  final bool isDefault;
  final IconData icon;
  final Color color;

  _PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.detail,
    required this.isDefault,
    required this.icon,
    required this.color,
  });
}
