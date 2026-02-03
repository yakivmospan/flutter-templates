import 'package:hive/hive.dart';
import '../../entity/Transaction.dart';
import '../dto/transaction_dto.dart';

class TransactionDao {
  final Box<TransactionDto> _box;

  TransactionDao(this._box);

  Stream<BoxEvent> get transactionStream => _box.watch();

  Future<List<Transaction>> getAll() async {
    return _box.values.map((dto) => dto.toEntity()).toList();
  }

  Future<Transaction?> getById(String id) async {
    final dto = _box.values.firstWhere(
      (dto) => dto.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );
    return dto.toEntity();
  }

  Future<void> add(Transaction transaction) async {
    final dto = TransactionDto.fromEntity(transaction);
    await _box.put(transaction.id, dto);
  }

  Future<void> update(Transaction transaction) async {
    final dto = TransactionDto.fromEntity(transaction);
    await _box.put(transaction.id, dto);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}