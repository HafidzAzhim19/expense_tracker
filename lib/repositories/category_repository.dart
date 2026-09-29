import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/category.dart';

class CategoryResult {
  final bool success;
  final String? message;
  CategoryResult.success() : success = true, message = null;
  CategoryResult.error(this.message) : success = false;
}

class CategoryRepository {
  final dbHelper = DatabaseHelper.instance;

  // Kategori default (userId null) + kategori privat milik user ini sendiri
  Future<List<AppCategory>> getAllCategories(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'categories',
      where: 'userId IS NULL OR userId = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
    return result.map((e) => AppCategory.fromMap(e)).toList();
  }

  Future<CategoryResult> addCategory(String name, int userId) async {
    if (name.trim().isEmpty) return CategoryResult.error('Nama kategori tidak boleh kosong');
    final db = await dbHelper.database;
    await db.insert('categories', {'name': name.trim(), 'isDefault': 0, 'userId': userId});
    return CategoryResult.success();
  }

  Future<int> countTransactionsUsingCategory(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions WHERE categoryId = ?', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}