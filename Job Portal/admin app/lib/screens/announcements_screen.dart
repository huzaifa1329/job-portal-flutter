// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/announcement_model.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    final announcements = await _databaseService.getAllAnnouncements();
    if (mounted) {
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    }
  }

  Future<void> _createOrEditAnnouncement([AnnouncementModel? announcement]) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: announcement?.title ?? '');
    final contentController = TextEditingController(text: announcement?.content ?? '');
    // Use a ValueNotifier so inner StatefulBuilder setState can update these reliably
    String selectedTarget = announcement?.target ?? 'all';
    DateTime? selectedExpiresAt = announcement?.expiresAt;
    // Keep a reference to outer ScaffoldMessenger before dialog opens
    final outerMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(announcement == null ? 'Create Announcement' : 'Edit Announcement'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTarget,
                      decoration: const InputDecoration(
                        labelText: 'Target Audience',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'jobseekers', child: Text('Job Seekers Only')),
                        DropdownMenuItem(value: 'employers', child: Text('Employers Only')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedTarget = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Expires At'),
                      subtitle: Text(selectedExpiresAt == null
                          ? 'No expiry date'
                          : _formatDate(selectedExpiresAt!)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedExpiresAt ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              selectedExpiresAt = date;
                            });
                          }
                        },
                      ),
                    ),
                    if (selectedExpiresAt != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setDialogState(() {
                              selectedExpiresAt = null;
                            });
                          },
                          child: const Text('Remove Expiry Date'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      if (announcement == null) {
                        final newAnnouncement = AnnouncementModel(
                          id: '',
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                          target: selectedTarget,
                          createdAt: DateTime.now(),
                          expiresAt: selectedExpiresAt,
                          isActive: true,
                        );
                        await _databaseService.createAnnouncement(newAnnouncement);
                      } else {
                        await _databaseService.updateAnnouncement(announcement.id, {
                          'title': titleController.text.trim(),
                          'content': contentController.text.trim(),
                          'target': selectedTarget,
                          'expires_at': selectedExpiresAt?.toIso8601String(),
                        });
                      }
                      Navigator.pop(dialogContext);
                      _loadAnnouncements();
                      outerMessenger.showSnackBar(
                        SnackBar(
                          content: Text(announcement == null
                              ? 'Announcement created successfully'
                              : 'Announcement updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      outerMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(announcement == null ? 'Create' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleAnnouncementStatus(AnnouncementModel announcement) async {
    await _databaseService.updateAnnouncement(announcement.id, {
      'is_active': !announcement.isActive,
    });
    _loadAnnouncements();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Announcement ${announcement.isActive ? 'deactivated' : 'activated'}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteAnnouncement(AnnouncementModel announcement) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement.title}"?'),
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

    if (confirm == true && mounted) {
      await _databaseService.deleteAnnouncement(announcement.id);
      _loadAnnouncements();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getTargetIcon(String target) {
    switch (target) {
      case 'all':
        return '🌐';
      case 'jobseekers':
        return '👥';
      case 'employers':
        return '🏢';
      default:
        return '📢';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Announcements'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrEditAnnouncement(),
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.announcement_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No announcements yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _createOrEditAnnouncement(),
                        child: const Text('Create First Announcement'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = _announcements[index];
                    final isExpired = announcement.expiresAt != null && 
                        announcement.expiresAt!.isBefore(DateTime.now());
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: !announcement.isActive || isExpired
                              ? Colors.grey.shade50
                              : Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.shade100,
                                child: Text(
                                  _getTargetIcon(announcement.target),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              title: Text(
                                announcement.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: !announcement.isActive || isExpired
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: !announcement.isActive || isExpired
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    announcement.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      Text(
                                        '📅 ${_formatDate(announcement.createdAt)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      if (announcement.expiresAt != null)
                                        Text(
                                          '⏰ Expires: ${_formatDate(announcement.expiresAt!)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isExpired ? Colors.red : Colors.grey,
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: announcement.isActive && !isExpired
                                              ? Colors.green.shade100
                                              : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          announcement.isActive && !isExpired ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: announcement.isActive && !isExpired
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                            fontWeight: FontWeight.w500,
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
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _createOrEditAnnouncement(announcement),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      announcement.isActive && !isExpired
                                          ? Icons.notifications_off
                                          : Icons.notifications_active,
                                      color: announcement.isActive && !isExpired
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    onPressed: () => _toggleAnnouncementStatus(announcement),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteAnnouncement(announcement),
                                  ),
                                ],
                              ),
                            ),
                            if (isExpired && announcement.expiresAt != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'This announcement has expired',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}