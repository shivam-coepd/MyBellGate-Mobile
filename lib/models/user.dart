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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<FamilyMember>? parsedFamilyMembers;
    String? parsedUnit;

    if (json['resident_data'] != null) {
      final resData = json['resident_data'] as Map<String, dynamic>;

      if (resData['family_members'] != null) {
        final List<dynamic> fmList = resData['family_members'];
        parsedFamilyMembers = fmList.map((fm) => FamilyMember(
          id: fm['id'].toString(),
          name: fm['name'] ?? '',
          relationship: fm['relation'] ?? '',
          profileImage: fm['image_url'],
        )).toList();
      }

      if (resData['flats'] != null && (resData['flats'] as List).isNotEmpty) {
        final flat = (resData['flats'] as List).first;
        parsedUnit = '${flat['building_name'] ?? ''} - ${flat['flat_number'] ?? ''}';
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
      ];
}

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

  const FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    this.profileImage,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        relationship,
        profileImage,
      ];
}