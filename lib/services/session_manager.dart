import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'key_user_id';
  static const _keyUsername = 'key_username';
  static const _keyLoginTime = 'key_login_time';
  static const int sessionDurationMs = 6 * 60 * 60 * 1000; // 6 jam

  Future<void> saveLoggedInUser(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int> getLoggedInUserId() async => (await SharedPreferences.getInstance()).getInt(_keyUserId) ?? -1;

  Future<String> getLoggedInUsername() async => (await SharedPreferences.getInstance()).getString(_keyUsername) ?? 'User';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId) ?? -1;
    if (userId == -1) return false;

    final loginTime = prefs.getInt(_keyLoginTime) ?? 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch - loginTime;
    if (elapsed > sessionDurationMs) {
      await logout();
      return false;
    }
    return true;
  }

  Future<void> logout() async => (await SharedPreferences.getInstance()).clear();
}