import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/models/invoice.dart';
import 'package:mygate_coepd/repositories/accounting_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AccountingEvent extends Equatable {
  const AccountingEvent();
  @override
  List<Object?> get props => [];
}

class LoadInvoices extends AccountingEvent {
  final String? status;
  const LoadInvoices({this.status});
  @override
  List<Object?> get props => [status];
}

class LoadInvoiceDetail extends AccountingEvent {
  final String invoiceId;
  const LoadInvoiceDetail(this.invoiceId);
  @override
  List<Object?> get props => [invoiceId];
}

class ProcessPayment extends AccountingEvent {
  final String invoiceId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String? notes;

  const ProcessPayment({
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [invoiceId, amount, paymentMethod, transactionId];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AccountingState extends Equatable {
  const AccountingState();
  @override
  List<Object?> get props => [];
}

class AccountingInitial extends AccountingState {}

class AccountingLoading extends AccountingState {}

class InvoicesLoaded extends AccountingState {
  final List<Invoice> invoices;
  const InvoicesLoaded(this.invoices);
  @override
  List<Object?> get props => [invoices];
}

class InvoiceDetailLoaded extends AccountingState {
  final Invoice invoice;
  const InvoiceDetailLoaded(this.invoice);
  @override
  List<Object?> get props => [invoice];
}

class PaymentSuccess extends AccountingState {
  final String paymentReference;
  final String receiptNumber;
  const PaymentSuccess({required this.paymentReference, required this.receiptNumber});
  @override
  List<Object?> get props => [paymentReference, receiptNumber];
}

class AccountingError extends AccountingState {
  final String message;
  const AccountingError(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentFailure extends AccountingState {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AccountingBloc extends Bloc<AccountingEvent, AccountingState> {
  final AccountingRepository _repository;

  AccountingBloc({AccountingRepository? repository})
      : _repository = repository ?? AccountingRepository(),
        super(AccountingInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<LoadInvoiceDetail>(_onLoadInvoiceDetail);
    on<ProcessPayment>(_onProcessPayment);
  }

  Future<void> _onLoadInvoices(
      LoadInvoices event, Emitter<AccountingState> emit) async {
    emit(AccountingLoading());
    try {
      final invoices = await _repository.getInvoices(status: event.status);
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(AccountingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadInvoiceDetail(
      LoadInvoiceDetail event, Emitter<AccountingState> emit) async {
    emit(AccountingLoading());
    try {
      final invoice = await _repository.getInvoiceById(event.invoiceId);
      emit(InvoiceDetailLoaded(invoice));
    } catch (e) {
      emit(AccountingError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onProcessPayment(
      ProcessPayment event, Emitter<AccountingState> emit) async {
    emit(AccountingLoading());
    try {
      final result = await _repository.processPayment(
        invoiceId: event.invoiceId,
        amount: event.amount,
        paymentMethod: event.paymentMethod,
        transactionId: event.transactionId,
        notes: event.notes,
      );
      emit(PaymentSuccess(
        paymentReference: result['payment_reference'] ?? '',
        receiptNumber: result['receipt_number'] ?? '',
      ));
    } catch (e) {
      emit(PaymentFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
