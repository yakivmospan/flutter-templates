import 'package:equatable/equatable.dart';
import '../../../core/entity/Transaction.dart';

abstract class TransactionListEvent extends Equatable {
  const TransactionListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionListEvent {}

class RefreshTransactions extends TransactionListEvent {}

class FilterTransactions extends TransactionListEvent {
  final TransactionType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTransactions({
    this.type,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, startDate, endDate];
}

class ClearFilters extends TransactionListEvent {}