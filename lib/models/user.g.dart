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
      appUserId: fields[13] as String?,
      coverImageUrl: fields[14] as String?,
      residentType: fields[15] as String?,
      bio: fields[16] as String?,
      profession: fields[17] as String?,
      hometown: fields[18] as String?,
      status: fields[19] as String?,
      googleId: fields[20] as String?,
      facebookId: fields[21] as String?,
      createdAt: fields[22] as String?,
      updatedAt: fields[23] as String?,
      vehicles: (fields[24] as List?)?.cast<ResidentVehicle>(),
      pets: (fields[25] as List?)?.cast<ResidentPet>(),
      flats: (fields[26] as List?)?.cast<ResidentFlat>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(27)
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
      ..write(obj.lastActive)
      ..writeByte(13)
      ..write(obj.appUserId)
      ..writeByte(14)
      ..write(obj.coverImageUrl)
      ..writeByte(15)
      ..write(obj.residentType)
      ..writeByte(16)
      ..write(obj.bio)
      ..writeByte(17)
      ..write(obj.profession)
      ..writeByte(18)
      ..write(obj.hometown)
      ..writeByte(19)
      ..write(obj.status)
      ..writeByte(20)
      ..write(obj.googleId)
      ..writeByte(21)
      ..write(obj.facebookId)
      ..writeByte(22)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.updatedAt)
      ..writeByte(24)
      ..write(obj.vehicles)
      ..writeByte(25)
      ..write(obj.pets)
      ..writeByte(26)
      ..write(obj.flats);
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
      phone: fields[4] as String?,
      isActive: fields[5] as bool,
      memberType: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyMember obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.relationship)
      ..writeByte(3)
      ..write(obj.profileImage)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.memberType);
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

class ResidentVehicleAdapter extends TypeAdapter<ResidentVehicle> {
  @override
  final int typeId = 2;

  @override
  ResidentVehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResidentVehicle(
      id: fields[0] as String,
      registrationNumber: fields[1] as String,
      typeName: fields[2] as String?,
      make: fields[3] as String?,
      model: fields[4] as String?,
      color: fields[5] as String?,
      parkingSpot: fields[6] as String?,
      vehicleTypeId: fields[7] as int,
      isElectric: fields[8] as int?,
      isParked: fields[9] as int?,
      imageUrl: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ResidentVehicle obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.registrationNumber)
      ..writeByte(2)
      ..write(obj.typeName)
      ..writeByte(3)
      ..write(obj.make)
      ..writeByte(4)
      ..write(obj.model)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.parkingSpot)
      ..writeByte(7)
      ..write(obj.vehicleTypeId)
      ..writeByte(8)
      ..write(obj.isElectric)
      ..writeByte(9)
      ..write(obj.isParked)
      ..writeByte(10)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResidentVehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResidentPetAdapter extends TypeAdapter<ResidentPet> {
  @override
  final int typeId = 3;

  @override
  ResidentPet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResidentPet(
      id: fields[0] as String,
      name: fields[1] as String,
      petTypeName: fields[2] as String?,
      breed: fields[3] as String?,
      age: fields[4] as int?,
      weight: fields[5] as double?,
      vaccinationStatus: fields[6] as String?,
      imageUrl: fields[7] as String?,
      notes: fields[8] as String?,
      petTypeId: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ResidentPet obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.petTypeName)
      ..writeByte(3)
      ..write(obj.breed)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.vaccinationStatus)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.petTypeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResidentPetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResidentFlatAdapter extends TypeAdapter<ResidentFlat> {
  @override
  final int typeId = 4;

  @override
  ResidentFlat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResidentFlat(
      id: fields[0] as String,
      flatNumber: fields[1] as String?,
      floorNumber: fields[2] as String?,
      areaSqft: fields[3] as double?,
      isOccupied: fields[4] as bool,
      buildingName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ResidentFlat obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.flatNumber)
      ..writeByte(2)
      ..write(obj.floorNumber)
      ..writeByte(3)
      ..write(obj.areaSqft)
      ..writeByte(4)
      ..write(obj.isOccupied)
      ..writeByte(5)
      ..write(obj.buildingName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResidentFlatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
