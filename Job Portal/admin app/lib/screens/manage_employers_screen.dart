import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/employer_management_model.dart';

class ManageEmployersScreen extends StatefulWidget {
  const ManageEmployersScreen({super.key});

  @override
  State<ManageEmployersScreen> createState() => _ManageEmployersScreenState();
}

class _ManageEmployersScreenState extends State<ManageEmployersScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<EmployerModel> _employers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadEmployers();
  }

  Future<void> _loadEmployers() async {
    setState(() => _isLoading = true);
    final employers = await _databaseService.getAllEmployers();
    if (mounted) {
      setState(() {
        _employers = employers;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleVerification(EmployerModel employer) async {
    await _databaseService.verifyEmployer(employer.id, !employer.isVerified);
    _loadEmployers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employer ${employer.isVerified ? 'unverified' : 'verified'} successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _toggleEmployerStatus(EmployerModel employer) async {
    await _databaseService.updateEmployerStatus(employer.id, !employer.isActive);
    _loadEmployers();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Employer account ${employer.isActive ? 'deactivated' : 'activated'}'),
          backgroundColor: employer.isActive ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  List<EmployerModel> get _filteredEmployers {
    var filtered = _employers;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((employer) =>
        employer.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        employer.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        employer.contactPerson.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_filterStatus != 'All') {
      filtered = filtered.where((employer) {
        if (_filterStatus == 'Verified') return employer.isVerified;
        if (_filterStatus == 'Unverified') return !employer.isVerified;
        if (_filterStatus == 'Active') return employer.isActive;
        if (_filterStatus == 'Inactive') return !employer.isActive;
        return true;
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Employers'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployers,
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
                    hintText: 'Search employers...',
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
                      _buildFilterChip('Verified'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unverified'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No employers found',
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
                        itemCount: _filteredEmployers.length,
                        itemBuilder: (context, index) {
                          final employer = _filteredEmployers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.green.shade100,
                                child: Text(
                                  employer.companyName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                              title: Text(
                                employer.companyName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('📧 ${employer.email}'),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: employer.isVerified
                                              ? Colors.blue.shade100
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          employer.isVerified ? 'Verified' : 'Unverified',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: employer.isVerified
                                                ? Colors.blue.shade800
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: employer.isActive
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          employer.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: employer.isActive
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      employer.isVerified
                                          ? Icons.verified
                                          : Icons.verified_outlined,
                                      color: employer.isVerified
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    onPressed: () => _toggleVerification(employer),
                                    tooltip: employer.isVerified ? 'Unverify' : 'Verify',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      employer.isActive
                                          ? Icons.block
                                          : Icons.check_circle,
                                      color: employer.isActive
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    onPressed: () => _toggleEmployerStatus(employer),
                                    tooltip: employer.isActive ? 'Deactivate' : 'Activate',
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (employer.companyDescription.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            '📝 ${employer.companyDescription}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      if (employer.companyWebsite.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            '🌐 ${employer.companyWebsite}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      if (employer.companyLocation.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            '📍 ${employer.companyLocation}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      const Divider(),
                                      Text(
                                        'Contact Person: ${employer.contactPerson}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '📞 ${employer.contactPhone}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Member since: ${_formatDate(employer.createdAt)}',
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