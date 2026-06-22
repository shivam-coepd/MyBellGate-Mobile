import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/event_repository.dart';

// --- Events ---
abstract class EventsEvent {}

class LoadEvents extends EventsEvent {}

class RsvpToEvent extends EventsEvent {
  final int eventId;
  final String status; // 'going', 'maybe', 'not_going'

  RsvpToEvent(this.eventId, this.status);
}

// --- States ---
abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Map<String, dynamic>> events;

  EventsLoaded({required this.events});

  EventsLoaded copyWith({List<Map<String, dynamic>>? events}) {
    return EventsLoaded(
      events: events ?? this.events,
    );
  }
}

class EventsError extends EventsState {
  final String message;

  EventsError(this.message);
}

// --- BLoC ---
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventRepository _repository;

  EventsBloc(this._repository) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<RsvpToEvent>(_onRsvpToEvent);
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());
    try {
      final events = await _repository.getEvents();
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventsError(e.toString()));
    }
  }

  Future<void> _onRsvpToEvent(RsvpToEvent event, Emitter<EventsState> emit) async {
    final currentState = state;
    if (currentState is EventsLoaded) {
      try {
        final rsvpData = await _repository.rsvpEvent(event.eventId, event.status);
        
        final updatedEvents = currentState.events.map((e) {
          if (e['id'] == event.eventId) {
            final newEvent = Map<String, dynamic>.from(e);
            newEvent['attendees'] = rsvpData['attendees'] is int 
                ? rsvpData['attendees'] 
                : int.tryParse(rsvpData['attendees'].toString()) ?? 0;
            if (rsvpData.containsKey('recent_attendees')) {
              newEvent['recent_attendees'] = rsvpData['recent_attendees'];
            }
            newEvent['my_status'] = event.status;
            return newEvent;
          }
          return e;
        }).toList();
        
        emit(currentState.copyWith(events: updatedEvents));
      } catch (e) {
        emit(EventsError(e.toString()));
        emit(currentState);
      }
    }
  }
}
