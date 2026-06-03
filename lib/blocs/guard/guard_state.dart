part of 'guard_bloc.dart';

abstract class GuardState extends Equatable {
  const GuardState();
  @override
  List<Object?> get props => [];
}

class GuardInitial extends GuardState {}

class GuardLoading extends GuardState {}

class GuardDashboardLoaded extends GuardState {
  final List<Map<String, dynamic>> pendingVisitors;
  final List<Map<String, dynamic>> recentActivity;

  const GuardDashboardLoaded({
    required this.pendingVisitors,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [pendingVisitors, recentActivity];
}

class VisitorsLoaded extends GuardState {
  final List<Map<String, dynamic>> visitors;
  const VisitorsLoaded(this.visitors);
  @override
  List<Object?> get props => [visitors];
}

class VisitorDetailLoaded extends GuardState {
  final Map<String, dynamic> visitor;
  const VisitorDetailLoaded(this.visitor);
  @override
  List<Object?> get props => [visitor];
}

class VisitorAdded extends GuardState {
  final String visitorId;
  const VisitorAdded(this.visitorId);
  @override
  List<Object?> get props => [visitorId];
}

class VisitorStatusUpdated extends GuardState {
  final int visitorId;
  final String newStatus;
  const VisitorStatusUpdated(this.visitorId, this.newStatus);
  @override
  List<Object?> get props => [visitorId, newStatus];
}

class SecurityAlertsLoaded extends GuardState {
  final List<Map<String, dynamic>> alerts;
  const SecurityAlertsLoaded(this.alerts);
  @override
  List<Object?> get props => [alerts];
}

class SecurityAlertReported extends GuardState {
  final String alertId;
  const SecurityAlertReported(this.alertId);
  @override
  List<Object?> get props => [alertId];
}

class AlertStatusUpdated extends GuardState {
  final int alertId;
  final String newStatus;
  const AlertStatusUpdated(this.alertId, this.newStatus);
  @override
  List<Object?> get props => [alertId, newStatus];
}

class EmergencyContactsLoaded extends GuardState {
  final List<Map<String, dynamic>> contacts;
  const EmergencyContactsLoaded(this.contacts);
  @override
  List<Object?> get props => [contacts];
}

class GuardError extends GuardState {
  final String message;
  const GuardError(this.message);
  @override
  List<Object?> get props => [message];
}

class ResidentsLoaded extends GuardState {
  final List<Map<String, dynamic>> residents;
  const ResidentsLoaded(this.residents);
  @override
  List<Object?> get props => [residents];
}

class VehiclesLoaded extends GuardState {
  final List<Map<String, dynamic>> vehicles;
  const VehiclesLoaded(this.vehicles);
  @override
  List<Object?> get props => [vehicles];
}

class VehicleEntryAdded extends GuardState {
  final String entryId;
  const VehicleEntryAdded(this.entryId);
  @override
  List<Object?> get props => [entryId];
}

class VehicleEntryStatusUpdated extends GuardState {
  final int entryId;
  final String newStatus;
  const VehicleEntryStatusUpdated(this.entryId, this.newStatus);
  @override
  List<Object?> get props => [entryId, newStatus];
}

class AttendanceLoaded extends GuardState {
  final Map<String, dynamic>? todayRecord;
  final List<Map<String, dynamic>> history;
  const AttendanceLoaded({this.todayRecord, required this.history});
  @override
  List<Object?> get props => [todayRecord, history];
}

class AttendanceMarked extends GuardState {
  final String type;
  const AttendanceMarked(this.type);
  @override
  List<Object?> get props => [type];
}
