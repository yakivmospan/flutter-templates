import 'package:equatable/equatable.dart';
import '../../../core/entity/Transaction.dart';

abstract class ChartsState extends Equatable {
  const ChartsState();
  @override
  List<Object> get props => [];
}

class ChartsInitial extends ChartsState {}

class ChartsLoading extends ChartsState {}

class ChartsLoaded extends ChartsState {
  final List<Transaction> transactions;

  const ChartsLoaded({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class ChartsError extends ChartsState {
  final String message;

  const ChartsError(this.message);

  @override
  List<Object> get props => [message];
}