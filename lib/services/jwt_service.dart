import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtService {
  final _storage = const FlutterSecureStorage();
  
  // Secret key untuk signing JWT lokal
  final String _secretKey = 'secret_key_expense_tracker_paling_aman';

  // 1. Generate & Simpan Token JWT pas Login Sukses
  Future<String> generateAndSaveToken(String userId) async {
    final jwt = JWT(
      {
        'sub': userId,
        'role': 'user',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      issuer: 'expense_tracker_app',
    );

    // Set Token Expire dalam 6 Jam
    final token = jwt.sign(
      SecretKey(_secretKey), 
      expiresIn: const Duration(hours: 6),
    );

    // Simpan terenkripsi di Keystore/Keychain HP
    await _storage.write(key: 'jwt_token', value: token);
    return token;
  }

  // 2. Validasi Token JWT pas Aplikasi Dibuka
  Future<bool> isSessionValid() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      print('JWT Valid! User ID: ${jwt.payload['sub']}');
      return true;
    } on JWTExpiredException {
      print('Sesi JWT udah kadaluwarsa (lebih dari 6 jam).');
      await clearToken();
      return false;
    } catch (e) {
      print('Token JWT tidak valid!');
      return false;
    }
  }

  // 3. Ambil User ID dari Token JWT
  Future<String?> getUserIdFromToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    try {
      final jwt = JWT.verify(token, SecretKey(_secretKey));
      return jwt.payload['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  // 4. Hapus Token pas Logout
  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}