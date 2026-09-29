import 'package:flutter/foundation.dart';
import '../repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _repo = UserRepository();
  bool isLoading = false;
  String? errorMessage;

  Future<bool> register(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repo.register(username, password);
    isLoading = false;
    if (!result.success) {
      errorMessage = result.message;
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<int?> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repo.login(username, password);
    isLoading = false;
    if (!result.success) {
      errorMessage = result.message;
      notifyListeners();
      return null;
    }
    notifyListeners();
    return result.user!.id;
  }
}