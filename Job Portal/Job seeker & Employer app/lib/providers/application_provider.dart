import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/application_service.dart';
import '../modules/job_application_model.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationService _applicationService = ApplicationService();
  List<JobApplicationModel> _applications = [];
  bool _isLoading = false;

  List<JobApplicationModel> get applications => _applications;
  bool get isLoading => _isLoading;

  ApplicationProvider() {
    _loadCachedApplications();
  }

  Future<void> _loadCachedApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final appsJson = prefs.getString('my_applications');
    if (appsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(appsJson);
        _applications = decoded.map((json) => JobApplicationModel.fromJson(json)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading cached applications: $e');
      }
    }
  }

  Future<void> _cacheApplications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appsJson = json.encode(_applications.map((a) => a.toJson()).toList());
      await prefs.setString('my_applications', appsJson);
    } catch (e) {
      print('Error caching applications: $e');
    }
  }

  Future<void> fetchApplications(String jobSeekerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final applications = await _applicationService.getApplicationsByJobSeeker(jobSeekerId);
      _applications = applications;
      await _cacheApplications();
    } catch (e) {
      print('Error fetching applications: $e');
      // Keep existing cached data when offline
    }

    _isLoading = false;
    notifyListeners();
  }

  // Simplified apply method without JobModel
  Future<bool> applyForJob({
    required String jobId,
    required String jobTitle,
    required String jobSeekerId,
    required String jobSeekerName,
    required String coverLetter,
    required String resume,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _applicationService.applyForJob(
        jobId: jobId,
        jobSeekerId: jobSeekerId,
        jobSeekerName: jobSeekerName,
        coverLetter: coverLetter,
        resume: resume,
      );

      if (success) {
        // Add to local applications
        final newApplication = JobApplicationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          jobId: jobId,
          jobTitle: jobTitle,
          jobSeekerId: jobSeekerId,
          jobSeekerName: jobSeekerName,
          resume: resume,
          coverLetter: coverLetter,
          appliedDate: DateTime.now(),
          status: 'pending',
          feedback: null,
        );
        _applications.insert(0, newApplication);
        await _cacheApplications();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Error applying for job: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}