import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/config/app_config.dart';
import 'package:mygate_coepd/blocs/auth/auth_event.dart';
import 'package:mygate_coepd/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<OtpRequested>(_onOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RoleSelected>(_onRoleSelected);
    on<OnboardingCompleted>(_onOnboardingCompleted);
    on<UserUpdated>((event, emit) {
      emit(Authenticated(user: event.user));
    });
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // Initialize user repository
    await userRepository.init();

    // Check if onboarding is complete
    if (!AppConfig.isOnboardingComplete) {
      emit(OnboardingState());
      return;
    }

    // Check if user is already logged in
    final user = userRepository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.login(
        event.phone, 
        event.password,
        role: event.role,
      );
      log("User Login Response: $user");
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(AuthError('Login failed'));
      }
    } catch (e) {
      log("User Login Exception: $e");
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await userRepository.register(
        name: event.name,
        phone: event.phone,
        email: event.email,
        societyId: event.societyId,
        unit: event.unit,
        role: event.role,
        password: event.password,
      );
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onOtpRequested(OtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Simulate OTP sending (in a real app, this would call an API)
      await Future.delayed(const Duration(seconds: 1));
      emit(OtpSent(phone: event.phone));
    } catch (e) {
      emit(AuthError('Failed to send OTP: $e'));
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await userRepository.logout();
    // Clear selected role if remember device is disabled
    if (!AppConfig.rememberDevice) {
      AppConfig.setSelectedRole(null);
    }
    emit(Unauthenticated());
  }

  void _onRoleSelected(RoleSelected event, Emitter<AuthState> emit) {
    AppConfig.setSelectedRole(event.role);
    emit(RoleSelectedState(role: event.role));
  }

  void _onOnboardingCompleted(
    OnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    await AppConfig.setOnboardingComplete(true);
    emit(Unauthenticated());
  }
}
