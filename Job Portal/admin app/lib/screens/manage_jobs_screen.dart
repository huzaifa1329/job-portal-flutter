import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/job_management_model.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<JobModel> _jobs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
  try {
    setState(() => _isLoading = true);

    final jobs = await _databaseService.getAllJobs();

    print("Jobs Loaded: ${jobs.length}");

    setState(() {
      _jobs = jobs;
      _isLoading = false;
    });
  } catch (e) {
    print("ERROR LOADING JOBS: $e");

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading jobs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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

    if (confirm == true) {
      await _databaseService.deleteJob(job.id);
      _loadJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Approve job method
  Future<void> _approveJob(JobModel job) async {
    await _databaseService.updateJobStatus(job.id, 'approved');
    _loadJobs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Reject job method
  Future<void> _rejectJob(JobModel job) async {
    await _databaseService.updateJobStatus(job.id, 'rejected');
    _loadJobs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job rejected'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<JobModel> get _filteredJobs {
    var filtered = _jobs;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((job) =>
        job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        job.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        job.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_filterStatus != 'All') {
      filtered = filtered.where((job) => job.status == _filterStatus.toLowerCase()).toList();
    }
    
    return filtered;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search jobs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
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
              ],
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
                                backgroundColor: _getStatusColor(job.status).withValues(alpha: 0.2),
                                child: Icon(
                                  Icons.work,
                                  color: _getStatusColor(job.status),
                                ),
                              ),
                              title: Text(
                                job.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(job.companyName),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Text('📍 ${job.location}'),
                                      Text('💼 ${job.jobType}'),
                                      Text('💰 ${job.salary}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(job.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      job.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getStatusColor(job.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (job.status == 'pending')
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'approve') {
                                          _approveJob(job);
                                        } else if (value == 'reject') {
                                          _rejectJob(job);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'approve',
                                          child: Text('Approve', style: TextStyle(color: Colors.green)),
                                        ),
                                        const PopupMenuItem(
                                          value: 'reject',
                                          child: Text('Reject', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteJob(job),
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
                                        'Description',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(job.description),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Requirements',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(job.requirements),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Skills Required',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        children: job.skills.map((skill) => Chip(
                                          label: Text(skill),
                                          backgroundColor: Colors.blue.shade50,
                                        )).toList(),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('📅 Deadline: ${_formatDate(job.deadline)}'),
                                          Text('🎯 Vacancies: ${job.vacancies}'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('👁️ Views: ${job.views}'),
                                          Text('📝 Applications: ${job.applications}'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Posted on: ${_formatDate(job.postedDate)}',
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