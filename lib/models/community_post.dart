class CommunityPost {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String? unit;
  final String content;
  final String? image;
  final int likesCount;
  final int commentsCount;
  final bool hasLiked;
  final String time;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.unit,
    required this.content,
    this.image,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.hasLiked = false,
    required this.time,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Unknown User',
      userAvatar: json['avatar_url'],
      unit: json['unit'],
      content: json['content'] ?? '',
      image: json['image'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      hasLiked: json['has_liked'] ?? false,
      time: json['created_at'] ?? '',
    );
  }
}
