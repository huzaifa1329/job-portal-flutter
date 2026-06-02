import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';
import '../modules/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isOffline = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  AuthProvider() {
    _loadCachedUser();
  }

  // Load cached user from local storage
  Future<void> _loadCachedUser() async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('current_user');

  if (userJson != null) {
    final Map<String, dynamic> data = jsonDecode(userJson);
    _currentUser = UserModel.fromJson(data);
    notifyListeners();
  }
}

  // Cache user locally
  Future<void> _cacheUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString( 'current_user', jsonEncode(user.toJson()),);
  }

  // Clear cached user
  Future<void> _clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        await _cacheUser(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? location,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        location: location,
      );
      if (user != null) {
        _currentUser = user;
        await _cacheUser(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _clearCachedUser();
    _currentUser = null;
    notifyListeners();
  }

  void setOfflineMode(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }
  Future<bool> resetPassword(String email) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    final success = await _authService.resetPassword(email);
    _isLoading = false;
    notifyListeners();
    return success;
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
}