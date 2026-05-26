import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// ─── Profile ──────────────────────────────────────────────
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

// ─── Family ───────────────────────────────────────────────
class AddFamilyMember extends ProfileEvent {
  final String name;
  final String relation;
  final String? phone;
  final String? imageUrl;

  const AddFamilyMember({
    required this.name,
    required this.relation,
    this.phone,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, relation, phone];
}

class DeleteFamilyMember extends ProfileEvent {
  final String memberId;
  const DeleteFamilyMember(this.memberId);

  @override
  List<Object?> get props => [memberId];
}

// ─── Vehicles ─────────────────────────────────────────────
class AddVehicle extends ProfileEvent {
  final String registrationNumber;
  final int vehicleTypeId;
  final String? make;
  final String? model;
  final String? color;
  final String? parkingSpot;
  final int? isElectric;
  final int? isParked;

  const AddVehicle({
    required this.registrationNumber,
    required this.vehicleTypeId,
    this.make,
    this.model,
    this.color,
    this.parkingSpot,
    this.isElectric,
    this.isParked,
  });

  @override
  List<Object?> get props => [registrationNumber, vehicleTypeId, isElectric, isParked];
}

class DeleteVehicle extends ProfileEvent {
  final String vehicleId;
  const DeleteVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

// ─── Pets ─────────────────────────────────────────────────
class AddPet extends ProfileEvent {
  final String name;
  final int petTypeId;
  final String? breed;
  final int? age;
  final double? weight;
  final String? vaccinationStatus;
  final String? notes;
  final String? imageUrl;

  const AddPet({
    required this.name,
    required this.petTypeId,
    this.breed,
    this.age,
    this.weight,
    this.vaccinationStatus,
    this.notes,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, petTypeId];
}

class DeletePet extends ProfileEvent {
  final String petId;
  const DeletePet(this.petId);

  @override
  List<Object?> get props => [petId];
}

// ─── Daily Help ───────────────────────────────────────────
class AddDailyHelper extends ProfileEvent {
  final String name;
  final String phone;
  final String serviceType;
  final String? visitTime;

  const AddDailyHelper({
    required this.name,
    required this.phone,
    required this.serviceType,
    this.visitTime,
  });

  @override
  List<Object?> get props => [name, phone, serviceType];
}

class DeleteDailyHelper extends ProfileEvent {
  final int helperId;
  const DeleteDailyHelper(this.helperId);

  @override
  List<Object?> get props => [helperId];
}
