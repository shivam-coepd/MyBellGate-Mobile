import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String contactType; // police | fire | ambulance | hospital | other
  final bool isActive;
  final String? societyId;
  final String? createdAt;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.contactType,
    this.isActive = true,
    this.societyId,
    this.createdAt,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      contactType: json['contact_type'] ?? 'other',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      societyId: json['society_id']?.toString(),
      createdAt: json['created_at'],
    );
  }

  String get contactTypeLabel {
    switch (contactType) {
      case 'police': return 'Police';
      case 'fire': return 'Fire Brigade';
      case 'ambulance': return 'Ambulance';
      case 'hospital': return 'Hospital';
      default: return 'Other';
    }
  }

  @override
  List<Object?> get props => [id, name, phone, contactType];
}
