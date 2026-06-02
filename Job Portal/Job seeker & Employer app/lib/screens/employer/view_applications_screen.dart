import 'package:flutter/material.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../modules/job_application_model.dart';
import '../../modules/user_model.dart';
import '../../widgets/custom_button.dart';

class ViewApplicationsScreen extends StatefulWidget {
  const ViewApplicationsScreen({super.key});

  @override
  State<ViewApplicationsScreen> createState() => _ViewApplicationsScreenState();
}

class _ViewApplicationsScreenState extends State<ViewApplicationsScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final AuthService _authService = AuthService();
  List<JobApplicationModel> _applications = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      final applications = await _applicationService
          .getApplicationsByEmployer(_currentUser!.id);
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

  Future<void> _updateStatus(
      JobApplicationModel application, String newStatus) async {
    String? feedback;
    
    if (newStatus == 'rejected') {
      final controller = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rejection Feedback'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter reason for rejection',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                feedback = controller.text;
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }
    
    final success = await _applicationService.updateApplicationStatus(
      application.id,
      newStatus,
      feedback: feedback,
    );
    
    if (success && mounted) {
      _loadApplications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
        title: const Text('Job Applications'),
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
                              'No applications received',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
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
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              application.jobTitle,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Applicant: ${application.jobSeekerName}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
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
                                            color:
                                                _getStatusColor(application.status),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Applied on: ${_formatDate(application.appliedDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (application.coverLetter != null &&
                                      application.coverLetter!.isNotEmpty) ...[
                                    const Text(
                                      'Cover Letter:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      application.coverLetter!,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (application.feedback != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
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
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  // Action Buttons
                                  if (application.status == 'pending')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomButton(
                                            text: 'Shortlist',
                                            onPressed: () => _updateStatus(
                                                application, 'shortlisted'),
                                            color: Colors.blue,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: CustomButton(
                                            text: 'Reject',
                                            onPressed: () => _updateStatus(
                                                application, 'rejected'),
                                            color: Colors.red,
                                            isOutlined: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (application.status == 'shortlisted')
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomButton(
                                            text: 'Hire',
                                            onPressed: () => _updateStatus(
                                                application, 'hired'),
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: CustomButton(
                                            text: 'Reject',
                                            onPressed: () => _updateStatus(
                                                application, 'rejected'),
                                            color: Colors.red,
                                            isOutlined: true,
                                          ),
                                        ),
                                      ],
                                    ),
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}