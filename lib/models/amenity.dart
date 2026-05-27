import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Amenity
// ─────────────────────────────────────────────────────────────────────────────
class Amenity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int capacity;
  final double bookingFee;
  final double cancellationFee;
  final String? cancellationPolicy;
  final String? societyId;
  final bool isActive;
  final String? createdAt;

  const Amenity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.capacity = 1,
    this.bookingFee = 0,
    this.cancellationFee = 0,
    this.cancellationPolicy,
    this.societyId,
    this.isActive = true,
    this.createdAt,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      capacity: int.tryParse(json['capacity']?.toString() ?? '1') ?? 1,
      bookingFee:
          double.tryParse(json['booking_fee']?.toString() ?? '0') ?? 0,
      cancellationFee:
          double.tryParse(json['cancellation_fee']?.toString() ?? '0') ?? 0,
      cancellationPolicy: json['cancellation_policy'],
      societyId: json['society_id']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'],
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, imageUrl, capacity, bookingFee,
        cancellationFee, societyId, isActive,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  AmenityBooking
// ─────────────────────────────────────────────────────────────────────────────
class AmenityBooking extends Equatable {
  final String id;
  final String amenityId;
  final String? amenityName;
  final String? amenityImageUrl;
  final String? residentId;
  final String? residentName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status; // requested | confirmed | cancelled | completed
  final double totalAmount;
  final String? createdAt;

  const AmenityBooking({
    required this.id,
    required this.amenityId,
    this.amenityName,
    this.amenityImageUrl,
    this.residentId,
    this.residentName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.totalAmount = 0,
    this.createdAt,
  });

  factory AmenityBooking.fromJson(Map<String, dynamic> json) {
    return AmenityBooking(
      id: json['id'].toString(),
      amenityId: json['amenity_id'].toString(),
      amenityName: json['amenity_name'],
      amenityImageUrl: json['image_url'],
      residentId: json['resident_id']?.toString(),
      residentName: json['resident_name'],
      bookingDate: json['booking_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? 'requested',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toBookingJson() => {
        'booking_date': bookingDate,
        'start_time': startTime,
        'end_time': endTime,
      };

  String get statusLabel {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Requested';
    }
  }

  @override
  List<Object?> get props =>
      [id, amenityId, bookingDate, startTime, endTime, status, totalAmount];
}
