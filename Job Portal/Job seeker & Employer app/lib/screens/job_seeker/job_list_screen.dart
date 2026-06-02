import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../widgets/job_card.dart';
import '../../modules/job_model.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final JobService _jobService = JobService();
  List<JobModel> _jobs = [];
  List<JobModel> _filteredJobs = [];
  bool _isLoading = true;
  
  // Filters
  String _searchQuery = '';
  String _selectedJobType = 'All';
  String _selectedLocation = 'All';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    final jobs = await _jobService.getAllJobs();
    setState(() {
      _jobs = jobs;
      _filteredJobs = jobs;
      _isLoading = false;
    });
  }

  void _filterJobs() {
    setState(() {
      _filteredJobs = _jobs.where((job) {
        final matchesSearch = _searchQuery.isEmpty ||
            job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.description.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesJobType = _selectedJobType == 'All' ||
            job.jobType.toLowerCase().replaceAll('-', ' ') ==
                _selectedJobType.toLowerCase().replaceAll('-', ' ');
        
        final matchesLocation = _selectedLocation == 'All' ||
            job.location.toLowerCase().contains(_selectedLocation.toLowerCase());
        
        return matchesSearch && matchesJobType && matchesLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Jobs'),
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _filterJobs();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterJobs();
              },
            ),
          ),
          
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Job Type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildFilterChip('All', _selectedJobType, (value) {
                    setState(() => _selectedJobType = value);
                    _filterJobs();
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Full Time', _selectedJobType, (value) {
                    setState(() => _selectedJobType = value);
                    _filterJobs();
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Part Time', _selectedJobType, (value) {
                    setState(() => _selectedJobType = value);
                    _filterJobs();
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Remote', _selectedJobType, (value) {
                    setState(() => _selectedJobType = value);
                    _filterJobs();
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Contract', _selectedJobType, (value) {
                    setState(() => _selectedJobType = value);
                    _filterJobs();
                  }),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Found ${_filteredJobs.length} jobs',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_searchQuery.isNotEmpty ||
                    _selectedJobType != 'All' ||
                    _selectedLocation != 'All')
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedJobType = 'All';
                        _selectedLocation = 'All';
                        _searchController.clear();
                        _filterJobs();
                      });
                    },
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Job List
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
                            Text(
                              'Try adjusting your filters',
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
                        itemCount: _filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = _filteredJobs[index];
                          return JobCard(
                            job: job,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailScreen(job: job),
                                ),
                              ).then((_) => _loadJobs()); // Refresh on return
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, Function(String) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selectedValue == label,
      onSelected: (selected) {
        if (selected) {
          onSelected(label);
        } else {
          onSelected('All');
        }
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}