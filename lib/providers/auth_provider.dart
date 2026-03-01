import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants/mock_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _hasSeenOnboarding = false;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  ThemeMode get themeMode => _themeMode;
  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    _themeMode = (prefs.getBool('darkMode') ?? true)
        ? ThemeMode.dark
        : ThemeMode.light;
    _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    _emailNotifications = prefs.getBool('emailNotifications') ?? false;
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

  void toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _themeMode == ThemeMode.dark);
  }

  Future<void> updateNotificationSettings({
    required bool push,
    required bool email,
  }) async {
    _pushNotifications = push;
    _emailNotifications = email;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', push);
    await prefs.setBool('emailNotifications', email);
  }

  Future<void> updateProfile(String fullName, String phone) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(fullName: fullName, phone: phone);
    notifyListeners();
  }

  Future<bool> login(String email, String password,
      {bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@app.com') {
      _currentUser = MockData.users[0];
    } else {
      _currentUser = MockData.users.firstWhere(
        (u) => u.email == email,
        orElse: () => UserModel(
          id: 'u_new',
          fullName: email.split('@').first,
          email: email,
          phone: '+1 555-0000',
          avatarUrl: 'assets/images/avatar_admin.jpg',
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
      avatarUrl: 'assets/images/avatar_admin.jpg',
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

  // Legacy — kept for backwards compatibility.
  void toggleDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
