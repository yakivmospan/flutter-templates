import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/entity/Transaction.dart';
import '../../../core/repository/transactions_repository.dart';
import 'transaction_list_event.dart';
import 'transaction_list_state.dart';

class TransactionListBloc
    extends Bloc<TransactionListEvent, TransactionListState> {
  final TransactionsRepository transactionsRepository;
  List<Transaction> _allTransactions = [];

  TransactionListBloc({required this.transactionsRepository})
      : super(TransactionListInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<FilterTransactions>(_onFilterTransactions);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionListState> emit) async {
    emit(TransactionListLoading());
    try {
      _allTransactions = await transactionsRepository.getTransactions();
      final balance = await transactionsRepository.getBalance();
      emit(TransactionListLoaded(
        transactions: _allTransactions,
        balance: balance,
      ));
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }

  Future<void> _onRefreshTransactions(
      RefreshTransactions event, Emitter<TransactionListState> emit) async {
    try {
      _allTransactions = await transactionsRepository.getTransactions();
      final balance = await transactionsRepository.getBalance();

      // Preserve filters if they exist
      if (state is TransactionListLoaded) {
        final currentState = state as TransactionListLoaded;
        if (currentState.hasActiveFilters) {
          add(FilterTransactions(
            type: currentState.filterType,
            startDate: currentState.filterStartDate,
            endDate: currentState.filterEndDate,
          ));
          return;
        }
      }

      emit(TransactionListLoaded(
        transactions: _allTransactions,
        balance: balance,
      ));
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }

  Future<void> _onFilterTransactions(
      FilterTransactions event, Emitter<TransactionListState> emit) async {
    try {
      List<Transaction> filtered = _allTransactions;

      // Filter by type
      if (event.type != null) {
        filtered = filtered.where((t) => t.type == event.type).toList();
      }

      // Filter by date range
      if (event.startDate != null) {
        filtered = filtered
            .where((t) =>
                t.date.isAfter(event.startDate!) ||
                t.date.isAtSameMomentAs(event.startDate!))
            .toList();
      }
      if (event.endDate != null) {
        filtered = filtered
            .where((t) =>
                t.date.isBefore(event.endDate!.add(const Duration(days: 1))))
            .toList();
      }

      // Calculate balance from filtered transactions
      double balance = 0.0;
      for (var transaction in filtered) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }

      emit(TransactionListLoaded(
        transactions: filtered,
        balance: balance,
        filterType: event.type,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
      ));
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }

  Future<void> _onClearFilters(
      ClearFilters event, Emitter<TransactionListState> emit) async {
    try {
      final balance = await transactionsRepository.getBalance();
      emit(TransactionListLoaded(
        transactions: _allTransactions,
        balance: balance,
      ));
    } catch (e) {
      emit(TransactionListError(e.toString()));
    }
  }
}