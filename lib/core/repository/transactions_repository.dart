import '../entity/Transaction.dart';

abstract class TransactionsRepository {
  Future<List<Transaction>> getTransactions();
  Future<Transaction> getTransaction(String id);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<double> getBalance();
}

class TransactionsRepositoryImpl implements TransactionsRepository {
  final List<Transaction> _transactions = [
    Transaction(
      id: '1',
      type: TransactionType.income,
      amount: 5000.0,
      category: 'Salary',
      date: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Monthly salary',
    ),
    Transaction(
      id: '2',
      type: TransactionType.expense,
      amount: 150.0,
      category: 'Groceries',
      date: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'Weekly shopping',
    ),
    Transaction(
      id: '3',
      type: TransactionType.expense,
      amount: 50.0,
      category: 'Transport',
      date: DateTime.now().subtract(const Duration(days: 2)),
      notes: 'Gas',
    ),
    Transaction(
      id: '4',
      type: TransactionType.income,
      amount: 200.0,
      category: 'Freelance',
      date: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'Side project payment',
    ),
    Transaction(
      id: '5',
      type: TransactionType.expense,
      amount: 80.0,
      category: 'Entertainment',
      date: DateTime.now(),
      notes: 'Cinema and dinner',
    ),
  ];

  @override
  Future<List<Transaction>> getTransactions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_transactions);
  }

  @override
  Future<Transaction> getTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _transactions.firstWhere((t) => t.id == id);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _transactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    double balance = 0.0;
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }
}
