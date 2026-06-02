import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_seeker_management_model.dart';
import '../models/employer_management_model.dart';
import '../models/job_management_model.dart';
import '../models/application_management_model.dart';
import '../models/announcement_model.dart';
import '../models/admin_dashboard_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Dashboard Stats
  Future<DashboardStats> getDashboardStats() async {
    final usersResponse = await _supabase.from('job_seekers').select('id');
    final employersResponse = await _supabase.from('employers').select('id');
    final jobsResponse = await _supabase.from('jobs').select('id');
    final applicationsResponse = await _supabase.from('applications').select('id');
    
    final pendingJobsResponse = await _supabase
        .from('jobs')
        .select('id')
        .eq('status', 'pending');

    return DashboardStats(
      totalUsers: usersResponse.length,
      totalEmployers: employersResponse.length,
      totalJobs: jobsResponse.length,
      totalApplications: applicationsResponse.length,
      pendingJobs: pendingJobsResponse.length,
      recentActivities: 0,
    );
  }

  // Get monthly statistics for charts
  Future<List<Map<String, dynamic>>> getMonthlyStats() async {
    final response = await _supabase
        .rpc('get_monthly_stats');
    
    return response;
  }

  // Job Seekers Management
  Future<List<JobSeekerModel>> getAllJobSeekers() async {
    final response = await _supabase
        .from('job_seekers')
        .select()
        .order('created_at', ascending: false);
    
    return response.map((json) => JobSeekerModel.fromJson(json)).toList();
  }

  Future<void> updateJobSeekerStatus(String userId, bool isActive) async {
    await _supabase
        .from('job_seekers')
        .update({'is_active': isActive})
        .eq('id', userId);
  }

  Future<void> deleteJobSeeker(String userId) async {
    await _supabase.from('job_seekers').delete().eq('id', userId);
  }

  // Employers Management
  Future<List<EmployerModel>> getAllEmployers() async {
    final response = await _supabase
        .from('employers')
        .select()
        .order('created_at', ascending: false);
    
    return response.map((json) => EmployerModel.fromJson(json)).toList();
  }

  Future<void> verifyEmployer(String employerId, bool isVerified) async {
    await _supabase
        .from('employers')
        .update({'is_verified': isVerified})
        .eq('id', employerId);
  }

  Future<void> updateEmployerStatus(String employerId, bool isActive) async {
    await _supabase
        .from('employers')
        .update({'is_active': isActive})
        .eq('id', employerId);
  }

  // Jobs Management
 Future<List<JobModel>> getAllJobs({String? status}) async {
  var query = _supabase
      .from('jobs')
      .select()
      .order('posted_date', ascending: false);

  final response = await query;

  var results = response;

  if (status != null) {
    results = response.where((job) => job['status'] == status).toList();
  }

  return results
      .map<JobModel>((json) => JobModel.fromJson(json))
      .toList();
}

  Future<void> updateJobStatus(String jobId, String status) async {
    await _supabase
        .from('jobs')
        .update({'status': status})
        .eq('id', jobId);
  }

  Future<void> deleteJob(String jobId) async {
    await _supabase.from('jobs').delete().eq('id', jobId);
  }

  // Applications Management
  Future<List<ApplicationModel>> getAllApplications({String? status}) async {
    var query = _supabase
        .from('applications')
        .select('*, jobs(title), job_seekers(full_name)')
        .order('applied_date', ascending: false);
    
    final response = await query;
    
    // Filter after fetching if status is provided
    var results = response;
    if (status != null) {
      results = response.where((app) => app['status'] == status).toList();
    }
    
    return results.map((json) {
      json['job_title'] = json['jobs']['title'];
      json['job_seeker_name'] = json['job_seekers']['full_name'];
      return ApplicationModel.fromJson(json);
    }).toList();
  }

  Future<void> updateApplicationStatus(String applicationId, String status, {String? feedback}) async {
    final updates = {'status': status};
    if (feedback != null) {
      updates['feedback'] = feedback;
    }
    
    await _supabase
        .from('applications')
        .update(updates)
        .eq('id', applicationId);
  }

  // Announcements Management
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    final response = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    
    return response.map((json) => AnnouncementModel.fromJson(json)).toList();
  }

  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    await _supabase.from('announcements').insert({
      'title': announcement.title,
      'content': announcement.content,
      'target': announcement.target,
      'created_at': announcement.createdAt.toIso8601String(),
      'expires_at': announcement.expiresAt?.toIso8601String(),
      'is_active': announcement.isActive,
    });
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> updates) async {
    await _supabase.from('announcements').update(updates).eq('id', id);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _supabase.from('announcements').delete().eq('id', id);
  }
  // Add this method for approving jobs
Future<void> approveJob(String jobId) async {
  await _supabase
      .from('jobs')
      .update({'status': 'approved'})
      .eq('id', jobId);
}
// Add this method for rejecting jobs
Future<void> rejectJob(String jobId, {String? reason}) async {
  await _supabase
      .from('jobs')
      .update({'status': 'rejected'})
      .eq('id', jobId);
}
}