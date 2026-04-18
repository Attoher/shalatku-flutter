import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _loading = false;
  String? _error;
  bool _notificationsEnabled = true;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get notificationsEnabled => _notificationsEnabled;

  AuthProvider() {
    _loadPreferences();
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signUp(email: email, password: password, name: name);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapError(e.code);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapError(e.code);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _authService.signOut();

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
