import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, type, amount, category, date, notes];
}