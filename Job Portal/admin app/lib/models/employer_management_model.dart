class EmployerModel {
  final String id;
  final String email;
  final String companyName;
  final String companyLogo;
  final String companyDescription;
  final String companyWebsite;
  final String companyLocation;
  final String contactPerson;
  final String contactPhone;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;

  EmployerModel({
    required this.id,
    required this.email,
    required this.companyName,
    required this.companyLogo,
    required this.companyDescription,
    required this.companyWebsite,
    required this.companyLocation,
    required this.contactPerson,
    required this.contactPhone,
    required this.createdAt,
    required this.isVerified,
    required this.isActive,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    return EmployerModel(
      id: json['id'].toString(),
      email: json['email'],
      companyName: json['company_name'],
      companyLogo: json['company_logo'] ?? '',
      companyDescription: json['company_description'] ?? '',
      companyWebsite: json['company_website'] ?? '',
      companyLocation: json['company_location'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
    );
  }
}