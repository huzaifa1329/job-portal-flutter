// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/application_management_model.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<ApplicationModel> _applications = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    final applications = await _databaseService.getAllApplications();
    setState(() {
      _applications = applications;
      _isLoading = false;
    });
  }

  Future<void> _updateApplicationStatus(ApplicationModel application, String newStatus) async {
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
    
    await _databaseService.updateApplicationStatus(application.id, newStatus, feedback: feedback);
    _loadApplications();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application status updated to $newStatus'),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<ApplicationModel> get _filteredApplications {
    if (_filterStatus == 'All') return _applications;
    return _applications.where((app) => app.status == _filterStatus.toLowerCase()).toList();
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
        title: const Text('Manage Applications'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(application.status).withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.person,
                                  color: _getStatusColor(application.status),
                                ),
                              ),
                              title: Text(
                                application.jobSeekerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Applied for: ${application.jobTitle}'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(application.status).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      application.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getStatusColor(application.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) => _updateApplicationStatus(application, value),
                                itemBuilder: (context) => [
                                  if (application.status == 'pending')
                                    const PopupMenuItem(
                                      value: 'shortlisted',
                                      child: Text('Shortlist'),
                                    ),
                                  if (application.status == 'pending' || application.status == 'shortlisted')
                                    const PopupMenuItem(
                                      value: 'rejected',
                                      child: Text('Reject'),
                                    ),
                                  if (application.status == 'shortlisted')
                                    const PopupMenuItem(
                                      value: 'hired',
                                      child: Text('Hire'),
                                    ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Cover Letter',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(application.coverLetter.isEmpty 
                                          ? 'No cover letter provided' 
                                          : application.coverLetter),
                                      if (application.feedback != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Feedback',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(application.feedback!),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.attach_file, size: 16, color: Colors.grey.shade600),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Resume attached',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
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
        setState(() {
          _filterStatus = label;
        });
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}