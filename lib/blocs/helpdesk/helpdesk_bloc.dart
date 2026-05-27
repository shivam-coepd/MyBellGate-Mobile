import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/models/ticket.dart';
import 'package:mygate_coepd/repositories/helpdesk_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class HelpdeskEvent extends Equatable {
  const HelpdeskEvent();
  @override
  List<Object?> get props => [];
}

class LoadTickets extends HelpdeskEvent {
  final String? status;
  final String? category;
  final String? priority;
  const LoadTickets({this.status, this.category, this.priority});
  @override
  List<Object?> get props => [status, category, priority];
}

class LoadTicketDetail extends HelpdeskEvent {
  final String ticketId;
  const LoadTicketDetail(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class CreateTicket extends HelpdeskEvent {
  final String title;
  final String description;
  final String category;
  final String priority;
  const CreateTicket({
    required this.title,
    required this.description,
    this.category = 'general',
    this.priority = 'medium',
  });
  @override
  List<Object?> get props => [title, description, category, priority];
}

class UpdateTicketStatus extends HelpdeskEvent {
  final String ticketId;
  final String status;
  const UpdateTicketStatus(this.ticketId, this.status);
  @override
  List<Object?> get props => [ticketId, status];
}

class AddTicketComment extends HelpdeskEvent {
  final String ticketId;
  final String comment;
  const AddTicketComment(this.ticketId, this.comment);
  @override
  List<Object?> get props => [ticketId, comment];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class HelpdeskState extends Equatable {
  const HelpdeskState();
  @override
  List<Object?> get props => [];
}

class HelpdeskInitial extends HelpdeskState {}

class HelpdeskLoading extends HelpdeskState {}

class TicketsLoaded extends HelpdeskState {
  final List<Ticket> tickets;
  const TicketsLoaded(this.tickets);
  @override
  List<Object?> get props => [tickets];
}

class TicketDetailLoaded extends HelpdeskState {
  final Ticket ticket;
  const TicketDetailLoaded(this.ticket);
  @override
  List<Object?> get props => [ticket];
}

class TicketCreated extends HelpdeskState {
  final String ticketId;
  const TicketCreated(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class TicketStatusUpdated extends HelpdeskState {}

class CommentAdded extends HelpdeskState {}

class HelpdeskError extends HelpdeskState {
  final String message;
  const HelpdeskError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class HelpdeskBloc extends Bloc<HelpdeskEvent, HelpdeskState> {
  final HelpdeskRepository _repository;

  HelpdeskBloc({HelpdeskRepository? repository})
      : _repository = repository ?? HelpdeskRepository(),
        super(HelpdeskInitial()) {
    on<LoadTickets>(_onLoadTickets);
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<CreateTicket>(_onCreateTicket);
    on<UpdateTicketStatus>(_onUpdateTicketStatus);
    on<AddTicketComment>(_onAddTicketComment);
  }

  Future<void> _onLoadTickets(
      LoadTickets event, Emitter<HelpdeskState> emit) async {
    emit(HelpdeskLoading());
    try {
      final tickets = await _repository.getTickets(
        status: event.status,
        category: event.category,
        priority: event.priority,
      );
      emit(TicketsLoaded(tickets));
    } catch (e) {
      emit(HelpdeskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadTicketDetail(
      LoadTicketDetail event, Emitter<HelpdeskState> emit) async {
    emit(HelpdeskLoading());
    try {
      final ticket = await _repository.getTicketById(event.ticketId);
      emit(TicketDetailLoaded(ticket));
    } catch (e) {
      emit(HelpdeskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreateTicket(
      CreateTicket event, Emitter<HelpdeskState> emit) async {
    emit(HelpdeskLoading());
    try {
      final id = await _repository.createTicket(
        title: event.title,
        description: event.description,
        category: event.category,
        priority: event.priority,
      );
      emit(TicketCreated(id));
    } catch (e) {
      emit(HelpdeskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateTicketStatus(
      UpdateTicketStatus event, Emitter<HelpdeskState> emit) async {
    emit(HelpdeskLoading());
    try {
      await _repository.updateTicketStatus(event.ticketId, event.status);
      emit(TicketStatusUpdated());
    } catch (e) {
      emit(HelpdeskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddTicketComment(
      AddTicketComment event, Emitter<HelpdeskState> emit) async {
    emit(HelpdeskLoading());
    try {
      await _repository.addComment(event.ticketId, event.comment);
      emit(CommentAdded());
    } catch (e) {
      emit(HelpdeskError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
