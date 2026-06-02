import 'package:flutter/material.dart';

import '../../modules/job_model.dart';
import '../../modules/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/job_service.dart';
import '../../widgets/custom_button.dart';
import 'post_job_screen.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();

  List<JobModel> _jobs = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);

    _currentUser = await _authService.getCurrentUser();
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    final jobs = await _jobService.getJobsByEmployer(_currentUser!.id);
    setState(() {
      _jobs = jobs;
      _isLoading = false;
    });
  }

  List<JobModel> get _filteredJobs {
    if (_filterStatus == 'All') return _jobs;
    return _jobs
        .where((job) => job.status == _filterStatus.toLowerCase())
        .toList();
  }

  Future<void> _deleteJob(JobModel job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job'),
        content: Text('Are you sure you want to delete "${job.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _jobService.deleteJob(job.id);
    if (!success || !mounted) return;

    await _loadJobs();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Jobs'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobs,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostJobScreen()),
          ).then((_) => _loadJobs());
        },
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approved'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Closed'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.work_off,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomButton(
                              text: 'Post a Job',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PostJobScreen(),
                                  ),
                                ).then((_) => _loadJobs());
                              },
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getStatusColor(job.status).withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.work,
                                  color: _getStatusColor(job.status),
                                ),
                              ),
                              title: Text(
                                job.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('📍 ${job.location}'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(job.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      job.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _getStatusColor(job.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteJob(job),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('Job Type', job.jobType),
                                      const SizedBox(height: 8),
                                      _buildInfoRow('Salary', job.salary),
                                      const SizedBox(height: 8),
                                      _buildInfoRow('Vacancies', job.vacancies.toString()),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                          'Applications', job.applications.toString()),
                                      const SizedBox(height: 8),
                                      _buildInfoRow('Views', job.views.toString()),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        'Posted',
                                        _formatDate(job.postedDate),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        'Deadline',
                                        _formatDate(job.deadline),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(job.description),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Requirements',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(job.requirements),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Skills Required',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: job.skills
                                            .map((skill) => Chip(
                                                  label: Text(skill),
                                                  backgroundColor: Colors.blue.shade50,
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _filterStatus == label,
      onSelected: (selected) {
        if (!selected) {
          setState(() => _filterStatus = 'All');
          return;
        }
        setState(() => _filterStatus = label);
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

