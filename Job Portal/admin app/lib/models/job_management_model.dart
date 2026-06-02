class JobModel {
  final String id;
  final String employerId;
  final String companyName;
  final String title;
  final String description;
  final String requirements;
  final String location;
  final String jobType; // full-time, part-time, remote, contract
  final String salary;
  final List<String> skills;
  final DateTime postedDate;
  final DateTime deadline;
  final int vacancies;
  final String status; // pending, approved, rejected, closed
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
  return JobModel(
    id: json['id']?.toString() ?? '',
    employerId: json['employer_id']?.toString() ?? '',
    companyName: json['company_name'] ?? 'Unknown Company',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    requirements: json['requirements'] ?? '',
    location: json['location'] ?? '',
    jobType: json['job_type'] ?? '',
    salary: json['salary'] ?? '',
    skills: List<String>.from(json['skills'] ?? []),
    postedDate: json['posted_date'] != null
        ? DateTime.parse(json['posted_date'])
        : DateTime.now(),
    deadline: json['deadline'] != null
        ? DateTime.parse(json['deadline'])
        : DateTime.now(),
    vacancies: json['vacancies'] ?? 1,
    status: json['status'] ?? 'pending',
    views: json['views'] ?? 0,
    applications: json['applications'] ?? 0,
  );
}
}