class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobSeekerId;
  final String jobSeekerName;
  final String resume;
  final String coverLetter;
  final DateTime appliedDate;
  final String status; // pending, shortlisted, rejected, hired
  final String? feedback;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobSeekerId,
    required this.jobSeekerName,
    required this.resume,
    required this.coverLetter,
    required this.appliedDate,
    required this.status,
    this.feedback,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'].toString(),
      jobId: json['job_id'].toString(),
      jobTitle: json['job_title'],
      jobSeekerId: json['job_seeker_id'].toString(),
      jobSeekerName: json['job_seeker_name'],
      resume: json['resume'],
      coverLetter: json['cover_letter'] ?? '',
      appliedDate: DateTime.parse(json['applied_date']),
      status: json['status'],
      feedback: json['feedback'],
    );
  }
}