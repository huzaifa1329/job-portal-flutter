import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final dynamic user; // Make it nullable
  const EditProfileScreen({super.key, this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // FIX: Check if user exists before accessing properties
    if (widget.user != null) {
      _fullNameController.text = widget.user.fullName ?? '';
      _phoneController.text = widget.user.phone ?? '';
      _locationController.text = widget.user.location ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          throw Exception('Not logged in');
        }
        
        final updates = {
          'full_name': _fullNameController.text,
          'phone': _phoneController.text,
          'location': _locationController.text,
        };
        
        // Check user role from widget or fetch it
        String userRole = 'job_seeker';
        if (widget.user != null) {
          userRole = widget.user.role;
        } else {
          // Try to determine role from database
          final employerCheck = await Supabase.instance.client
              .from('employers')
              .select()
              .eq('id', session.user.id)
              .maybeSingle();
          
          userRole = employerCheck != null ? 'employer' : 'job_seeker';
        }
        
        // Update based on role
        if (userRole == 'employer') {
          await Supabase.instance.client
              .from('employers')
              .update({
                'company_name': _fullNameController.text,
                'contact_phone': _phoneController.text,
                'company_location': _locationController.text,
              })
              .eq('id', session.user.id);
        } else {
          await Supabase.instance.client
              .from('job_seekers')
              .update(updates)
              .eq('id', session.user.id);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _fullNameController,
                        label: widget.user?.role == 'employer'
                            ? 'Company Name'
                            : 'Full Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _locationController,
                        label: 'Location',
                        prefixIcon: Icons.location_on,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}