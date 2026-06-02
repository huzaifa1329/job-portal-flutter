class JobModel {
  final String id;
  final String employerId;
  final String companyName;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String jobType;
  final String salary;
  final List<String> skills;
  final DateTime postedDate;
  final DateTime deadline;
  final int vacancies;
  final String status;
  final int views;
  final int applications;

  JobModel({
    required this.id,
    required this.employerId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.requirements,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.skills,
    required this.postedDate,
    required this.deadline,
    required this.vacancies,
    required this.status,
    required this.views,
    required this.applications,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Safe date parser - returns a fallback date if null/invalid
    DateTime safeParseDate(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return fallback ?? DateTime.now();
      }
    }

    return JobModel(
      id: (json['id'] ?? '').toString(),
      employerId: (json['employer_id'] ?? '').toString(),
      companyName: (json['company_name'] ?? '').toString().trim().isEmpty
          ? 'Unknown Company'
          : (json['company_name'] ?? 'Unknown Company').toString(),
      title: (json['title'] ?? 'Untitled').toString(),
      description: (json['description'] ?? '').toString(),
      requirements: (json['requirements'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      jobType: (json['job_type'] ?? 'Full Time').toString(),
      salary: (json['salary'] ?? 'Not specified').toString(),
      skills: List<String>.from(json['skills'] ?? []),
      postedDate: safeParseDate(json['posted_date']),
      deadline: safeParseDate(
        json['deadline'],
        fallback: DateTime.now().add(const Duration(days: 30)),
      ),
      vacancies: (json['vacancies'] as num?)?.toInt() ?? 1,
      status: (json['status'] ?? 'pending').toString(),
      views: (json['views'] as num?)?.toInt() ?? 0,
      applications: (json['applications'] as num?)?.toInt() ?? 0,
    );
  }

  // Add this toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employer_id': employerId,
      'company_name': companyName,
      'title': title,
      'description': description,
      'requirements': requirements,
      'location': location,
      'job_type': jobType,
      'salary': salary,
      'skills': skills,
      'posted_date': postedDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'vacancies': vacancies,
      'status': status,
      'views': views,
      'applications': applications,
    };
  }
}