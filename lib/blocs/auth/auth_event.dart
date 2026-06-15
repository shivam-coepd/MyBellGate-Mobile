import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String phone;
  final String password;
  final String? role;

  const LoginRequested({
    required this.phone, 
    required this.password,
    this.role,
  });

  @override
  List<Object?> get props => [phone, password, role];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String societyId;
  final String unit;
  final String role;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.phone,
    required this.email,
    required this.societyId,
    required this.unit,
    required this.role,
    required this.password,
  });

  @override
  List<Object?> get props => [name, phone, email, societyId, unit, role, password];
}

class OtpRequested extends AuthEvent {
  final String phone;

  const OtpRequested({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class LogoutRequested extends AuthEvent {}

class RoleSelected extends AuthEvent {
  final String role;

  const RoleSelected({required this.role});

  @override
  List<Object?> get props => [role];
}

class OnboardingCompleted extends AuthEvent {}