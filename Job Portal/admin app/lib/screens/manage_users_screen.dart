// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/job_seeker_management_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<JobSeekerModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _databaseService.getAllJobSeekers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _toggleUserStatus(JobSeekerModel user) async {
    await _databaseService.updateJobSeekerStatus(user.id, !user.isActive);
    _loadUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User ${user.isActive ? 'blocked' : 'activated'} successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteUser(JobSeekerModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
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
      await _databaseService.deleteJobSeeker(user.id);
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<JobSeekerModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) =>
      user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      user.location.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Job Seekers'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
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
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  user.fullName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              title: Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('📧 ${user.email}'),
                                  if (user.location.isNotEmpty)
                                    Text('📍 ${user.location}'),
                                  if (user.skills.isNotEmpty)
                                    Text('🔧 Skills: ${user.skills.take(3).join(', ')}'),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: user.isActive
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.isActive ? 'Active' : 'Blocked',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: user.isActive
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      user.isActive
                                          ? Icons.block
                                          : Icons.check_circle,
                                      color: user.isActive
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    onPressed: () => _toggleUserStatus(user),
                                    tooltip: user.isActive ? 'Block' : 'Activate',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteUser(user),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                              onTap: () {
                                _showUserDetails(user);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(JobSeekerModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', user.email),
              const Divider(),
              _buildDetailRow('Phone', user.phone.isEmpty ? 'Not provided' : user.phone),
              const Divider(),
              _buildDetailRow('Location', user.location.isEmpty ? 'Not provided' : user.location),
              const Divider(),
              _buildDetailRow('Experience', '${user.experience} years'),
              const Divider(),
              _buildDetailRow('Education', user.education.isEmpty ? 'Not provided' : user.education),
              const Divider(),
              _buildDetailRow('Skills', user.skills.isEmpty ? 'None' : user.skills.join(', ')),
              const Divider(),
              _buildDetailRow('Member Since', _formatDate(user.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}