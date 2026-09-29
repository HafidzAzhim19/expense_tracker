import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'key_user_id';
  static const _keyUsername = 'key_username';

  Future<void> saveLoggedInUser(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
  }

  Future<int> getLoggedInUserId() async => (await SharedPreferences.getInstance()).getInt(_keyUserId) ?? -1;

  Future<String> getLoggedInUsername() async => (await SharedPreferences.getInstance()).getString(_keyUsername) ?? 'User';

  Future<bool> isLoggedIn() async => (await getLoggedInUserId()) != -1;

  Future<void> logout() async => (await SharedPreferences.getInstance()).clear();
}