class NotificationModel {
  final String id;
  final String userId;
  final String userType;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.userType,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      userType: json['user_type'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}