part of 'guard_bloc.dart';

abstract class GuardEvent extends Equatable {
  const GuardEvent();
  @override
  List<Object?> get props => [];
}

class LoadGuardDashboard extends GuardEvent {
  const LoadGuardDashboard();
}

class LoadVisitors extends GuardEvent {
  final String? status;
  final String? visitorType;
  final int page;
  final int limit;

  const LoadVisitors({
    this.status,
    this.visitorType,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [status, visitorType, page, limit];
}

class LoadVisitorById extends GuardEvent {
  final int id;
  const LoadVisitorById(this.id);
  @override
  List<Object?> get props => [id];
}

class AddVisitor extends GuardEvent {
  final String name;
  final String phone;
  final String purpose;
  final String? email;
  final String? visitDate;
  final String? visitTime;
  final String? expectedExitTime;
  final String? visitorType;
  final String? imageUrl;
  final int? residentId;

  const AddVisitor({
    required this.name,
    required this.phone,
    required this.purpose,
    this.email,
    this.visitDate,
    this.visitTime,
    this.expectedExitTime,
    this.visitorType,
    this.imageUrl,
    this.residentId,
  });

  @override
  List<Object?> get props => [name, phone, purpose, visitorType, residentId];
}

class UpdateVisitorStatus extends GuardEvent {
  final int id;
  final String status;

  const UpdateVisitorStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class LoadSecurityAlerts extends GuardEvent {
  final String? status;
  final String? severity;
  final String? alertType;
  final int page;
  final int limit;

  const LoadSecurityAlerts({
    this.status,
    this.severity,
    this.alertType,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [status, severity, alertType, page, limit];
}

class ReportSecurityAlert extends GuardEvent {
  final String alertType;
  final String description;
  final String severity;
  final String? imageUrl;
  final String? location;

  const ReportSecurityAlert({
    required this.alertType,
    required this.description,
    this.severity = 'medium',
    this.imageUrl,
    this.location,
  });

  @override
  List<Object?> get props => [alertType, description, severity];
}

class UpdateAlertStatus extends GuardEvent {
  final int id;
  final String status;

  const UpdateAlertStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class LoadEmergencyContacts extends GuardEvent {
  final String? contactType;
  final int page;
  final int limit;

  const LoadEmergencyContacts({
    this.contactType,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [contactType, page, limit];
}

class LoadResidents extends GuardEvent {
  final String? search;
  final int page;
  final int limit;

  const LoadResidents({this.search, this.page = 1, this.limit = 50});

  @override
  List<Object?> get props => [search, page, limit];
}

class LoadVehicles extends GuardEvent {
  final String? status;
  final int page;
  final int limit;

  const LoadVehicles({this.status, this.page = 1, this.limit = 50});

  @override
  List<Object?> get props => [status, page, limit];
}

class AddVehicleEntry extends GuardEvent {
  final String vehicleType;
  final String vehicleNumber;
  final String driverName;
  final String driverPhone;
  final String purpose;
  final int? residentId;

  const AddVehicleEntry({
    required this.vehicleType,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverPhone,
    required this.purpose,
    this.residentId,
  });

  @override
  List<Object?> get props => [
    vehicleType,
    vehicleNumber,
    driverName,
    driverPhone,
    purpose,
  ];
}

class UpdateVehicleEntryStatus extends GuardEvent {
  final int id;
  final String status; // 'inside' | 'exited'

  const UpdateVehicleEntryStatus(this.id, this.status);

  @override
  List<Object?> get props => [id, status];
}

class LoadGuardAttendance extends GuardEvent {
  const LoadGuardAttendance();
}

class MarkAttendance extends GuardEvent {
  final String type; // 'in' | 'out'
  const MarkAttendance(this.type);
  @override
  List<Object?> get props => [type];
}
