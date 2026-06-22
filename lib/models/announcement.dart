import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Announcement
// ─────────────────────────────────────────────────────────────────────────────
class Announcement extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? societyId;
  final String? createdBy;
  final String? createdByName;
  final String? targetGroupId;
  final String? targetGroupName;
  final String sendVia; // app | sms | email | whatsapp
  final String? scheduledAt;
  final bool isDraft;
  final String? createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.societyId,
    this.createdBy,
    this.createdByName,
    this.targetGroupId,
    this.targetGroupName,
    this.sendVia = 'app',
    this.scheduledAt,
    this.isDraft = false,
    this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      societyId: json['society_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdByName: json['created_by_name'],
      targetGroupId: json['target_group_id']?.toString(),
      targetGroupName: json['target_group_name'],
      sendVia: json['send_via'] ?? 'app',
      scheduledAt: json['scheduled_at'],
      isDraft: json['is_draft'] == 1 || json['is_draft'] == true,
      createdAt: json['created_at'],
    );
  }

  @override
  List<Object?> get props => [
        id, title, content, createdBy, targetGroupId, isDraft, createdAt
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  PollOption
// ─────────────────────────────────────────────────────────────────────────────
class PollOption extends Equatable {
  final String id;
  final String pollId;
  final String optionText;
  final int voteCount;

  const PollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    this.voteCount = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'].toString(),
      pollId: json['poll_id'].toString(),
      optionText: json['option_text'] ?? '',
      voteCount:
          int.tryParse(json['vote_count']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, pollId, optionText, voteCount];
}

// ─────────────────────────────────────────────────────────────────────────────
//  Poll
// ─────────────────────────────────────────────────────────────────────────────
class Poll extends Equatable {
  final String id;
  final String question;
  final String pollType; // public | secret
  final String? societyId;
  final String? createdBy;
  final String? createdByName;
  final String? createdByProfileImage;
  final String? startsAt;
  final String endsAt;
  final bool isActive;
  final bool hasVoted;
  final List<PollOption> options;
  final String? createdAt;

  const Poll({
    required this.id,
    required this.question,
    this.pollType = 'public',
    this.societyId,
    this.createdBy,
    this.createdByName,
    this.createdByProfileImage,
    this.startsAt,
    required this.endsAt,
    this.isActive = true,
    this.hasVoted = false,
    this.options = const [],
    this.createdAt,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    List<PollOption> parsedOptions = [];
    if (json['options'] != null) {
      parsedOptions = (json['options'] as List)
          .map((o) => PollOption.fromJson(o))
          .toList();
    }

    return Poll(
      id: json['id'].toString(),
      question: json['question'] ?? '',
      pollType: json['poll_type'] ?? 'public',
      societyId: json['society_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdByName: json['created_by_name'],
      createdByProfileImage: json['created_by_profile_image'],
      startsAt: json['starts_at'],
      endsAt: json['ends_at'] ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      hasVoted: json['has_voted'] == true,
      options: parsedOptions,
      createdAt: json['created_at'],
    );
  }

  int get totalVotes =>
      options.fold(0, (sum, opt) => sum + opt.voteCount);

  @override
  List<Object?> get props =>
      [id, question, pollType, endsAt, isActive, hasVoted, createdAt];
}
