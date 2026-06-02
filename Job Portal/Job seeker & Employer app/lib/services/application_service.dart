import 'package:supabase_flutter/supabase_flutter.dart';
import '../modules/job_application_model.dart';

class ApplicationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<bool> applyForJob({
    required String jobId,
    required String jobSeekerId,
    required String jobSeekerName,
    required String coverLetter,
    required String resume,
  }) async {
    try {
      final existingApplication = await _supabase
          .from('applications')
          .select('id')
          .eq('job_id', jobId)
          .eq('job_seeker_id', jobSeekerId)
          .maybeSingle();

      if (existingApplication != null) {
        return false;
      }

      final job = await _supabase
          .from('jobs')
          .select('title, applications')
          .eq('id', jobId)
          .single();

      await _supabase.from('applications').insert({
        'job_id': jobId,
        'job_seeker_id': jobSeekerId,
        'job_seeker_name': jobSeekerName,
        'job_title': job['title'],
        'cover_letter': coverLetter,
        'resume': resume,
        'applied_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      final currentCount = (job['applications'] as num?)?.toInt() ?? 0;
      await _supabase
          .from('jobs')
          .update({'applications': currentCount + 1}).eq('id', jobId);

      return true;
    } catch (e) {
      print('Apply for job error: $e');
      return false;
    }
  }

  Future<List<JobApplicationModel>> getApplicationsByJobSeeker(
      String jobSeekerId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select(
              'id, job_id, job_seeker_id, job_title, job_seeker_name, resume, cover_letter, applied_date, status, feedback')
          .eq('job_seeker_id', jobSeekerId)
          .order('applied_date', ascending: false);

      return response
          .map<JobApplicationModel>(
              (json) => JobApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get applications by job seeker error: $e');
      return [];
    }
  }

  Future<List<JobApplicationModel>> getApplicationsByJob(String jobId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select(
              'id, job_id, job_seeker_id, job_title, job_seeker_name, resume, cover_letter, applied_date, status, feedback')
          .eq('job_id', jobId)
          .order('applied_date', ascending: false);

      return response
          .map<JobApplicationModel>(
              (json) => JobApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get applications by job error: $e');
      return [];
    }
  }

  Future<List<JobApplicationModel>> getApplicationsByEmployer(
      String employerId) async {
    try {
      final jobs = await _supabase
          .from('jobs')
          .select('id')
          .eq('employer_id', employerId);

      final jobIds = jobs.map((job) => job['id'].toString()).toList();

      if (jobIds.isEmpty) return [];

      final response = await _supabase
          .from('applications')
          .select(
              'id, job_id, job_seeker_id, job_title, job_seeker_name, resume, cover_letter, applied_date, status, feedback')
          .inFilter('job_id', jobIds)
          .order('applied_date', ascending: false);

      return response
          .map<JobApplicationModel>(
              (json) => JobApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get applications by employer error: $e');
      return [];
    }
  }

  Future<bool> updateApplicationStatus(String applicationId, String status,
      {String? feedback}) async {
    try {
      final updates = {'status': status};
      if (feedback != null) {
        updates['feedback'] = feedback;
      }

      await _supabase
          .from('applications')
          .update(updates)
          .eq('id', applicationId);

      return true;
    } catch (e) {
      print('Update application status error: $e');
      return false;
    }
  }

  Future<bool> hasApplied(String jobId, String jobSeekerId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('id')
          .eq('job_id', jobId)
          .eq('job_seeker_id', jobSeekerId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}