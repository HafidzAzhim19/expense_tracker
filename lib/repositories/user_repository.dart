import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import '../utils/validators.dart';

class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;
  AuthResult.success(this.user) : success = true, message = null;
  AuthResult.error(this.message) : success = false, user = null;
}

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  String _generateSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return base64Encode(bytes);
  }

  String _hashPassword(String password, String salt) {
    List<int> bytes = utf8.encode(password + salt);
    for (int i = 0; i < 10000; i++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64Encode(bytes);
  }

  Future<AuthResult> register(String username, String password) async {
    if (username.trim().isEmpty) {
      return AuthResult.error('Username tidak boleh kosong');
    }
    final complexityError = PasswordValidator.validate(password);
    if (complexityError != null) {
      return AuthResult.error(complexityError);
    }

    final db = await dbHelper.database;
    final existing = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (existing.isNotEmpty) {
      return AuthResult.error('Username sudah digunakan');
    }

    final salt = _generateSalt();
    final hashed = _hashPassword(password, salt);
    final id = await db.insert('users', {'username': username, 'password': hashed, 'salt': salt});
    return AuthResult.success(AppUser(id: id, username: username, password: hashed));
  }

  Future<AuthResult> login(String username, String password) async {
    final db = await dbHelper.database;
    final result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isEmpty) return AuthResult.error('Username atau password salah');

    final row = result.first;
    final salt = row['salt'] as String;
    final hashed = _hashPassword(password, salt);

    if (hashed == row['password']) {
      return AuthResult.success(AppUser.fromMap(row));
    }
    return AuthResult.error('Username atau password salah');
  }
}