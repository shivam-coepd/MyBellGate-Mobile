import 'package:equatable/equatable.dart';

class Visitor extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String purpose;
  final String visitDate;
  final String? visitTime;
  final String? expectedExitTime;
  final String? actualExitTime;
  final String status; // pending | approved | rejected | entered | exited
  final String visitorType; // guest | delivery | service | other
  final String? residentId;
  final String? residentName;
  final String? guardId;
  final String? guardName;
  final String? societyId;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  const Visitor({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.purpose,
    required this.visitDate,
    this.visitTime,
    this.expectedExitTime,
    this.actualExitTime,
    required this.status,
    required this.visitorType,
    this.residentId,
    this.residentName,
    this.guardId,
    this.guardName,
    this.societyId,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      purpose: json['purpose'] ?? '',
      visitDate: json['visit_date'] ?? '',
      visitTime: json['visit_time'],
      expectedExitTime: json['expected_exit_time'],
      actualExitTime: json['actual_exit_time'],
      status: json['status'] ?? 'pending',
      visitorType: json['visitor_type'] ?? 'guest',
      residentId: json['resident_id']?.toString(),
      residentName: json['resident_name'],
      guardId: json['guard_id']?.toString(),
      guardName: json['guard_name'],
      societyId: json['society_id']?.toString(),
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        'purpose': purpose,
        'visit_date': visitDate,
        if (visitTime != null) 'visit_time': visitTime,
        if (expectedExitTime != null) 'expected_exit_time': expectedExitTime,
        'visitor_type': visitorType,
        if (residentId != null) 'resident_id': residentId,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  /// Human-friendly status label
  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'entered':
        return 'Inside';
      case 'exited':
        return 'Exited';
      default:
        return 'Pending';
    }
  }

  /// Human-friendly visitor type label
  String get visitorTypeLabel {
    switch (visitorType) {
      case 'delivery':
        return 'Delivery';
      case 'service':
        return 'Service';
      case 'other':
        return 'Other';
      default:
        return 'Guest';
    }
  }

  @override
  List<Object?> get props => [
        id, name, phone, email, purpose, visitDate, visitTime,
        expectedExitTime, actualExitTime, status, visitorType,
        residentId, guardId, societyId, imageUrl, createdAt,
      ];
}
