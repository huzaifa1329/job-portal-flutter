// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/admin_service.dart';
import '../models/admin_dashboard_model.dart';
import '../widgets/admin_card.dart';
import 'manage_users_screen.dart';
import 'manage_employers_screen.dart';
import 'manage_jobs_screen.dart';
import 'applications_screen.dart';
import 'announcements_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _databaseService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      final adminService = AdminService();
      await adminService.logoutAdmin();
    } catch (e) {
      print('Logout error (ignored): $e');
    } finally {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Job Portal Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage everything',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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
              leading: const Icon(Icons.people),
              title: const Text('Job Seekers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageUsersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Employers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageEmployersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Jobs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageJobsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Applications'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ApplicationsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.announcement),
              title: const Text('Announcements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnnouncementsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Failed to load dashboard data'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Admin!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Here\'s what\'s happening with your job portal today.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          AdminCard(
                            title: 'Total Users',
                            value: _stats!.totalUsers.toString(),
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManageUsersScreen(),
                                ),
                              );
                            },
                          ),
                          AdminCard(
                            title: 'Total Employers',
                            value: _stats!.totalEmployers.toString(),
                            icon: Icons.business,
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManageEmployersScreen(),
                                ),
                              );
                            },
                          ),
                          AdminCard(
                            title: 'Total Jobs',
                            value: _stats!.totalJobs.toString(),
                            icon: Icons.work,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManageJobsScreen(),
                                ),
                              );
                            },
                          ),
                          AdminCard(
                            title: 'Applications',
                            value: _stats!.totalApplications.toString(),
                            icon: Icons.description,
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ApplicationsScreen(),
                                ),
                              );
                            },
                          ),
                          AdminCard(
                            title: 'Pending Jobs',
                            value: _stats!.pendingJobs.toString(),
                            icon: Icons.pending,
                            color: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ManageJobsScreen(),
                                ),
                              );
                            },
                          ),
                          AdminCard(
                            title: 'Announcements',
                            value: '0',
                            icon: Icons.announcement,
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AnnouncementsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}