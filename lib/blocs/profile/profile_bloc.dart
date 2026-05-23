import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mygate_coepd/repositories/user_repository.dart';
import 'package:mygate_coepd/blocs/profile/profile_event.dart';
import 'package:mygate_coepd/blocs/profile/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfileInfo>(_onUpdateProfileInfo);
  }

  void _onFetchProfile(FetchProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final user = await userRepository.getProfile();
      if (user != null) {
        emit(ProfileLoaded(user: user));
      } else {
        emit(const ProfileError(message: 'Failed to retrieve profile data'));
      }
    } catch (e) {
      log("Fetch Profile Exception: $e");
      emit(ProfileError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onUpdateProfileInfo(UpdateProfileInfo event, Emitter<ProfileState> emit) async {
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
        // Emit loaded state after update success so UI stays in Loaded state
        emit(ProfileLoaded(user: user));
      } else {
        emit(const ProfileError(message: 'Failed to update profile data'));
      }
    } catch (e) {
      log("Update Profile Exception: $e");
      emit(ProfileError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
