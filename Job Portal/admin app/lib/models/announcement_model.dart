class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String target;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.target,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      target: json['target'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'target': target,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}