class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // job_seeker or employer
  final String? phone;
  final String? location;
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.location,
    required this.createdAt,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      phone: json['phone'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}