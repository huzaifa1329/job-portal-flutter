class CompanyModel {
  final String id;
  final String employerId;
  final String companyName;
  final String? companyLogo;
  final String? companyDescription;
  final String? companyWebsite;
  final String? companyLocation;
  final String? companyEmail;
  final String? companyPhone;
  final int? companySize;
  final String? industry;
  final String? foundedYear;
  final List<String>? socialLinks;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  CompanyModel({
    required this.id,
    required this.employerId,
    required this.companyName,
    this.companyLogo,
    this.companyDescription,
    this.companyWebsite,
    this.companyLocation,
    this.companyEmail,
    this.companyPhone,
    this.companySize,
    this.industry,
    this.foundedYear,
    this.socialLinks,
    required this.createdAt,
    this.updatedAt,
    required this.isVerified,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'].toString(),
      employerId: json['employer_id'].toString(),
      companyName: json['company_name'],
      companyLogo: json['company_logo'],
      companyDescription: json['company_description'],
      companyWebsite: json['company_website'],
      companyLocation: json['company_location'],
      companyEmail: json['company_email'],
      companyPhone: json['company_phone'],
      companySize: json['company_size'],
      industry: json['industry'],
      foundedYear: json['founded_year'],
      socialLinks: json['social_links'] != null 
          ? List<String>.from(json['social_links']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employer_id': employerId,
      'company_name': companyName,
      'company_logo': companyLogo,
      'company_description': companyDescription,
      'company_website': companyWebsite,
      'company_location': companyLocation,
      'company_email': companyEmail,
      'company_phone': companyPhone,
      'company_size': companySize,
      'industry': industry,
      'founded_year': foundedYear,
      'social_links': socialLinks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  // Helper method to get company size as string
  String getCompanySizeString() {
    if (companySize == null) return 'Not specified';
    if (companySize! < 10) return '1-10 employees';
    if (companySize! < 50) return '11-50 employees';
    if (companySize! < 200) return '51-200 employees';
    if (companySize! < 500) return '201-500 employees';
    if (companySize! < 1000) return '501-1000 employees';
    return '1000+ employees';
  }

  // Helper method to get company age
  String getCompanyAge() {
    if (foundedYear == null) return 'Not specified';
    final currentYear = DateTime.now().year;
    final founded = int.tryParse(foundedYear!);
    if (founded == null) return 'Not specified';
    final age = currentYear - founded;
    return '$age years old';
  }
}