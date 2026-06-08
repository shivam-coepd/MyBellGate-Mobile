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
  List<Object?> get props => [name, relation, phone, imageUrl];
}

class UpdateFamilyMember extends ProfileEvent {
  final String id;
  final String? name;
  final String? relation;
  final String? phone;
  final String? imageUrl;

  const UpdateFamilyMember({
    required this.id,
    this.name,
    this.relation,
    this.phone,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, relation, phone, imageUrl];
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
  List<Object?> get props => [registrationNumber, vehicleTypeId, make, model, color, parkingSpot, isElectric, isParked];
}

class UpdateVehicle extends ProfileEvent {
  final String id;
  final int? vehicleTypeId;
  final String? make;
  final String? model;
  final String? color;
  final String? parkingSpot;
  final int? isElectric;
  final int? isParked;

  const UpdateVehicle({
    required this.id,
    this.vehicleTypeId,
    this.make,
    this.model,
    this.color,
    this.parkingSpot,
    this.isElectric,
    this.isParked,
  });

  @override
  List<Object?> get props => [id, vehicleTypeId, make, model, color, parkingSpot, isElectric, isParked];
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
  List<Object?> get props => [name, petTypeId, breed, age, weight, vaccinationStatus, notes, imageUrl];
}

class UpdatePet extends ProfileEvent {
  final String id;
  final int? petTypeId;
  final String? name;
  final String? breed;
  final int? age;
  final double? weight;
  final String? vaccinationStatus;
  final String? notes;
  final String? imageUrl;

  const UpdatePet({
    required this.id,
    this.petTypeId,
    this.name,
    this.breed,
    this.age,
    this.weight,
    this.vaccinationStatus,
    this.notes,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, petTypeId, name, breed, age, weight, vaccinationStatus, notes, imageUrl];
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
  List<Object?> get props => [name, phone, serviceType, visitTime];
}

class UpdateDailyHelper extends ProfileEvent {
  final int id;
  final String? name;
  final String? phone;
  final String? serviceType;
  final String? visitTime;

  const UpdateDailyHelper({
    required this.id,
    this.name,
    this.phone,
    this.serviceType,
    this.visitTime,
  });

  @override
  List<Object?> get props => [id, name, phone, serviceType, visitTime];
}

class DeleteDailyHelper extends ProfileEvent {
  final int helperId;
  const DeleteDailyHelper(this.helperId);

  @override
  List<Object?> get props => [helperId];
}
