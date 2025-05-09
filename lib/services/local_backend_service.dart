import 'package:shared_preferences/shared_preferences.dart';

class LocalBackendService {
  static final LocalBackendService instance = LocalBackendService._();
  LocalBackendService._();

  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static const String _aboutKey = 'about';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getUsername() {
    return _prefs.getString(_usernameKey) ?? '';
  }

  Future<void> setUsername(String username) async {
    await _prefs.setString(_usernameKey, username);
  }

  String getEmail() {
    return _prefs.getString(_emailKey) ?? '';
  }

  Future<void> setEmail(String initialEmail) async {
    if (!_prefs.containsKey(_emailKey)) {
      await _prefs.setString(_emailKey, initialEmail);
    }
  }

  String getAbout() {
    return _prefs.getString(_aboutKey) ?? 'just a simple person';
  }

  Future<void> setAbout(String about) async {
    await _prefs.setString(_aboutKey, about);
  }

  String getPassword() {
    return _prefs.getString(_passwordKey) ?? '';
  }

  Future<void> updatePassword(String newPassword) async {
    await _prefs.setString(_passwordKey, newPassword);
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_passwordKey);
    await _prefs.remove(_aboutKey);
  }
}
