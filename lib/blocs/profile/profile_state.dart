import 'package:equatable/equatable.dart';
import 'package:mygate_coepd/models/user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;

  const ProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final User user;

  const ProfileUpdateSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Emitted while a household mutation (add/delete) is in progress.
class HouseholdUpdating extends ProfileState {}

/// Emitted after a successful household mutation so the UI can refresh.
class HouseholdUpdateSuccess extends ProfileState {
  final User user;
  final String message;

  const HouseholdUpdateSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// A transient error emitted during a household mutation that should not
/// replace the full screen — the UI should show a SnackBar instead.
class HouseholdError extends ProfileState {
  final String message;
  final User? user; // keep the previously loaded user so the screen stays stable

  const HouseholdError({required this.message, this.user});

  @override
  List<Object?> get props => [message];
}
