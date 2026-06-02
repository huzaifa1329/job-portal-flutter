import 'package:supabase_flutter/supabase_flutter.dart';
import '../modules/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? location,
  }) async {
    try {
      print('📝 Starting signup for: $email');
      
      // Check if user already exists in auth
     final existingJobSeeker = await _supabase
    .from('job_seekers')
    .select('email')
    .eq('email', email.trim().toLowerCase())
    .maybeSingle();

final existingEmployer = await _supabase
    .from('employers')
    .select('email')
    .eq('email', email.trim().toLowerCase())
    .maybeSingle();

if (existingJobSeeker != null || existingEmployer != null) {
  throw Exception('User already exists. Please login.');
}
      // Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );
      
      if (response.user == null) {
        throw Exception('Failed to create user account');
      }
      
      print('✅ Auth user created: ${response.user!.id}');
      
      final userId = response.user!.id;
      final userEmail = email.trim().toLowerCase();
      
      // Create profile with retry logic
      int retryCount = 0;
      bool profileCreated = false;
      
      while (retryCount < 3 && !profileCreated) {
        try {
          if (role == 'employer') {
            print('📝 Creating employer profile (attempt ${retryCount + 1})...');
            await _supabase.from('employers').insert({
              'id': userId,
              'email': userEmail,
              'company_name': fullName,
              'contact_person': fullName,
              'contact_phone': phone ?? '',
              'company_location': location ?? '',
              'created_at': DateTime.now().toIso8601String(),
              'is_verified': false,
              'is_active': true,
            });
          } else {
            print('📝 Creating job seeker profile (attempt ${retryCount + 1})...');
            await _supabase.from('job_seekers').insert({
              'id': userId,
              'email': userEmail,
              'full_name': fullName,
              'phone': phone ?? '',
              'location': location ?? '',
              'skills': [],
              'experience': 0,
              'education': '',
              'created_at': DateTime.now().toIso8601String(),
              'is_active': true,
            });
          }
          profileCreated = true;
          print('✅ Profile created successfully');
        } catch (e) {
          print('⚠️ Profile creation attempt ${retryCount + 1} failed: $e');
          retryCount++;
          if (retryCount == 3) {
            rethrow;
          }
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      
      return UserModel(
        id: userId,
        email: userEmail,
        fullName: fullName,
        role: role,
        phone: phone,
        location: location,
        createdAt: DateTime.now(),
        isActive: true,
      );
      
    } catch (e) {
      print('❌ Signup error: $e');
      return null;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      print('📝 Attempting login for: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      
      if (response.user == null) {
        print('❌ Login failed: No user returned');
        return null;
      }
      
      print('✅ Auth login successful: ${response.user!.id}');
      
      final userId = response.user!.id;
      String role = 'job_seeker';
      String fullName = '';
      String? phone;
      String? location;
      
      // Check if user is an employer
      print('📝 Checking employer table...');
      final employerData = await _supabase
          .from('employers')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (employerData != null) {
        role = 'employer';
        fullName = employerData['company_name'] ?? '';
        phone = employerData['contact_phone'];
        location = employerData['company_location'];
        print('✅ Found as EMPLOYER: $fullName');
      } else {
        // Check if user is a job seeker
        print('📝 Checking job_seekers table...');
        final jobSeekerData = await _supabase
            .from('job_seekers')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        if (jobSeekerData != null) {
          role = 'job_seeker';
          fullName = jobSeekerData['full_name'] ?? '';
          phone = jobSeekerData['phone'];
          location = jobSeekerData['location'];
          print('✅ Found as JOB SEEKER: $fullName');
        } else {
          print('✅ Auto-created job seeker profile');
        }
      }
      
      return UserModel(
        id: userId,
        email: response.user!.email ?? email,
        fullName: fullName,
        role: role,
        phone: phone,
        location: location,
        createdAt: DateTime.now(),
        isActive: true,
      );
      
    } catch (e, stackTrace) {
      print('❌ Login error: $e');
      print(stackTrace);
      rethrow;
}
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    
    final userId = session.user.id;
    final userEmail = session.user.email ?? '';
    
    // Try to get from employers
    final employerData = await _supabase
        .from('employers')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (employerData != null) {
      return UserModel(
        id: userId,
        email: userEmail,
        fullName: employerData['company_name'] ?? '',
        role: 'employer',
        phone: employerData['contact_phone'],
        location: employerData['company_location'],
        createdAt: DateTime.now(),
        isActive: employerData['is_active'] ?? true,
      );
    }
    
    // Try to get from job seekers
    final jobSeekerData = await _supabase
        .from('job_seekers')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (jobSeekerData != null) {
      return UserModel(
        id: userId,
        email: userEmail,
        fullName: jobSeekerData['full_name'] ?? '',
        role: 'job_seeker',
        phone: jobSeekerData['phone'],
        location: jobSeekerData['location'],
        createdAt: DateTime.now(),
        isActive: jobSeekerData['is_active'] ?? true,
      );
    }
    
    return null;
  }
}