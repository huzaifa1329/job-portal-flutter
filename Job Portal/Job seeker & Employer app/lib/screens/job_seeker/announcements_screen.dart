import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobSeekerAnnouncementsScreen extends StatefulWidget {
  const JobSeekerAnnouncementsScreen({super.key});

  @override
  State<JobSeekerAnnouncementsScreen> createState() =>
      _JobSeekerAnnouncementsScreenState();
}

class _JobSeekerAnnouncementsScreenState
    extends State<JobSeekerAnnouncementsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('announcements')
          .select()
          .eq('is_active', true)
          .or('target.eq.all,target.eq.jobseekers')
          .order('created_at', ascending: false);

      final filtered = response.where((a) {
        final expiresAt = a['expires_at'];
        if (expiresAt == null) return true;
        return DateTime.parse(expiresAt).isAfter(DateTime.now());
      }).toList();

      if (mounted) {
        setState(() {
          _announcements = List<Map<String, dynamic>>.from(filtered);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading announcements: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.announcement_outlined,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements at this time',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for updates.',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnnouncements,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _announcements.length,
                    itemBuilder: (context, index) {
                      final a = _announcements[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.campaign,
                                        color: Colors.orange.shade700,
                                        size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      a['title'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                a['content'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '📅 ${_formatDate(a['created_at'])}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600),
                                  ),
                                  if (a['expires_at'] != null)
                                    Text(
                                      '⏰ Expires: ${_formatDate(a['expires_at'])}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
