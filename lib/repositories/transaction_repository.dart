import '../db/database_helper.dart';
import '../models/transaction.dart';

class TransactionResult {
  final bool success;
  final String? message;
  TransactionResult.success() : success = true, message = null;
  TransactionResult.error(this.message) : success = false;
}

class TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<TransactionResult> addTransaction({
    required int userId,
    required int categoryId,
    required double amount,
    required TransactionType type,
    String? note,
    required int date,
  }) async {
    if (amount <= 0) return TransactionResult.error('Nominal harus lebih dari 0');
    final db = await dbHelper.database;
    final tx = AppTransaction(userId: userId, categoryId: categoryId, amount: amount, type: type, note: note, date: date);
    await db.insert('transactions', tx.toMap());
    return TransactionResult.success();
  }

  Future<void> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AppTransaction>> getAllTransactions(int userId) async {
    final db = await dbHelper.database;
    final result = await db.query('transactions', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return result.map((e) => AppTransaction.fromMap(e)).toList();
  }

  Future<List<AppTransaction>> getTransactionsByType(int userId, TransactionType type) async {
    final db = await dbHelper.database;
    final typeStr = type == TransactionType.income ? 'INCOME' : 'EXPENSE';
    final result = await db.query('transactions', where: 'userId = ? AND type = ?', whereArgs: [userId, typeStr], orderBy: 'date DESC');
    return result.map((e) => AppTransaction.fromMap(e)).toList();
  }

  Future<double> getTotalIncome(int userId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery("SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = 'INCOME'", [userId]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalExpense(int userId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery("SELECT SUM(amount) as total FROM transactions WHERE userId = ? AND type = 'EXPENSE'", [userId]);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}