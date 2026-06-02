class SavedJobModel {
  final String id;
  final String jobId;
  final String jobSeekerId;
  final String jobTitle;
  final String companyName;
  final DateTime savedAt;

  SavedJobModel({
    required this.id,
    required this.jobId,
    required this.jobSeekerId,
    required this.jobTitle,
    required this.companyName,
    required this.savedAt,
  });

  factory SavedJobModel.fromJson(Map<String, dynamic> json) {
    return SavedJobModel(
      id: json['id'].toString(),
      jobId: json['job_id'].toString(),
      jobSeekerId: json['job_seeker_id'].toString(),
      jobTitle: json['job_title'],
      companyName: json['company_name'],
      savedAt: DateTime.parse(json['saved_at']),
    );
  }
}