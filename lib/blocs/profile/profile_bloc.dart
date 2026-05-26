import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/repositories/household_repository.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;
  final HouseholdRepository householdRepository;

  ProfileBloc({
    required this.userRepository,
    required this.householdRepository,
  }) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileInfo>(_onUpdateProfileInfo);
    on<AddFamilyMember>(_onAddFamilyMember);
    on<DeleteFamilyMember>(_onDeleteFamilyMember);
    on<AddVehicle>(_onAddVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<AddPet>(_onAddPet);
    on<DeletePet>(_onDeletePet);
    on<AddDailyHelper>(_onAddDailyHelper);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Profile
  // ─────────────────────────────────────────────────────────────────

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getProfile();
      if (user != null) {
        emit(ProfileLoaded(user: user));
      } else {
        emit(const ProfileError(message: 'Failed to retrieve profile data'));
      }
    } catch (e) {
      log('FetchProfile error: $e');
      emit(ProfileError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfileInfo(
    UpdateProfileInfo event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      final user = await userRepository.updateProfile(
        name: event.name,
        email: event.email,
        profileImage: event.profileImage,
        coverImageUrl: event.coverImageUrl,
        residentType: event.residentType,
        bio: event.bio,
        profession: event.profession,
        hometown: event.hometown,
      );
      if (user != null) {
        emit(ProfileUpdateSuccess(user: user));
        emit(ProfileLoaded(user: user));
      } else {
        emit(const ProfileError(message: 'Failed to update profile data'));
      }
    } catch (e) {
      log('UpdateProfileInfo error: $e');
      emit(ProfileError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Family
  // ─────────────────────────────────────────────────────────────────

  Future<void> _onAddFamilyMember(
    AddFamilyMember event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.addFamilyMember(
        name: event.name,
        relation: event.relation,
        phone: event.phone,
        imageUrl: event.imageUrl,
      );
      // Refresh full profile so state reflects the new member
      final refreshed = await userRepository.getProfile();
      if (refreshed != null) {
        emit(HouseholdUpdateSuccess(
          user: refreshed,
          message: '${event.name} added to family',
        ));
        emit(ProfileLoaded(user: refreshed));
      } else {
        emit(HouseholdError(message: 'Added, but failed to refresh profile', user: currentUser));
        if (currentUser != null) emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('AddFamilyMember error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  Future<void> _onDeleteFamilyMember(
    DeleteFamilyMember event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.deleteFamilyMember(event.memberId);
      final refreshed = await userRepository.getProfile();
      if (refreshed != null) {
        emit(HouseholdUpdateSuccess(user: refreshed, message: 'Family member removed'));
        emit(ProfileLoaded(user: refreshed));
      } else {
        emit(HouseholdError(message: 'Removed, but failed to refresh', user: currentUser));
        if (currentUser != null) emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('DeleteFamilyMember error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Vehicles
  // ─────────────────────────────────────────────────────────────────

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.addVehicle(
        registrationNumber: event.registrationNumber,
        vehicleTypeId: event.vehicleTypeId,
        make: event.make,
        model: event.model,
        color: event.color,
        parkingSpot: event.parkingSpot,
        isElectric: event.isElectric,
        isParked: event.isParked,
      );
      final refreshed = await userRepository.getProfile();
      if (refreshed != null) {
        emit(HouseholdUpdateSuccess(
          user: refreshed,
          message: '${event.registrationNumber} added successfully',
        ));
        emit(ProfileLoaded(user: refreshed));
      } else {
        emit(HouseholdError(message: 'Added, but failed to refresh', user: currentUser));
        if (currentUser != null) emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('AddVehicle error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.deleteVehicle(event.vehicleId);
      final refreshed = await userRepository.getProfile();
      if (refreshed != null) {
        emit(HouseholdUpdateSuccess(user: refreshed, message: 'Vehicle removed'));
        emit(ProfileLoaded(user: refreshed));
      } else {
        emit(HouseholdError(message: 'Removed, but failed to refresh', user: currentUser));
        if (currentUser != null) emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('DeleteVehicle error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Pets
  // ─────────────────────────────────────────────────────────────────

  Future<void> _onAddPet(
    AddPet event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.addPet(
        name: event.name,
        petTypeId: event.petTypeId,
        breed: event.breed,
        age: event.age,
        weight: event.weight,
        vaccinationStatus: event.vaccinationStatus,
        notes: event.notes,
        imageUrl: event.imageUrl,
      );
      final refreshed = await userRepository.getProfile();
      if (refreshed != null) {
        emit(HouseholdUpdateSuccess(
          user: refreshed,
          message: '${event.name} added to pets',
        ));
        emit(ProfileLoaded(user: refreshed));
      } else {
        emit(HouseholdError(message: 'Added, but failed to refresh', user: currentUser));
        if (currentUser != null) emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('AddPet error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  Future<void> _onDeletePet(
    DeletePet event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.deletePet(event.petId);
      final refreshed = await userRepository.getProfile();
      if (refreshed != null) {
        emit(HouseholdUpdateSuccess(user: refreshed, message: 'Pet removed'));
        emit(ProfileLoaded(user: refreshed));
      } else {
        emit(HouseholdError(message: 'Removed, but failed to refresh', user: currentUser));
        if (currentUser != null) emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('DeletePet error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Daily Help
  // ─────────────────────────────────────────────────────────────────

  Future<void> _onAddDailyHelper(
    AddDailyHelper event,
    Emitter<ProfileState> emit,
  ) async {
    final currentUser = _getCurrentUser();
    emit(HouseholdUpdating());
    try {
      await householdRepository.addDailyHelper(
        name: event.name,
        phone: event.phone,
        serviceType: event.serviceType,
        visitTime: event.visitTime,
      );
      // Daily helpers don't appear in the profile endpoint, so just restore state
      if (currentUser != null) {
        emit(HouseholdUpdateSuccess(
          user: currentUser,
          message: '${event.name} added as daily helper',
        ));
        emit(ProfileLoaded(user: currentUser));
      }
    } catch (e) {
      log('AddDailyHelper error: $e');
      emit(HouseholdError(
        message: e.toString().replaceFirst('Exception: ', ''),
        user: currentUser,
      ));
      if (currentUser != null) emit(ProfileLoaded(user: currentUser));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────

  /// Returns the user from the last ProfileLoaded state if available,
  /// falling back to Hive local cache.
  dynamic _getCurrentUser() {
    final s = state;
    if (s is ProfileLoaded) return s.user;
    return userRepository.getCurrentUser();
  }
}
