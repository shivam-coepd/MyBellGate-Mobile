import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mygate_coepd/repositories/guard_repository.dart';

part 'guard_event.dart';
part 'guard_state.dart';

class GuardBloc extends Bloc<GuardEvent, GuardState> {
  final GuardRepository _repository;

  GuardBloc({required GuardRepository repository})
    : _repository = repository,
      super(GuardInitial()) {
    on<LoadVisitors>(_onLoadVisitors);
    on<LoadVisitorById>(_onLoadVisitorById);
    on<AddVisitor>(_onAddVisitor);
    on<UpdateVisitorStatus>(_onUpdateVisitorStatus);
    on<LoadSecurityAlerts>(_onLoadSecurityAlerts);
    on<ReportSecurityAlert>(_onReportSecurityAlert);
    on<UpdateAlertStatus>(_onUpdateAlertStatus);
    on<LoadEmergencyContacts>(_onLoadEmergencyContacts);
    on<LoadGuardDashboard>(_onLoadGuardDashboard);
    on<LoadResidents>(_onLoadResidents);
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicleEntry>(_onAddVehicleEntry);
    on<UpdateVehicleEntryStatus>(_onUpdateVehicleEntryStatus);
    on<LoadGuardAttendance>(_onLoadGuardAttendance);
    on<MarkAttendance>(_onMarkAttendance);
  }

  Future<void> _onLoadVisitors(
    LoadVisitors event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final visitors = await _repository.getVisitors(
        status: event.status,
        visitorType: event.visitorType,
        page: event.page,
        limit: event.limit,
      );
      emit(VisitorsLoaded(visitors));
    } catch (e) {
      log('LoadVisitors error: $e');
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadVisitorById(
    LoadVisitorById event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final visitor = await _repository.getVisitorById(event.id);
      if (visitor != null) {
        emit(VisitorDetailLoaded(visitor));
      } else {
        emit(const GuardError('Visitor not found'));
      }
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddVisitor(AddVisitor event, Emitter<GuardState> emit) async {
    emit(GuardLoading());
    try {
      final result = await _repository.addVisitor(
        name: event.name,
        phone: event.phone,
        purpose: event.purpose,
        email: event.email,
        visitDate: event.visitDate,
        visitTime: event.visitTime,
        expectedExitTime: event.expectedExitTime,
        visitorType: event.visitorType,
        imageUrl: event.imageUrl,
        residentId: event.residentId,
      );
      emit(VisitorAdded(result['visitor_id']?.toString() ?? ''));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateVisitorStatus(
    UpdateVisitorStatus event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      await _repository.updateVisitorStatus(event.id, event.status);
      emit(VisitorStatusUpdated(event.id, event.status));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadSecurityAlerts(
    LoadSecurityAlerts event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final alerts = await _repository.getSecurityAlerts(
        status: event.status,
        severity: event.severity,
        alertType: event.alertType,
        page: event.page,
        limit: event.limit,
      );
      emit(SecurityAlertsLoaded(alerts));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onReportSecurityAlert(
    ReportSecurityAlert event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final result = await _repository.reportSecurityAlert(
        alertType: event.alertType,
        description: event.description,
        severity: event.severity,
        imageUrl: event.imageUrl,
        location: event.location,
      );
      emit(SecurityAlertReported(result['alert_id']?.toString() ?? ''));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateAlertStatus(
    UpdateAlertStatus event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      await _repository.updateAlertStatus(event.id, event.status);
      emit(AlertStatusUpdated(event.id, event.status));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadEmergencyContacts(
    LoadEmergencyContacts event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final contacts = await _repository.getEmergencyContacts(
        contactType: event.contactType,
        page: event.page,
        limit: event.limit,
      );
      emit(EmergencyContactsLoaded(contacts));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadGuardDashboard(
    LoadGuardDashboard event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final pendingVisitors = await _repository.getVisitors(
        status: 'pending',
        limit: 10,
      );
      final recentVisitors = await _repository.getVisitors(limit: 5);
      emit(
        GuardDashboardLoaded(
          pendingVisitors: pendingVisitors,
          recentActivity: recentVisitors,
        ),
      );
    } catch (e) {
      log('LoadGuardDashboard error: $e');
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadResidents(
    LoadResidents event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final residents = await _repository.getResidents(
        search: event.search,
        page: event.page,
        limit: event.limit,
      );
      emit(ResidentsLoaded(residents));
    } catch (e) {
      log('LoadResidents error: $e');
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final vehicles = await _repository.getVehicleEntries(
        status: event.status,
        page: event.page,
        limit: event.limit,
      );
      emit(VehiclesLoaded(vehicles));
    } catch (e) {
      log('LoadVehicles error: $e');
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddVehicleEntry(
    AddVehicleEntry event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final result = await _repository.addVehicleEntry(
        vehicleType: event.vehicleType,
        vehicleNumber: event.vehicleNumber,
        driverName: event.driverName,
        driverPhone: event.driverPhone,
        purpose: event.purpose,
        residentId: event.residentId,
      );
      emit(VehicleEntryAdded(result['entry_id']?.toString() ?? ''));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateVehicleEntryStatus(
    UpdateVehicleEntryStatus event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      await _repository.updateVehicleEntryStatus(event.id, event.status);
      emit(VehicleEntryStatusUpdated(event.id, event.status));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLoadGuardAttendance(
    LoadGuardAttendance event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      final attendance = await _repository.getGuardAttendance();
      emit(
        AttendanceLoaded(
          todayRecord: attendance['today'],
          history: List<Map<String, dynamic>>.from(attendance['history'] ?? []),
        ),
      );
    } catch (e) {
      log('LoadGuardAttendance error: $e');
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMarkAttendance(
    MarkAttendance event,
    Emitter<GuardState> emit,
  ) async {
    emit(GuardLoading());
    try {
      await _repository.markAttendance(event.type);
      emit(AttendanceMarked(event.type));
    } catch (e) {
      emit(GuardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
