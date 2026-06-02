import 'company_model.dart';

class EmployerModel {
  final String id;
  final String email;
  final String companyName;
  final String? companyLogo;
  final String? companyDescription;
  final String? companyWebsite;
  final String? companyLocation;
  final String contactPerson;
  final String? contactPhone;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;
  CompanyModel? companyDetails; // Optional company details

  EmployerModel({
    required this.id,
    required this.email,
    required this.companyName,
    this.companyLogo,
    this.companyDescription,
    this.companyWebsite,
    this.companyLocation,
    required this.contactPerson,
    this.contactPhone,
    required this.createdAt,
    required this.isVerified,
    required this.isActive,
    this.companyDetails,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    return EmployerModel(
      id: json['id'].toString(),
      email: json['email'],
      companyName: json['company_name'],
      companyLogo: json['company_logo'],
      companyDescription: json['company_description'],
      companyWebsite: json['company_website'],
      companyLocation: json['company_location'],
      contactPerson: json['contact_person'],
      contactPhone: json['contact_phone'],
      createdAt: DateTime.parse(json['created_at']),
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      companyDetails: json['company_details'] != null 
          ? CompanyModel.fromJson(json['company_details']) 
          : null,
    );
  }
}