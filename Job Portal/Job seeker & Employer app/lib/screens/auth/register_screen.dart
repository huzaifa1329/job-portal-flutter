import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'job_seeker';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your ${_selectedRole == 'employer' ? 'company name' : 'full name'}', Colors.orange);
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter email address', Colors.orange);
      return;
    }
    
    if (!_emailController.text.trim().contains('@')) {
      _showSnackBar('Please enter a valid email address', Colors.orange);
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter a password', Colors.orange);
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters long', Colors.orange);
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.orange);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final location = _locationController.text.trim();
      
      print('📝 Starting registration for: $email as $_selectedRole');
      
      // Step 1: Sign up with Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'role': _selectedRole,
        },
      );
      
      if (response.user == null) {
        throw Exception('Failed to create user account. Please try again.');
      }
      
      print('✅ Auth user created: ${response.user!.id}');
      
      final userId = response.user!.id;
      
      // Step 2: Create profile based on role
      if (_selectedRole == 'employer') {
        await Supabase.instance.client.from('employers').insert({
          'id': userId,
          'email': email,
          'company_name': name,
          'contact_person': name,
          'contact_phone': phone.isEmpty ? null : phone,
          'company_location': location.isEmpty ? null : location,
          'created_at': DateTime.now().toIso8601String(),
          'is_verified': false,
          'is_active': true,
        });
        print('✅ Employer profile created');
      } else {
        await Supabase.instance.client.from('job_seekers').insert({
          'id': userId,
          'email': email,
          'full_name': name,
          'phone': phone.isEmpty ? null : phone,
          'location': location.isEmpty ? null : location,
          'skills': [],
          'experience': 0,
          'education': '',
          'created_at': DateTime.now().toIso8601String(),
          'is_active': true,
        });
        print('✅ Job seeker profile created');
      }
      
      if (mounted) {
        _showSnackBar('Registration successful! Please login.', Colors.green);
        // Clear form and go back to login
        _clearForm();
        Navigator.pop(context);
      }
      
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      
      String errorMessage;
      if (e.message.contains('already registered')) {
        errorMessage = 'This email is already registered. Please login instead.';
      } else if (e.message.contains('password')) {
        errorMessage = 'Password is too weak. Please use a stronger password.';
      } else {
        errorMessage = e.message;
      }
      
      if (mounted) {
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      print('❌ Registration error: $e');
      
      String errorMessage = 'Registration failed. ';
      if (e.toString().contains('duplicate key')) {
        errorMessage = 'Email already registered. Please login instead.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('row-level security')) {
        errorMessage = 'Please try again in a few moments.';
      } else {
        errorMessage += e.toString();
      }
      
      if (mounted) {
        _showSnackBar(errorMessage, Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();
    _locationController.clear();
  }
  
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedRole == 'employer' 
                          ? 'Register your company to start hiring'
                          : 'Register to find your dream job',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Role Selection
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedRole = 'job_seeker');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'job_seeker' 
                                      ? Colors.blue.shade700 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Job Seeker',
                                    style: TextStyle(
                                      color: _selectedRole == 'job_seeker' 
                                          ? Colors.white 
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedRole = 'employer');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'employer' 
                                      ? Colors.blue.shade700 
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Employer',
                                    style: TextStyle(
                                      color: _selectedRole == 'employer' 
                                          ? Colors.white 
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Name Field
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: _selectedRole == 'employer' ? 'Company Name' : 'Full Name',
                        hintText: _selectedRole == 'employer' ? 'e.g., Tech Solutions Inc.' : 'e.g., John Doe',
                        prefixIcon: Icon(
                          _selectedRole == 'employer' ? Icons.business : Icons.person,
                          color: Colors.blue.shade700,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        hintText: 'e.g., +92 300 1234567',
                        prefixIcon: Icon(Icons.phone, color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Field
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location (Optional)',
                        hintText: 'e.g., Karachi, Pakistan',
                        prefixIcon: Icon(Icons.location_on, color: Colors.blue.shade700),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimum 6 characters',
                        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm Password Field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}