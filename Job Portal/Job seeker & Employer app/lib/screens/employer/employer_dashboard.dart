import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../modules/job_model.dart';
import '../../modules/user_model.dart';
import '../../widgets/custom_button.dart';
import 'post_job_screen.dart';
import 'manage_jobs_screen.dart';
import 'view_applications_screen.dart';
import 'announcements_screen.dart';
import '../profile/profile_screen.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  final JobService _jobService = JobService();
  final AuthService _authService = AuthService();
  List<JobModel> _recentJobs = [];
  bool _isLoading = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      final jobs = await _jobService.getJobsByEmployer(_currentUser!.id);
      setState(() {
        _recentJobs = jobs.take(5).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.business,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUser?.fullName ?? 'Company',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Post New Job'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostJobScreen()),
                ).then((_) => _loadData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Manage Jobs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageJobsScreen()),
                ).then((_) => _loadData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('View Applications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewApplicationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.announcement, color: Colors.orange),
              title: const Text('Announcements'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmployerAnnouncementsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade300],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${_currentUser?.fullName ?? ''}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Jobs Posted: ${_recentJobs.length}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Post a New Job',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PostJobScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                          color: Colors.white,
                          isOutlined: false,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Jobs',
                          _recentJobs.length.toString(),
                          Icons.work,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Active Jobs',
                          _recentJobs.where((j) => j.status == 'approved').length.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Post Job',
                          Icons.add,
                          Colors.blue,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PostJobScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          'Manage Jobs',
                          Icons.edit,
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManageJobsScreen(),
                              ),
                            ).then((_) => _loadData());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Applications',
                          Icons.description,
                          Colors.purple,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ViewApplicationsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          'Announcements',
                          Icons.announcement,
                          Colors.orange,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmployerAnnouncementsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Profile',
                          Icons.person,
                          Colors.green,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Jobs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Jobs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageJobsScreen(),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _recentJobs.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.work_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No jobs posted yet',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PostJobScreen(),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                child: const Text('Post Your First Job'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _recentJobs.map((job) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: job.status == 'approved'
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  child: Icon(
                                    Icons.work,
                                    color: job.status == 'approved'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(job.title),
                                subtitle: Text(
                                  'Posted: ${_formatDate(job.postedDate)} • Status: ${job.status}',
                                ),
                                trailing: Text(
                                  '${job.applications} apps',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ManageJobsScreen(),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}