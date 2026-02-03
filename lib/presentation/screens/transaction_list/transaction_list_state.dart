import 'package:equatable/equatable.dart';
import '../../../core/entity/Transaction.dart';

abstract class TransactionListState extends Equatable {
  const TransactionListState();

  @override
  List<Object?> get props => [];
}

class TransactionListInitial extends TransactionListState {}

class TransactionListLoading extends TransactionListState {}

class TransactionListLoaded extends TransactionListState {
  final List<Transaction> transactions;
  final double balance;
  final TransactionType? filterType;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const TransactionListLoaded({
    required this.transactions,
    required this.balance,
    this.filterType,
    this.filterStartDate,
    this.filterEndDate,
  });

  @override
  List<Object?> get props => [
        transactions,
        balance,
        filterType,
        filterStartDate,
        filterEndDate,
      ];

  bool get hasActiveFilters =>
      filterType != null || filterStartDate != null || filterEndDate != null;
}

class TransactionListError extends TransactionListState {
  final String message;

  const TransactionListError(this.message);

  @override
  List<Object> get props => [message];
}
