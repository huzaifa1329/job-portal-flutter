class JobApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String jobSeekerId;
  final String jobSeekerName;
  final String? resume;
  final String? coverLetter;
  final DateTime appliedDate;
  final String status;
  final String? feedback;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.jobSeekerId,
    required this.jobSeekerName,
    this.resume,
    this.coverLetter,
    required this.appliedDate,
    required this.status,
    this.feedback,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'].toString(),
      jobId: json['job_id'].toString(),
      jobTitle: json['job_title'] ?? '',
      jobSeekerId: json['job_seeker_id'].toString(),
      jobSeekerName: json['job_seeker_name'] ?? '',
      resume: json['resume'],
      coverLetter: json['cover_letter'],
      appliedDate: DateTime.parse(json['applied_date']),
      status: json['status'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job_title': jobTitle,
      'job_seeker_id': jobSeekerId,
      'job_seeker_name': jobSeekerName,
      'resume': resume,
      'cover_letter': coverLetter,
      'applied_date': appliedDate.toIso8601String(),
      'status': status,
      'feedback': feedback,
    };
  }
}