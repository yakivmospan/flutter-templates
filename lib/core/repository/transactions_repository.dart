import '../entity/Transaction.dart';
import '../storage/storage.dart';

abstract class TransactionsRepository {
  Stream<void> get transactionChanges;
  Future<List<Transaction>> getTransactions();
  Future<Transaction> getTransaction(String id);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<double> getBalance();
}

class TransactionsRepositoryImpl implements TransactionsRepository {
  final Storage storage;

  TransactionsRepositoryImpl({required this.storage});

  @override
  Stream<void> get transactionChanges =>
      storage.transactionDao.transactionStream.map((_) {});

  @override
  Future<List<Transaction>> getTransactions() async {
    final transactions = await storage.transactionDao.getAll();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  Future<Transaction> getTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final transaction = await storage.transactionDao.getById(id);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }
    return transaction;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await storage.transactionDao.add(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await storage.transactionDao.update(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await storage.transactionDao.delete(id);
  }

  @override
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final transactions = await storage.transactionDao.getAll();

    double balance = 0.0;
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }
}