import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  InvoiceItem
// ─────────────────────────────────────────────────────────────────────────────
class InvoiceItem extends Equatable {
  final String id;
  final String invoiceId;
  final String? chargeHeadId;
  final String? chargeHeadName;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double gstRate;
  final double gstAmount;
  final double totalAmount;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    this.chargeHeadId,
    this.chargeHeadName,
    this.description,
    this.quantity = 1,
    this.unitPrice = 0,
    this.gstRate = 0,
    this.gstAmount = 0,
    this.totalAmount = 0,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'].toString(),
      invoiceId: json['invoice_id'].toString(),
      chargeHeadId: json['charge_head_id']?.toString(),
      chargeHeadName: json['charge_head_name'],
      description: json['description'],
      quantity: double.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0,
      gstRate: double.tryParse(json['gst_rate']?.toString() ?? '0') ?? 0,
      gstAmount: double.tryParse(json['gst_amount']?.toString() ?? '0') ?? 0,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    invoiceId,
    chargeHeadId,
    quantity,
    unitPrice,
    totalAmount,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  Invoice
// ─────────────────────────────────────────────────────────────────────────────
class Invoice extends Equatable {
  final String id;
  final String invoiceNumber;
  final String? flatId;
  final String? flatNumber;
  final String? residentId;
  final String? residentName;
  final String? societyId;
  final String invoiceDate;
  final String? dueDate;
  final double totalAmount;
  final double totalGst;
  final double totalDiscount;
  final double arrearsAmount;
  final double fineAmount;
  final String
  status; // draft | sent | partially_paid | paid | overdue | cancelled
  final String? notes;
  final List<InvoiceItem> items;
  final String? createdAt;
  final String? paymentMethod;
  final String? paidDate;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    this.flatId,
    this.flatNumber,
    this.residentId,
    this.residentName,
    this.societyId,
    required this.invoiceDate,
    this.dueDate,
    this.totalAmount = 0,
    this.totalGst = 0,
    this.totalDiscount = 0,
    this.arrearsAmount = 0,
    this.fineAmount = 0,
    required this.status,
    this.notes,
    this.items = const [],
    this.createdAt,
    this.paymentMethod,
    this.paidDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    List<InvoiceItem> parsedItems = [];
    if (json['items'] != null) {
      parsedItems = (json['items'] as List)
          .map((i) => InvoiceItem.fromJson(i))
          .toList();
    }

    return Invoice(
      id: json['id'].toString(),
      invoiceNumber: json['invoice_number'] ?? '',
      flatId: json['flat_id']?.toString(),
      flatNumber: json['flat_number'],
      residentId: json['resident_id']?.toString(),
      residentName: json['resident_name'],
      societyId: json['society_id']?.toString(),
      invoiceDate: json['invoice_date'] ?? '',
      dueDate: json['due_date'],
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      totalGst: double.tryParse(json['total_gst']?.toString() ?? '0') ?? 0,
      totalDiscount:
          double.tryParse(json['total_discount']?.toString() ?? '0') ?? 0,
      arrearsAmount:
          double.tryParse(json['arrears_amount']?.toString() ?? '0') ?? 0,
      fineAmount: double.tryParse(json['fine_amount']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'draft',
      paymentMethod: json['payment_method'],
      paidDate: json['paid_date'],
      notes: json['notes'],
      items: parsedItems,
      createdAt: json['created_at'],
    );
  }

  double get grandTotal =>
      totalAmount + totalGst + arrearsAmount + fineAmount - totalDiscount;

  String get statusLabel {
    switch (status) {
      case 'sent':
        return 'Sent';
      case 'partially_paid':
        return 'Partially Paid';
      case 'paid':
        return 'Paid';
      case 'overdue':
        return 'Overdue';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Draft';
    }
  }

  @override
  List<Object?> get props => [
    id,
    invoiceNumber,
    flatId,
    residentId,
    invoiceDate,
    status,
    totalAmount,
  ];
}
