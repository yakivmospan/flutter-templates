import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/repository/transactions_repository.dart';
import 'charts_event.dart';
import 'charts_state.dart';

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  final TransactionsRepository transactionsRepository;
  StreamSubscription? _transactionSubscription;

  ChartsBloc({required this.transactionsRepository})
      : super(ChartsInitial()) {
    on<LoadCharts>(_onLoadCharts);
    on<RefreshCharts>(_onRefreshCharts);

    _transactionSubscription = transactionsRepository.transactionChanges.listen(
          (_) {
        add(RefreshCharts());
      },
    );
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadCharts(
      LoadCharts event,
      Emitter<ChartsState> emit,
      ) async {
    emit(ChartsLoading());
    try {
      final transactions = await transactionsRepository.getTransactions();
      emit(ChartsLoaded(transactions: transactions));
    } catch (e) {
      emit(ChartsError(e.toString()));
    }
  }

  Future<void> _onRefreshCharts(
      RefreshCharts event,
      Emitter<ChartsState> emit,
      ) async {
    try {
      final transactions = await transactionsRepository.getTransactions();
      emit(ChartsLoaded(transactions: transactions));
    } catch (e) {
      emit(ChartsError(e.toString()));
    }
  }
}