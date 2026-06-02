import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../modules/job_application_model.dart';
// Removed unused import: import '../../modules/user_model.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final AuthService _authService = AuthService();
  List<JobApplicationModel> _applications = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      final applications =
          await _applicationService.getApplicationsByJobSeeker(user.id);
      if (mounted) {
        setState(() {
          _applications = applications;
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<JobApplicationModel> get _filteredApplications {
    if (_filterStatus == 'All') return _applications;
    return _applications
        .where((app) => app.status == _filterStatus.toLowerCase())
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shortlisted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
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
                  _buildFilterChip('Shortlisted'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hired'),
                ],
              ),
            ),
          ),

          // Applications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApplications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No applications found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Apply for jobs to see them here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredApplications.length,
                        itemBuilder: (context, index) {
                          final application = _filteredApplications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          application.jobTitle,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                                  application.status)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          application.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _getStatusColor(
                                                application.status),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Applied on: ${_formatDate(application.appliedDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (application.feedback != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Feedback:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            application.feedback!,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
        setState(() {
          _filterStatus = label;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}