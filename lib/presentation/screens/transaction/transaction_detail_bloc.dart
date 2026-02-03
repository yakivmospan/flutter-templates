import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/entity/Transaction.dart';
import '../../../core/repository/transactions_repository.dart';
import 'transaction_detail_event.dart';
import 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final TransactionsRepository transactionsRepository;

  TransactionDetailBloc({required this.transactionsRepository})
      : super(TransactionDetailInitial()) {
    on<LoadTransaction>(_onLoadTransaction);
    on<InitializeNewTransaction>(_onInitializeNewTransaction);
    on<SaveTransaction>(_onSaveTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransaction(
      LoadTransaction event, Emitter<TransactionDetailState> emit) async {
    emit(TransactionDetailLoading());
    try {
      final transaction = await transactionsRepository.getTransaction(event.id);
      emit(TransactionDetailLoaded(
        transaction: transaction,
        mode: TransactionMode.view,
      ));
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }

  Future<void> _onInitializeNewTransaction(InitializeNewTransaction event,
      Emitter<TransactionDetailState> emit) async {
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: event.type,
      amount: 0.0,
      category: '',
      date: DateTime.now(),
      notes: null,
    );
    emit(TransactionDetailLoaded(
      transaction: newTransaction,
      mode: TransactionMode.add,
    ));
  }

  Future<void> _onSaveTransaction(
      SaveTransaction event, Emitter<TransactionDetailState> emit) async {
    emit(TransactionDetailSaving());
    try {
      await transactionsRepository.addTransaction(event.transaction);
      emit(TransactionDetailSaved());
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransaction event, Emitter<TransactionDetailState> emit) async {
    emit(TransactionDetailSaving());
    try {
      await transactionsRepository.updateTransaction(event.transaction);
      emit(TransactionDetailSaved());
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<TransactionDetailState> emit) async {
    emit(TransactionDetailDeleting());
    try {
      await transactionsRepository.deleteTransaction(event.id);
      emit(TransactionDetailDeleted());
    } catch (e) {
      emit(TransactionDetailError(e.toString()));
    }
  }
}
