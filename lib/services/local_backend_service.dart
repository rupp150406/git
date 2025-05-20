import 'package:shared_preferences/shared_preferences.dart';

class LocalBackendService {
  static LocalBackendService? _instance;
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _usernameKey = 'username';
  static const String _tokenKey = 'token';

  // Singleton pattern
  static LocalBackendService get instance {
    _instance ??= LocalBackendService();
    return _instance!;
  }

  // Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Email methods
  Future<void> setEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_emailKey, email);
  }

  Future<String?> getEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_emailKey);
  }

  // Password methods
  Future<void> updatePassword(String password) async {
    final prefs = await _prefs;
    await prefs.setString(_passwordKey, password);
  }

  Future<String?> getPassword() async {
    final prefs = await _prefs;
    return prefs.getString(_passwordKey);
  }

  // Username methods
  Future<void> setUsername(String username) async {
    final prefs = await _prefs;
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> getUsername() async {
    final prefs = await _prefs;
    return prefs.getString(_usernameKey);
  }

  // Token methods
  Future<void> setToken(String? token) async {
    final prefs = await _prefs;
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
