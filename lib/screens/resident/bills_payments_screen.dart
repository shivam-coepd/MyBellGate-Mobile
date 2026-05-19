import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BillsPaymentsScreen extends StatefulWidget {
  const BillsPaymentsScreen({super.key});

  @override
  State<BillsPaymentsScreen> createState() => _BillsPaymentsScreenState();
}

class _BillsPaymentsScreenState extends State<BillsPaymentsScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'bills';
  final bool _showPaymentMethods = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBills = [];
  List<Map<String, dynamic>> _filteredPaymentHistory = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _bills = [
    {
      'id': 1,
      'title': 'Maintenance Charges',
      'amount': '₹2,500',
      'dueDate': 'May 25, 2023',
      'status': 'Due',
      'period': 'April 2023',
      'category': 'Maintenance',
    },
    {
      'id': 2,
      'title': 'Water Charges',
      'amount': '₹800',
      'dueDate': 'May 30, 2023',
      'status': 'Due',
      'period': 'April 2023',
      'category': 'Utilities',
    },
    {
      'id': 3,
      'title': 'Parking Fees',
      'amount': '₹1,200',
      'dueDate': 'Jun 5, 2023',
      'status': 'Upcoming',
      'period': 'May 2023',
      'category': 'Facility',
    },
  ];

  final List<Map<String, dynamic>> _paymentHistory = [
    {
      'id': 1,
      'title': 'Maintenance Charges',
      'amount': '₹2,500',
      'date': 'Apr 15, 2023',
      'status': 'Paid',
      'method': 'UPI',
      'receipt': 'REC001234',
    },
    {
      'id': 2,
      'title': 'Water Charges',
      'amount': '₹750',
      'date': 'Mar 20, 2023',
      'status': 'Paid',
      'method': 'Credit Card',
      'receipt': 'REC001233',
    },
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 1,
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'name': 'UPI',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple,
    },
    {
      'id': 3,
      'name': 'Net Banking',
      'icon': Icons.account_balance,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredBills = _bills;
    _filteredPaymentHistory = _paymentHistory;
    _searchController.addListener(_filterBills);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animations after a small delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _filterBills() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();

      _filteredBills = _bills.where((bill) {
        return searchTerm.isEmpty ||
            bill['title'].toLowerCase().contains(searchTerm) ||
            bill['category'].toLowerCase().contains(searchTerm) ||
            bill['status'].toLowerCase().contains(searchTerm);
      }).toList();

      _filteredPaymentHistory = _paymentHistory.where((payment) {
        return searchTerm.isEmpty ||
            payment['title'].toLowerCase().contains(searchTerm) ||
            payment['method'].toLowerCase().contains(searchTerm) ||
            payment['status'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBills);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Bills Management',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        // foregroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: Column(
          spacing: 10.h,
          children: [
            // Tab Selection
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selectedTab = 'bills'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 'bills'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardTheme.color,
                        foregroundColor: _selectedTab == 'bills'
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('Bills', style: TextStyle(fontSize: 16.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _selectedTab = 'history'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedTab == 'history'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardTheme.color,
                        foregroundColor: _selectedTab == 'history'
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Payment History',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content based on selected tab
            Expanded(
              child: _selectedTab == 'bills'
                  ? _buildBillsContent()
                  : _buildPaymentHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsContent() {
    return Column(
      children: [
        // Summary Cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFF0F0),
                            const Color(0xFFFFF8F8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.warning,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Total Due',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '₹3,300',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '2 bills pending',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.1, 0.4, curve: Curves.elasticOut),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFFF8F0),
                            const Color(0xFFFFFCF8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.schedule,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Upcoming',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '₹1,200',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '1 bill upcoming',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Bills List
        Expanded(
          child: _filteredBills.isEmpty
              ? _buildEmptyBillsState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = _filteredBills[index];
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.2 + (0.1 * index),
                            0.5 + (0.1 * index),
                            curve: Curves.elasticOut,
                          ),
                        ),
                      ),
                      child: Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).cardTheme.color!,
                                Theme.of(
                                  context,
                                ).cardTheme.color!.withValues(alpha: 0.95),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bill['title'],
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            bill['period'],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(bill['status']),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        bill['status'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Due: ${bill['dueDate']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      bill['amount'],
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showPaymentOptions(bill);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 12.h,
                                        ),
                                      ),
                                      child: Text(
                                        'Pay Now',
                                        style: TextStyle(fontSize: 14.sp),
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory() {
    return _filteredPaymentHistory.isEmpty
        ? _buildEmptyHistoryState()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _filteredPaymentHistory.length,
            itemBuilder: (context, index) {
              final payment = _filteredPaymentHistory[index];
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      0.1 * index,
                      0.3 + (0.1 * index),
                      curve: Curves.elasticOut,
                    ),
                  ),
                ),
                child: Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              payment['title'],
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              payment['amount'],
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              payment['date'],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Paid',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.payment,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Method: ${payment['method']}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 16.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Receipt: ${payment['receipt']}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildEmptyBillsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              size: 50,
              color: Color(0xFF006D77),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Bills Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'You don\'t have any bills'
                : 'No bills match your search',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.history,
              size: 50,
              color: Color(0xFF006D77),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Payment History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _searchController.text.isEmpty
                ? 'You don\'t have any payment history'
                : 'No history matches your search',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(Map<String, dynamic> bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._paymentMethods.map((method) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: method['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(method['icon'], color: method['color']),
                    ),
                    title: Text(method['name']),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).pop();
                      _processPayment(bill, method);
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _processPayment(Map<String, dynamic> bill, Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bill: ${bill['title']}'),
              Text('Amount: ${bill['amount']}'),
              Text('Payment Method: ${method['name']}'),
              const SizedBox(height: 16),
              const Text('Please confirm to proceed with payment'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Process the payment
                _completePayment(bill);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Pay Now'),
            ),
          ],
        );
      },
    );
  }

  void _completePayment(Map<String, dynamic> bill) {
    // Show payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Processing payment...'),
            ],
          ),
        );
      },
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close processing dialog
      Navigator.of(context).pop(); // Close payment options

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment of ${bill['amount']} completed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Update bill status
      setState(() {
        // Find and update the bill status
        for (var i = 0; i < _bills.length; i++) {
          if (_bills[i]['id'] == bill['id']) {
            _bills[i] = Map<String, dynamic>.from(_bills[i])
              ..['status'] = 'Paid';
            break;
          }
        }
        _filterBills(); // Refresh filtered list
      });
    });
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search bills...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006D77),
                  ),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Bills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  FilterChip(
                    label: const Text('Due'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Upcoming'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Paid'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  FilterChip(
                    label: const Text('Maintenance'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Utilities'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                  FilterChip(
                    label: const Text('Facility'),
                    selected: false,
                    onSelected: (selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Date Range',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start Date'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('End Date'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Filters applied')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006D77),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Due':
        return Colors.red;
      case 'Paid':
        return Colors.green;
      case 'Upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
