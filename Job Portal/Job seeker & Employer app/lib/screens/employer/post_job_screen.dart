import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/constants.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _vacanciesController = TextEditingController();
  final _skillsController = TextEditingController();
  
  String _selectedJobType = 'Full Time';
  DateTime? _deadline;
  final List<String> _skillsList = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Job'),
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
              // Basic Information
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
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _titleController,
                        label: 'Job Title',
                        prefixIcon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Job Description',
                        hint: 'Describe the role, responsibilities, etc.',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _requirementsController,
                        label: 'Requirements',
                        hint: 'List the requirements for this position',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter requirements';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Job Details
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
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _locationController,
                        label: 'Location',
                        prefixIcon: Icons.location_on,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedJobType,
                        decoration: InputDecoration(
                          labelText: 'Job Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: AppConstants.jobTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedJobType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _salaryController,
                        label: 'Salary Range',
                        prefixIcon: Icons.attach_money,
                        hint: 'e.g., \$50,000 - \$70,000',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter salary range';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _vacanciesController,
                        label: 'Number of Vacancies',
                        prefixIcon: Icons.people,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of vacancies';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Skills
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _skillsController,
                              label: 'Add Skill',
                              hint: 'e.g., Flutter, Dart, Firebase',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_skillsController.text.isNotEmpty) {
                                setState(() {
                                  _skillsList.add(_skillsController.text);
                                  _skillsController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      if (_skillsList.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skillsList.map((skill) {
                            return Chip(
                              label: Text(skill),
                              onDeleted: () {
                                setState(() {
                                  _skillsList.remove(skill);
                                });
                              },
                              backgroundColor: Colors.blue.shade50,
                              deleteIcon: const Icon(Icons.close, size: 16),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Deadline
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
                        'Application Deadline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          _deadline == null
                              ? 'No deadline selected'
                              : DateFormat('MMM dd, yyyy').format(_deadline!),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _deadline = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              CustomButton(
                text: 'Post Job',
                onPressed: _submitJob,
                isLoading: _isLoading,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      if (_deadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an application deadline'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (_skillsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one skill'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      setState(() => _isLoading = true);
      
      final currentUser = await _authService.getCurrentUser();
      
      final jobData = {
        'employer_id': currentUser!.id,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'requirements': _requirementsController.text,
        'location': _locationController.text,
        'job_type': _selectedJobType,
        'salary': _salaryController.text,
        'skills': _skillsList,
        'vacancies': int.parse(_vacanciesController.text),
        'deadline': _deadline!.toIso8601String(),
        'posted_date': DateTime.now().toIso8601String(),
        'status': 'pending', // Needs admin approval
        'views': 0,
        'applications': 0,
      };
      
      final success = await _jobService.postJob(jobData);
      
      setState(() => _isLoading = false);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully! Waiting for admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post job. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _vacanciesController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
}