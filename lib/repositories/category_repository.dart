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

  Future<List<AppCategory>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((e) => AppCategory.fromMap(e)).toList();
  }

  Future<CategoryResult> addCategory(String name) async {
    if (name.trim().isEmpty) return CategoryResult.error('Nama kategori tidak boleh kosong');
    final db = await dbHelper.database;
    await db.insert('categories', {'name': name.trim(), 'isDefault': 0});
    return CategoryResult.success();
  }

  Future<int> countTransactionsUsingCategory(int categoryId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM transactions WHERE categoryId = ?', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}