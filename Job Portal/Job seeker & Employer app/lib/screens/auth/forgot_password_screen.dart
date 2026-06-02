import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
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
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _isEmailSent
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email,
                            size: 80,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Check Your Email',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We have sent password reset instructions to\n${_emailController.text}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: const Text('Back to Login'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_reset,
                            size: 80,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your email address and we\'ll send you instructions to reset your password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      setState(() => _isLoading = true);
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      final success = await authProvider.resetPassword(_emailController.text.trim());
                                      setState(() {
                                        _isLoading = false;
                                        _isEmailSent = success;
                                      });
                                      if (!success && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Failed to send reset email. Please try again.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Send Reset Instructions', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Back to Login'),
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
    super.dispose();
  }
}