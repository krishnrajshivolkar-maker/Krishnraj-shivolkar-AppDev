import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../core/supabase_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  final _client = SupabaseService.client;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch user profile from 'profiles' table
        final profileData = await _client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();
            
        _currentUser = User.fromJson(profileData);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Login Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, Map<String, dynamic> data) async {
      // Implementation for signup if needed
  }

  void logout() async {
    await _client.auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
  
  // Check current session on app start
  Future<void> checkSession() async {
      final session = _client.auth.currentSession;
      if (session != null) {
          try {
             final profileData = await _client
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();
            _currentUser = User.fromJson(profileData);
            _isAuthenticated = true;
            notifyListeners();
          } catch(e) {
             // Handle profile fetch error (maybe log out)
             logout();
          }
      }
  }
}
