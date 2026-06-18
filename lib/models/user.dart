import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String? unit;

  @HiveField(5)
  final String? societyId;

  @HiveField(6)
  final String role;

  @HiveField(7)
  final String? profileImage;

  @HiveField(8)
  final bool? biometricEnabled;

  @HiveField(9)
  final List<FamilyMember>? familyMembers;

  @HiveField(10)
  final bool? isApproved;

  @HiveField(11)
  final int? points;

  @HiveField(12)
  final String? lastActive;

  @HiveField(13)
  final String? appUserId;

  @HiveField(14)
  final String? coverImageUrl;

  @HiveField(15)
  final String? residentType;

  @HiveField(16)
  final String? bio;

  @HiveField(17)
  final String? profession;

  @HiveField(18)
  final String? hometown;

  @HiveField(19)
  final String? status;

  @HiveField(20)
  final String? googleId;

  @HiveField(21)
  final String? facebookId;

  @HiveField(22)
  final String? createdAt;

  @HiveField(23)
  final String? updatedAt;

  // ── Household ──────────────────────────────────────
  @HiveField(24)
  final List<ResidentVehicle>? vehicles;

  @HiveField(25)
  final List<ResidentPet>? pets;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.unit,
    this.societyId,
    required this.role,
    this.profileImage,
    this.biometricEnabled,
    this.familyMembers,
    this.isApproved,
    this.points,
    this.lastActive,
    this.appUserId,
    this.coverImageUrl,
    this.residentType,
    this.bio,
    this.profession,
    this.hometown,
    this.status,
    this.googleId,
    this.facebookId,
    this.createdAt,
    this.updatedAt,
    this.vehicles,
    this.pets,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<FamilyMember>? parsedFamilyMembers;
    List<ResidentVehicle>? parsedVehicles;
    List<ResidentPet>? parsedPets;
    String? parsedUnit;

    if (json['resident_data'] != null) {
      final resData = json['resident_data'] as Map<String, dynamic>;

      // Family Members
      if (resData['family_members'] != null) {
        final List<dynamic> fmList = resData['family_members'];
        parsedFamilyMembers = fmList.map((fm) => FamilyMember(
          id: fm['id'].toString(),
          name: fm['name'] ?? '',
          relationship: fm['relation'] ?? '',
          phone: fm['phone'],
          profileImage: fm['image_url'],
          isActive: fm['is_active'] == 1 || fm['is_active'] == true,
          memberType: fm['member_type'] ?? 'Adult',
        )).toList();
      }

      // Flats → derive unit display string
      if (resData['flats'] != null && (resData['flats'] as List).isNotEmpty) {
        final flat = (resData['flats'] as List).first;
        parsedUnit = '${flat['building_name'] ?? ''} - ${flat['flat_number'] ?? ''}';
      }

      // Vehicles
      if (resData['vehicles'] != null) {
        final List<dynamic> vList = resData['vehicles'];
        parsedVehicles = vList.map((v) => ResidentVehicle.fromJson(v)).toList();
      }

      // Pets
      if (resData['pets'] != null) {
        final List<dynamic> pList = resData['pets'];
        parsedPets = pList.map((p) => ResidentPet.fromJson(p)).toList();
      }
    }

    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      unit: parsedUnit ?? json['resident_type'],
      societyId: json['society_id']?.toString(),
      role: json['role'] ?? 'resident',
      profileImage: json['profile_image'],
      biometricEnabled: false,
      familyMembers: parsedFamilyMembers,
      isApproved: json['status'] == 'active',
      points: 0,
      lastActive: json['updated_at'],
      appUserId: json['app_user_id']?.toString(),
      coverImageUrl: json['cover_image_url'],
      residentType: json['resident_type'],
      bio: json['bio'],
      profession: json['profession'],
      hometown: json['hometown'],
      status: json['status'],
      googleId: json['google_id'],
      facebookId: json['facebook_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      vehicles: parsedVehicles,
      pets: parsedPets,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? unit,
    String? societyId,
    String? role,
    String? profileImage,
    bool? biometricEnabled,
    List<FamilyMember>? familyMembers,
    bool? isApproved,
    int? points,
    String? lastActive,
    String? appUserId,
    String? coverImageUrl,
    String? residentType,
    String? bio,
    String? profession,
    String? hometown,
    String? status,
    String? googleId,
    String? facebookId,
    String? createdAt,
    String? updatedAt,
    List<ResidentVehicle>? vehicles,
    List<ResidentPet>? pets,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      unit: unit ?? this.unit,
      societyId: societyId ?? this.societyId,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      familyMembers: familyMembers ?? this.familyMembers,
      isApproved: isApproved ?? this.isApproved,
      points: points ?? this.points,
      lastActive: lastActive ?? this.lastActive,
      appUserId: appUserId ?? this.appUserId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      residentType: residentType ?? this.residentType,
      bio: bio ?? this.bio,
      profession: profession ?? this.profession,
      hometown: hometown ?? this.hometown,
      status: status ?? this.status,
      googleId: googleId ?? this.googleId,
      facebookId: facebookId ?? this.facebookId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicles: vehicles ?? this.vehicles,
      pets: pets ?? this.pets,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        unit,
        societyId,
        role,
        profileImage,
        biometricEnabled,
        familyMembers,
        isApproved,
        points,
        lastActive,
        appUserId,
        coverImageUrl,
        residentType,
        bio,
        profession,
        hometown,
        status,
        googleId,
        facebookId,
        createdAt,
        updatedAt,
        vehicles,
        pets,
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
//  FamilyMember
// ═══════════════════════════════════════════════════════════════════════════
@HiveType(typeId: 1)
class FamilyMember extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String relationship;

  @HiveField(3)
  final String? profileImage;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final String? memberType;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    this.profileImage,
    this.phone,
    this.isActive = true,
    this.memberType,
  });

  @override
  List<Object?> get props => [id, name, relationship, profileImage, phone, isActive, memberType];
}

// ═══════════════════════════════════════════════════════════════════════════
//  ResidentVehicle
// ═══════════════════════════════════════════════════════════════════════════
@HiveType(typeId: 2)
class ResidentVehicle extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String registrationNumber;

  @HiveField(2)
  final String? typeName;

  @HiveField(3)
  final String? make;

  @HiveField(4)
  final String? model;

  @HiveField(5)
  final String? color;

  @HiveField(6)
  final String? parkingSpot;

  @HiveField(7)
  final int vehicleTypeId;

  @HiveField(8)
  final int? isElectric;

  @HiveField(9)
  final int? isParked;

  @HiveField(10)
  final String? imageUrl;

  const ResidentVehicle({
    required this.id,
    required this.registrationNumber,
    this.typeName,
    this.make,
    this.model,
    this.color,
    this.parkingSpot,
    this.vehicleTypeId = 0,
    this.isElectric,
    this.isParked,
    this.imageUrl,
  });

  factory ResidentVehicle.fromJson(Map<String, dynamic> json) {
    return ResidentVehicle(
      id: json['id'].toString(),
      registrationNumber: json['registration_number'] ?? '',
      typeName: json['type_name'],
      make: json['make'],
      model: json['model'],
      color: json['color'],
      parkingSpot: json['parking_spot'],
      vehicleTypeId: int.tryParse(json['vehicle_type_id']?.toString() ?? '0') ?? 0,
      isElectric: json['is_electric'] != null ? int.tryParse(json['is_electric'].toString()) : null,
      isParked: json['is_parked'] != null ? int.tryParse(json['is_parked'].toString()) : null,
      imageUrl: json['image_url'],
    );
  }

  /// Display-friendly label e.g. "MH12AB1234 · Car"
  String get label {
    final parts = <String>[registrationNumber];
    if (typeName != null && typeName!.isNotEmpty) parts.add(typeName!);
    return parts.join(' · ');
  }

  @override
  List<Object?> get props => [id, registrationNumber, typeName, make, model, color, parkingSpot, isElectric];
}

// ═══════════════════════════════════════════════════════════════════════════
//  ResidentPet
// ═══════════════════════════════════════════════════════════════════════════
@HiveType(typeId: 3)
class ResidentPet extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? petTypeName;

  @HiveField(3)
  final String? breed;

  @HiveField(4)
  final int? age;

  @HiveField(5)
  final double? weight;

  @HiveField(6)
  final String? vaccinationStatus;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final int petTypeId;

  const ResidentPet({
    required this.id,
    required this.name,
    this.petTypeName,
    this.breed,
    this.age,
    this.weight,
    this.vaccinationStatus,
    this.imageUrl,
    this.notes,
    this.petTypeId = 0,
  });

  factory ResidentPet.fromJson(Map<String, dynamic> json) {
    return ResidentPet(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      petTypeName: json['pet_type_name'],
      breed: json['breed'],
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      weight: json['weight'] != null ? double.tryParse(json['weight'].toString()) : null,
      vaccinationStatus: json['vaccination_status'],
      imageUrl: json['image_url'],
      notes: json['notes'],
      petTypeId: int.tryParse(json['pet_type_id']?.toString() ?? '0') ?? 0,
    );
  }

  /// Display-friendly label e.g. "Bruno · Dog"
  String get label {
    final parts = <String>[name];
    if (petTypeName != null && petTypeName!.isNotEmpty) parts.add(petTypeName!);
    if (breed != null && breed!.isNotEmpty) parts.add(breed!);
    return parts.join(' · ');
  }

  @override
  List<Object?> get props => [id, name, petTypeName, breed, age, vaccinationStatus];
}