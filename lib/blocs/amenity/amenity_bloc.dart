import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/models/amenity.dart';
import 'package:mygate_coepd/repositories/amenity_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AmenityEvent extends Equatable {
  const AmenityEvent();
  @override
  List<Object?> get props => [];
}

class LoadAmenities extends AmenityEvent {
  const LoadAmenities();
}

class LoadMyBookings extends AmenityEvent {
  final String? status;
  const LoadMyBookings({this.status});
  @override
  List<Object?> get props => [status];
}

class BookAmenity extends AmenityEvent {
  final String amenityId;
  final String bookingDate;
  final String startTime;
  final String endTime;

  const BookAmenity({
    required this.amenityId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [amenityId, bookingDate, startTime, endTime];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AmenityState extends Equatable {
  const AmenityState();
  @override
  List<Object?> get props => [];
}

class AmenityInitial extends AmenityState {}

class AmenityLoading extends AmenityState {}

class AmenitiesLoaded extends AmenityState {
  final List<Amenity> amenities;
  const AmenitiesLoaded(this.amenities);
  @override
  List<Object?> get props => [amenities];
}

class BookingsLoaded extends AmenityState {
  final List<AmenityBooking> bookings;
  const BookingsLoaded(this.bookings);
  @override
  List<Object?> get props => [bookings];
}

class AmenityBookingSuccess extends AmenityState {
  final AmenityBooking booking;
  const AmenityBookingSuccess(this.booking);
  @override
  List<Object?> get props => [booking];
}

class AmenityError extends AmenityState {
  final String message;
  const AmenityError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AmenityBloc extends Bloc<AmenityEvent, AmenityState> {
  final AmenityRepository _repository;

  AmenityBloc({AmenityRepository? repository})
      : _repository = repository ?? AmenityRepository(),
        super(AmenityInitial()) {
    on<LoadAmenities>(_onLoadAmenities);
    on<LoadMyBookings>(_onLoadMyBookings);
    on<BookAmenity>(_onBookAmenity);
  }

  Future<void> _onLoadAmenities(
      LoadAmenities event, Emitter<AmenityState> emit) async {
    emit(AmenityLoading());
    try {
      final amenities = await _repository.getAmenities();
      emit(AmenitiesLoaded(amenities));
    } catch (e) {
      emit(AmenityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadMyBookings(
      LoadMyBookings event, Emitter<AmenityState> emit) async {
    emit(AmenityLoading());
    try {
      final bookings = await _repository.getMyBookings(status: event.status);
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(AmenityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onBookAmenity(
      BookAmenity event, Emitter<AmenityState> emit) async {
    emit(AmenityLoading());
    try {
      final booking = await _repository.bookAmenity(
        amenityId: event.amenityId,
        bookingDate: event.bookingDate,
        startTime: event.startTime,
        endTime: event.endTime,
      );
      emit(AmenityBookingSuccess(booking));
    } catch (e) {
      emit(AmenityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
