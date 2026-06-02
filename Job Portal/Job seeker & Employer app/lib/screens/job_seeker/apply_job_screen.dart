import 'package:flutter/material.dart';

import '../../modules/job_model.dart';
import '../../modules/user_model.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ApplyJobScreen extends StatefulWidget {
  final JobModel job;
  const ApplyJobScreen({super.key, required this.job});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final ApplicationService _applicationService = ApplicationService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _coverLetterController = TextEditingController();

  // Keep resume upload as a simple text/path for now to avoid file_picker dependency.
  String? _resumeName;
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _resumeName = null;
    _loadUser();
  }

  Future<void> _loadUser() async {
    _currentUser = await _authService.getCurrentUser();
    if (mounted) setState(() {});
  }

  void _mockPickResume() {
    setState(() {
      _resumeName = 'resume.pdf';
    });
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_resumeName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your resume'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _applicationService.applyForJob(
      jobId: widget.job.id,
      jobSeekerId: _currentUser!.id,
      jobSeekerName: _currentUser!.fullName,
      coverLetter: _coverLetterController.text,
      resume: _resumeName!,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.job.title}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Job Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Position: ${widget.job.title}'),
                      const SizedBox(height: 4),
                      Text('Company: ${widget.job.companyName}'),
                      const SizedBox(height: 4),
                      Text('Location: ${widget.job.location}'),
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
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Name: ${_currentUser?.fullName ?? ''}'),
                      const SizedBox(height: 4),
                      Text('Email: ${_currentUser?.email ?? ''}'),
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
                        'Application Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Resume/CV (Mock)',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _mockPickResume,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _resumeName == null
                                    ? Icons.upload_file
                                    : Icons.check_circle,
                                color: _resumeName == null
                                    ? Colors.grey
                                    : Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _resumeName ?? 'Tap to upload resume (PDF)',
                                  style: TextStyle(
                                    color: _resumeName == null
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _coverLetterController,
                        label: 'Cover Letter (Optional)',
                        hint:
                            "Tell us why you're a good fit for this position...",
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Submit Application',
                onPressed: _submitApplication,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}