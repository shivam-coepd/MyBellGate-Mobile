import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfileInfo extends ProfileEvent {
  final String? name;
  final String? email;
  final String? profileImage;
  final String? coverImageUrl;
  final String? residentType;
  final String? bio;
  final String? profession;
  final String? hometown;

  const UpdateProfileInfo({
    this.name,
    this.email,
    this.profileImage,
    this.coverImageUrl,
    this.residentType,
    this.bio,
    this.profession,
    this.hometown,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        profileImage,
        coverImageUrl,
        residentType,
        bio,
        profession,
        hometown,
      ];
}
