import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  TicketComment
// ─────────────────────────────────────────────────────────────────────────────
class TicketComment extends Equatable {
  final String id;
  final String ticketId;
  final String userId;
  final String? commenterName;
  final String comment;
  final String? createdAt;

  const TicketComment({
    required this.id,
    required this.ticketId,
    required this.userId,
    this.commenterName,
    required this.comment,
    this.createdAt,
  });

  factory TicketComment.fromJson(Map<String, dynamic> json) {
    return TicketComment(
      id: json['id'].toString(),
      ticketId: json['ticket_id'].toString(),
      userId: json['user_id'].toString(),
      commenterName: json['commenter_name'],
      comment: json['comment'] ?? '',
      createdAt: json['created_at'],
    );
  }

  @override
  List<Object?> get props => [id, ticketId, userId, comment, createdAt];
}

// ─────────────────────────────────────────────────────────────────────────────
//  Ticket
// ─────────────────────────────────────────────────────────────────────────────
class Ticket extends Equatable {
  final String id;
  final String ticketNumber;
  final String title;
  final String description;
  final String category; // general | maintenance | security | billing | other
  final String priority; // low | medium | high | urgent
  final String status; // open | in_progress | resolved | closed
  final String? residentId;
  final String? residentName;
  final String? assignedTo;
  final String? assignedToName;
  final String? flatNumber;
  final String? societyId;
  final String? resolvedAt;
  final List<TicketComment> comments;
  final String? createdAt;
  final String? updatedAt;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.residentId,
    this.residentName,
    this.assignedTo,
    this.assignedToName,
    this.flatNumber,
    this.societyId,
    this.resolvedAt,
    this.comments = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    List<TicketComment> parsedComments = [];
    if (json['comments'] != null) {
      parsedComments = (json['comments'] as List)
          .map((c) => TicketComment.fromJson(c))
          .toList();
    }

    return Ticket(
      id: json['id'].toString(),
      ticketNumber: json['ticket_number'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      residentId: json['resident_id']?.toString(),
      residentName: json['resident_name'],
      assignedTo: json['assigned_to']?.toString(),
      assignedToName: json['assigned_to_name'],
      flatNumber: json['flat_number'],
      societyId: json['society_id']?.toString(),
      resolvedAt: json['resolved_at'],
      comments: parsedComments,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      };

  String get statusLabel {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return 'Open';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      case 'low':
        return 'Low';
      default:
        return 'Medium';
    }
  }

  @override
  List<Object?> get props => [
        id, ticketNumber, title, category, priority, status,
        residentId, assignedTo, createdAt,
      ];
}
