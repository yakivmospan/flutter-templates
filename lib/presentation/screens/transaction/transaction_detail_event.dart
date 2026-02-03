import 'package:equatable/equatable.dart';

import '../../../core/entity/Transaction.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransaction extends TransactionDetailEvent {
  final String id;

  const LoadTransaction(this.id);

  @override
  List<Object> get props => [id];
}

class SaveTransaction extends TransactionDetailEvent {
  final Transaction transaction;

  const SaveTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class UpdateTransaction extends TransactionDetailEvent {
  final Transaction transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends TransactionDetailEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object> get props => [id];
}

class InitializeNewTransaction extends TransactionDetailEvent {
  final TransactionType type;

  const InitializeNewTransaction(this.type);

  @override
  List<Object> get props => [type];
}
