class JobSeekerModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String location;
  final String resume;
  final List<String> skills;
  final int experience;
  final String education;
  final DateTime createdAt;
  final bool isActive;

  JobSeekerModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.location,
    required this.resume,
    required this.skills,
    required this.experience,
    required this.education,
    required this.createdAt,
    required this.isActive,
  });

  factory JobSeekerModel.fromJson(Map<String, dynamic> json) {
    return JobSeekerModel(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      resume: json['resume'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      experience: json['experience'] ?? 0,
      education: json['education'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}