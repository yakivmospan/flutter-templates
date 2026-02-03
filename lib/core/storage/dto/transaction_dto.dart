import 'package:hive/hive.dart';
import '../../entity/Transaction.dart';

part 'transaction_dto.g.dart';

@HiveType(typeId: 0)
class TransactionDto extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int type; // '0 for income' or '1 expense'

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? notes;

  TransactionDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  factory TransactionDto.fromEntity(Transaction transaction) {
    return TransactionDto(
      id: transaction.id,
      type: transaction.type == TransactionType.income ? 0 : 1,
      amount: transaction.amount,
      category: transaction.category,
      date: transaction.date,
      notes: transaction.notes,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      type: type == 0 ? TransactionType.income : TransactionType.expense,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
    );
  }
}