import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class AuthResult {
  final bool success;
  final String? message;
  final AppUser? user;
  AuthResult.success(this.user) : success = true, message = null;
  AuthResult.error(this.message) : success = false, user = null;
}

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  String _hashPassword(String password) => sha256.convert(utf8.encode(password)).toString();

  Future<AuthResult> register(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return AuthResult.error('Username dan password tidak boleh kosong');
    }
    // Validasi dasar MASVS-AUTH: panjang minimum password
    if (password.length < 6) {
      return AuthResult.error('Password minimal 6 karakter');
    }

    final db = await dbHelper.database;
    final existing = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (existing.isNotEmpty) {
      return AuthResult.error('Username sudah digunakan');
    }

    final hashed = _hashPassword(password);
    final id = await db.insert('users', {'username': username, 'password': hashed});
    return AuthResult.success(AppUser(id: id, username: username, password: hashed));
  }

  Future<AuthResult> login(String username, String password) async {
    final db = await dbHelper.database;
    final hashed = _hashPassword(password);
    final result = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, hashed]);
    if (result.isNotEmpty) return AuthResult.success(AppUser.fromMap(result.first));
    return AuthResult.error('Username atau password salah');
  }
}