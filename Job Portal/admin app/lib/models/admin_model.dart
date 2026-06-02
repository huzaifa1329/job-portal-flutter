class AdminModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final DateTime createdAt;
  final DateTime lastLogin;

  AdminModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    required this.lastLogin,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'] ?? 'admin',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
  }
}