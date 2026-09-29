import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../repositories/category_repository.dart';
import '../repositories/transaction_repository.dart';

class StatisticsProvider extends ChangeNotifier {
  final TransactionRepository _txRepo = TransactionRepository();
  final CategoryRepository _catRepo = CategoryRepository();

  TransactionType selectedType = TransactionType.expense;
  Map<int, double> categoryTotals = {};
  Map<int, String> categoryNames = {};
  bool isLoading = false;
  int? _userId;

  Future<void> load(int userId) async {
    _userId = userId;
    isLoading = true;
    notifyListeners();

    final categories = await _catRepo.getAllCategories(userId);
    categoryNames = {for (var c in categories) c.id!: c.name};
    categoryTotals = await _txRepo.getTotalsByCategory(userId, selectedType);

    isLoading = false;
    notifyListeners();
  }

  Future<void> setType(TransactionType type) async {
    selectedType = type;
    if (_userId != null) await load(_userId!);
  }
}