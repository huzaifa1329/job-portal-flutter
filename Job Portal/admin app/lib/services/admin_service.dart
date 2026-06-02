// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_model.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AdminModel?> loginAdmin(String email, String password) async {
    try {
      print('=== ADMIN LOGIN DEBUG ===');
      print('Email: $email');

      // Sign in with Supabase Auth
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        print('❌ Sign in failed - no user returned');
        return null;
      }

      print('✅ User authenticated: ${response.user!.id}');
      print('User email from auth: ${response.user!.email}');

      // Validate that the signed-in user is present in admins.
      // If this DB query fails (RLS/schema issue), we should NOT present it as invalid credentials.
      // Instead, return null after logging the real error.
      final adminQueryResponse = await _supabase
          .from('admins')
          .select('*')
          .eq('id', response.user!.id)
          .maybeSingle();

      final adminQuery = adminQueryResponse;

      // If the query returned null, determine whether it was actually a failure.
      // Supabase client can throw; if not thrown, then it's either NOT FOUND or returns null.
      // We keep existing behavior: null => user not found, but we log accordingly.

      print(
          'Admin data from admins table: ${adminQuery != null ? "FOUND" : "NOT FOUND"}');
      if (adminQuery != null) {
        print('Admin email: ${adminQuery['email']}');
        print('Admin role: ${adminQuery['role']}');
        print('Admin full_name: ${adminQuery['full_name']}');
      }

      // If admin row isn't found, show a more accurate debug signal.
      if (adminQuery == null) {
        print(
            '❌ Auth user id ${response.user!.id} authenticated, but not found in admins.id');
        // Keep session? We sign out to avoid entering dashboard without being admin.
        await _supabase.auth.signOut();
        return null;
      }

      // Update last login time
      final updateResp = await _supabase
          .from('admins')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', response.user!.id)
          .select()
          .maybeSingle();

      if (updateResp == null) {
        print('⚠️ last_login update returned no row (still allowing login)');
      }

      print('✅ Login successful!');
      return AdminModel.fromJson(adminQuery);
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  Future<void> logoutAdmin() async {
  try {
    await _supabase.auth.signOut();
    print('✅ Admin logged out');
  } catch (e) {
    print('❌ Logout error: $e');
    rethrow;
  }
}

  Future<bool> isAdminLoggedIn() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;

    try {
      final adminData = await _supabase
          .from('admins')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      return adminData != null;
    } catch (e) {
      return false;
    }
  }
}
