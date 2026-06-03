import 'package:equatable/equatable.dart';

class SecurityAlert extends Equatable {
  final String id;
  final String alertType; // suspicious_activity | unauthorized_access | emergency | other
  final String description;
  final String severity; // low | medium | high | critical
  final String status; // open | in_progress | resolved | closed
  final String reportedBy;
  final String? reportedByName;
  final String? resolvedBy;
  final String? resolvedByName;
  final String? resolvedAt;
  final String? imageUrl;
  final String? location;
  final String? societyId;
  final String? createdAt;
  final String? updatedAt;

  const SecurityAlert({
    required this.id,
    required this.alertType,
    required this.description,
    required this.severity,
    required this.status,
    required this.reportedBy,
    this.reportedByName,
    this.resolvedBy,
    this.resolvedByName,
    this.resolvedAt,
    this.imageUrl,
    this.location,
    this.societyId,
    this.createdAt,
    this.updatedAt,
  });

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'].toString(),
      alertType: json['alert_type'] ?? 'other',
      description: json['description'] ?? '',
      severity: json['severity'] ?? 'medium',
      status: json['status'] ?? 'open',
      reportedBy: json['reported_by']?.toString() ?? '',
      reportedByName: json['reported_by_name'],
      resolvedBy: json['resolved_by']?.toString(),
      resolvedByName: json['resolved_by_name'],
      resolvedAt: json['resolved_at'],
      imageUrl: json['image_url'],
      location: json['location'],
      societyId: json['society_id']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String get alertTypeLabel {
    switch (alertType) {
      case 'suspicious_activity': return 'Suspicious Activity';
      case 'unauthorized_access': return 'Unauthorized Access';
      case 'emergency': return 'Emergency';
      default: return 'Other';
    }
  }

  String get severityLabel {
    switch (severity) {
      case 'low': return 'Low';
      case 'high': return 'High';
      case 'critical': return 'Critical';
      default: return 'Medium';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      case 'closed': return 'Closed';
      default: return 'Open';
    }
  }

  @override
  List<Object?> get props => [id, alertType, description, severity, status, reportedBy, createdAt];
}
