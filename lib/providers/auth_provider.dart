import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _hasSeenOnboarding = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final savedEmail = prefs.getString('userEmail');
    if (savedEmail != null) {
      _currentUser = MockData.users.firstWhere(
        (u) => u.email == savedEmail,
        orElse: () => MockData.users[1],
      );
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<void> setOnboardingSeen() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    notifyListeners();
  }

  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@app.com') {
      _currentUser = MockData.users[0]; // Admin user
    } else {
      // Mock: accept any email/password
      _currentUser = MockData.users.firstWhere(
        (u) => u.email == email,
        orElse: () => UserModel(
          id: 'u_new',
          fullName: email.split('@').first,
          email: email,
          phone: '+1 555-0000',
          avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
          joinDate: DateTime.now(),
        ),
      );
    }

    _isAuthenticated = true;
    _isLoading = false;

    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
    }

    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      email: email,
      phone: phone,
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
      joinDate: DateTime.now(),
    );

    _isAuthenticated = true;
    _isLoading = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    notifyListeners();
  }

  void toggleDarkMode(bool isDark) {
    notifyListeners();
  }
}
