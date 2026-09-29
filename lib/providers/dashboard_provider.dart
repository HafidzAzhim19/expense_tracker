import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/category_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/currency_service.dart';

class DashboardProvider extends ChangeNotifier {
  final TransactionRepository _txRepo = TransactionRepository();
  final CategoryRepository _catRepo = CategoryRepository();
  final CurrencyService _currencyService = CurrencyService();

  List<AppTransaction> transactions = [];
  List<AppCategory> categories = [];
  Map<int, String> categoryMap = {};
  double totalIncome = 0;
  double totalExpense = 0;
  String kursInfo = 'Memuat kurs...';
  String currentFilter = 'ALL';
  int? _userId;

  Future<void> load(int userId) async {
    _userId = userId;
    categories = await _catRepo.getAllCategories(userId);
    categoryMap = {for (var c in categories) c.id!: c.name};
    await _loadTransactions();
    await _loadTotals();
    notifyListeners();
    fetchKurs();
  }

  Future<void> _loadTransactions() async {
    if (_userId == null) return;
    if (currentFilter == 'INCOME') {
      transactions = await _txRepo.getTransactionsByType(_userId!, TransactionType.income);
    } else if (currentFilter == 'EXPENSE') {
      transactions = await _txRepo.getTransactionsByType(_userId!, TransactionType.expense);
    } else {
      transactions = await _txRepo.getAllTransactions(_userId!);
    }
  }

  Future<void> _loadTotals() async {
    if (_userId == null) return;
    totalIncome = await _txRepo.getTotalIncome(_userId!);
    totalExpense = await _txRepo.getTotalExpense(_userId!);
  }

  Future<void> setFilter(String filter) async {
    currentFilter = filter;
    await _loadTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(int id) async {
    await _txRepo.deleteTransaction(id);
    await _loadTransactions();
    await _loadTotals();
    notifyListeners();
  }

  Future<void> refreshAfterAdd() async {
    await _loadTransactions();
    await _loadTotals();
    notifyListeners();
  }

  Future<String> addCategoryAndRefresh(String name) async {
    if (_userId == null) return 'Gagal: sesi user tidak ditemukan';
    final result = await _catRepo.addCategory(name, _userId!);
    if (result.success) {
      categories = await _catRepo.getAllCategories(_userId!);
      categoryMap = {for (var c in categories) c.id!: c.name};
      notifyListeners();
      return 'Kategori ditambahkan';
    }
    return result.message ?? 'Gagal menambah kategori';
  }

  Future<void> fetchKurs() async {
    kursInfo = 'Memuat kurs...';
    notifyListeners();
    kursInfo = await _currencyService.fetchKursHariIni();
    notifyListeners();
  }
}