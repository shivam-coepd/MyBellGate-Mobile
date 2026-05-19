// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      unit: fields[4] as String?,
      societyId: fields[5] as String?,
      role: fields[6] as String,
      profileImage: fields[7] as String?,
      biometricEnabled: fields[8] as bool?,
      familyMembers: (fields[9] as List?)?.cast<FamilyMember>(),
      isApproved: fields[10] as bool?,
      points: fields[11] as int?,
      lastActive: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.societyId)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.profileImage)
      ..writeByte(8)
      ..write(obj.biometricEnabled)
      ..writeByte(9)
      ..write(obj.familyMembers)
      ..writeByte(10)
      ..write(obj.isApproved)
      ..writeByte(11)
      ..write(obj.points)
      ..writeByte(12)
      ..write(obj.lastActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FamilyMemberAdapter extends TypeAdapter<FamilyMember> {
  @override
  final int typeId = 1;

  @override
  FamilyMember read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyMember(
      id: fields[0] as String,
      name: fields[1] as String,
      relationship: fields[2] as String,
      profileImage: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyMember obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.profileImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyMemberAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
