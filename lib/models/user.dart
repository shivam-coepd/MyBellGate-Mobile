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
  });

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