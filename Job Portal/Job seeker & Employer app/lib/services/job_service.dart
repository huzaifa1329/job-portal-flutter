import 'package:supabase_flutter/supabase_flutter.dart';
import '../modules/job_model.dart';

class JobService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<JobModel>> getAllJobs({
  String? searchQuery,
  String? jobType,
  String? location,
}) async {
  try {
    final response = await _supabase
        .from('jobs')
        .select()
        .eq('status', 'approved')
        .order('posted_date', ascending: false);

    var results = response;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((job) =>
          (job['title'] ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (job['description'] ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (job['company_name'] ?? '')
              .toLowerCase()
              .contains(searchQuery.toLowerCase())).toList();
    }

    if (jobType != null &&
        jobType.isNotEmpty &&
        jobType != 'All') {
      results = results
          .where((job) => job['job_type'] == jobType)
          .toList();
    }

    if (location != null &&
        location.isNotEmpty &&
        location != 'All') {
      results = results.where((job) =>
          (job['location'] ?? '')
              .toLowerCase()
              .contains(location.toLowerCase())).toList();
    }

    return results
        .map<JobModel>((json) => JobModel.fromJson(json))
        .toList();
  } catch (e) {
    print('Get jobs error: $e');
    return [];
  }
}

  Future<JobModel?> getJobById(String jobId) async {
  try {
    final response = await _supabase
        .from('jobs')
        .select()
        .eq('id', jobId)
        .single();

    await _supabase
        .from('jobs')
        .update({'views': (response['views'] ?? 0) + 1})
        .eq('id', jobId);

    return JobModel.fromJson(response);
  } catch (e) {
    print('Get job by id error: $e');
    return null;
  }
}

  Future<List<JobModel>> getJobsByEmployer(String employerId) async {
  try {
    final response = await _supabase
        .from('jobs')
        .select()
        .eq('employer_id', employerId)
        .order('posted_date', ascending: false);

    return response
        .map<JobModel>((json) => JobModel.fromJson(json))
        .toList();
  } catch (e) {
    print('Get employer jobs error: $e');
    return [];
  }
}

  Future<bool> postJob(Map<String, dynamic> jobData) async {
    try {
      await _supabase.from('jobs').insert(jobData);
      return true;
    } catch (e) {
      print('Post job error: $e');
      return false;
    }
  }

  Future<bool> updateJob(String jobId, Map<String, dynamic> updates) async {
    try {
      await _supabase.from('jobs').update(updates).eq('id', jobId);
      return true;
    } catch (e) {
      print('Update job error: $e');
      return false;
    }
  }

  Future<bool> deleteJob(String jobId) async {
    try {
      await _supabase.from('jobs').delete().eq('id', jobId);
      return true;
    } catch (e) {
      print('Delete job error: $e');
      return false;
    }
  }
}