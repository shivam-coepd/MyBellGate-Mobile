import 'package:equatable/equatable.dart';
import 'package:mygate_coepd/models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class OnboardingState extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSent extends AuthState {
  final String phone;

  const OtpSent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class RoleSelectedState extends AuthState {
  final String role;

  const RoleSelectedState({required this.role});

  @override
  List<Object?> get props => [role];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}