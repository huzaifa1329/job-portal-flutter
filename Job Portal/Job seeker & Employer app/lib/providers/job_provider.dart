import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/job_service.dart';
import '../modules/job_model.dart';

class JobProvider extends ChangeNotifier {
  final JobService _jobService = JobService();
  List<JobModel> _jobs = [];
  List<JobModel> _savedJobs = [];
  bool _isLoading = false;
  bool _isOffline = false;

  List<JobModel> get jobs => _jobs;
  List<JobModel> get savedJobs => _savedJobs;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  JobProvider() {
    _loadCachedJobs();
    _loadSavedJobs();
  }

  // Load cached jobs from local storage
  Future<void> _loadCachedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final jobsJson = prefs.getString('cached_jobs');
    if (jobsJson != null) {
      final List<dynamic> decoded = json.decode(jobsJson);
      _jobs = decoded.map((json) => JobModel.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Cache jobs locally
  Future<void> _cacheJobs(List<JobModel> jobs) async {
    final prefs = await SharedPreferences.getInstance();
    final jobsJson = json.encode(jobs.map((j) => j.toJson()).toList());
    await prefs.setString('cached_jobs', jobsJson);
  }

  // Load saved jobs from local storage
  Future<void> _loadSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('saved_jobs');
    if (savedJson != null) {
      final List<dynamic> decoded = json.decode(savedJson);
      _savedJobs = decoded.map((json) => JobModel.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Save job to local storage
  Future<void> _saveSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = json.encode(_savedJobs.map((j) => j.toJson()).toList());
    await prefs.setString('saved_jobs', savedJson);
  }

  Future<void> fetchJobs({bool forceRefresh = false}) async {
    if (!forceRefresh && _jobs.isNotEmpty && _isOffline) {
      return; // Use cached data when offline
    }

    _isLoading = true;
    notifyListeners();

    try {
      final jobs = await _jobService.getAllJobs();
      _jobs = jobs;
      await _cacheJobs(jobs);
      _isOffline = false;
    } catch (e) {
      _isOffline = true;
      print('Offline mode - using cached jobs');
    }

    _isLoading = false;
    notifyListeners();
  }

  void saveJob(JobModel job) {
    if (!_savedJobs.any((j) => j.id == job.id)) {
      _savedJobs.add(job);
      _saveSavedJobs();
      notifyListeners();
    }
  }

  void unsaveJob(String jobId) {
    _savedJobs.removeWhere((job) => job.id == jobId);
    _saveSavedJobs();
    notifyListeners();
  }

  bool isJobSaved(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }

  void setOfflineMode(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }
}