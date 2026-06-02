import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../modules/job_model.dart';
import '../../modules/user_model.dart';
import '../../widgets/custom_button.dart';
import 'apply_job_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final AuthService _authService = AuthService();
  bool _hasApplied = false;
  bool _isLoading = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      _hasApplied = await _applicationService.hasApplied(
        widget.job.id,
        _currentUser!.id,
      );
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          widget.job.companyName.isNotEmpty ? widget.job.companyName[0].toUpperCase() : "?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.job.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.job.companyName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_on, 'Location', widget.job.location),
                    _buildDetailRow(Icons.work, 'Job Type', widget.job.jobType),
                    _buildDetailRow(Icons.attach_money, 'Salary', widget.job.salary),
                    _buildDetailRow(Icons.timer, 'Posted', 
                        DateFormat('MMM dd, yyyy').format(widget.job.postedDate)),
                    _buildDetailRow(Icons.event, 'Deadline',
                        DateFormat('MMM dd, yyyy').format(widget.job.deadline)),
                    _buildDetailRow(Icons.people, 'Vacancies', widget.job.vacancies.toString()),
                    _buildDetailRow(Icons.visibility, 'Views', widget.job.views.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.job.description, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Requirements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.job.requirements, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Skills Required',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.job.skills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Colors.blue.shade50,
                          labelStyle: TextStyle(color: Colors.blue.shade700),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isLoading && _currentUser != null)
              _buildApplyButton(),
            if (_currentUser == null && !_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please login to apply for this job',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login Now'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    if (_hasApplied) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You have already applied for this position',
                style: TextStyle(color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      );
    }
    
    return CustomButton(
      text: 'Apply Now',
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplyJobScreen(job: widget.job),
          ),
        );
        if (result == true) {
          _checkApplicationStatus();
        }
      },
      color: Colors.blue.shade700,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}