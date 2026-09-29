enum TransactionType { income, expense }

class AppTransaction {
  final int? id;
  final int userId;
  final int categoryId;
  final double amount;
  final TransactionType type;
  final String? note;
  final int date;

  AppTransaction({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'categoryId': categoryId,
        'amount': amount,
        'type': type == TransactionType.income ? 'INCOME' : 'EXPENSE',
        'note': note,
        'date': date,
      };

  factory AppTransaction.fromMap(Map<String, dynamic> map) => AppTransaction(
        id: map['id'] as int?,
        userId: map['userId'] as int,
        categoryId: map['categoryId'] as int,
        amount: (map['amount'] as num).toDouble(),
        type: (map['type'] as String) == 'INCOME' ? TransactionType.income : TransactionType.expense,
        note: map['note'] as String?,
        date: map['date'] as int,
      );
}