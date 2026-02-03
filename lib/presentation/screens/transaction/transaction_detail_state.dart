import 'package:equatable/equatable.dart';

import '../../../core/entity/Transaction.dart';

enum TransactionMode { add, view, edit }

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {}

class TransactionDetailLoading extends TransactionDetailState {}

class TransactionDetailLoaded extends TransactionDetailState {
  final Transaction transaction;
  final TransactionMode mode;

  const TransactionDetailLoaded({
    required this.transaction,
    required this.mode,
  });

  @override
  List<Object> get props => [transaction, mode];

  TransactionDetailLoaded copyWith({
    Transaction? transaction,
    TransactionMode? mode,
  }) {
    return TransactionDetailLoaded(
      transaction: transaction ?? this.transaction,
      mode: mode ?? this.mode,
    );
  }
}

class TransactionDetailSaving extends TransactionDetailState {}

class TransactionDetailSaved extends TransactionDetailState {}

class TransactionDetailDeleting extends TransactionDetailState {}

class TransactionDetailDeleted extends TransactionDetailState {}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object> get props => [message];
}
