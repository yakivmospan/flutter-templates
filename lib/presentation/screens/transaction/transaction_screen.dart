import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../app/app_dependencies.dart';
import '../../../core/entity/Transaction.dart';
import '../../../core/repository/transactions_repository.dart';
import '../../localization/localization.dart';
import '../transaction/transaction_detail_bloc.dart';
import '../transaction/transaction_detail_event.dart';
import '../transaction/transaction_detail_state.dart';

class TransactionScreen extends StatelessWidget {
  final String? transactionId;
  final TransactionType? initialType;

  const TransactionScreen({super.key, this.transactionId, this.initialType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = TransactionDetailBloc(
          transactionsRepository: getIt<TransactionsRepository>(),
        );
        if (transactionId != null) {
          bloc.add(LoadTransaction(transactionId!));
        } else if (initialType != null) {
          bloc.add(InitializeNewTransaction(initialType!));
        }
        return bloc;
      },
      child: const _TransactionScreenContent(),
    );
  }
}

class _TransactionScreenContent extends StatefulWidget {
  const _TransactionScreenContent();

  @override
  State<_TransactionScreenContent> createState() =>
      _TransactionScreenContentState();
}

class _TransactionScreenContentState extends State<_TransactionScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TransactionType? _selectedType;
  Transaction? _originalTransaction;
  TransactionDetailState? _lastValidState;

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateForm(Transaction transaction) {
    _amountController.text = transaction.amount > 0
        ? transaction.amount.toStringAsFixed(2)
        : '';
    _categoryController.text = transaction.category;
    _notesController.text = transaction.notes ?? '';
    _selectedDate = transaction.date;
    _selectedType = transaction.type;
    _originalTransaction = transaction;
  }

  void _saveTransaction(BuildContext context, TransactionMode mode) {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id:
        _originalTransaction?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType!,
        amount: double.parse(_amountController.text),
        category: _categoryController.text,
        date: _selectedDate!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mode == TransactionMode.add) {
        context.read<TransactionDetailBloc>().add(SaveTransaction(transaction));
      } else {
        context.read<TransactionDetailBloc>().add(
          UpdateTransaction(transaction),
        );
      }
    }
  }

  void _deleteTransaction(BuildContext context) {
    if (_originalTransaction != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppLocalizations.of(context).delete),
          content: Text(AppLocalizations.of(context).deleteConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<TransactionDetailBloc>().add(
                  DeleteTransaction(_originalTransaction!.id),
                );
              },
              child: Text(
                AppLocalizations.of(context).delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _switchToEditMode(BuildContext context) {
    if (_originalTransaction != null) {
      context.read<TransactionDetailBloc>().emit(
        TransactionDetailLoaded(
          transaction: _originalTransaction!,
          mode: TransactionMode.edit,
        ),
      );
    }
  }

  void _cancelEdit(BuildContext context) {
    if (_originalTransaction != null) {
      _populateForm(_originalTransaction!);
      context.read<TransactionDetailBloc>().emit(
        TransactionDetailLoaded(
          transaction: _originalTransaction!,
          mode: TransactionMode.view,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return BlocConsumer<TransactionDetailBloc, TransactionDetailState>(
      listener: (context, state) {
        if (state is TransactionDetailSaved) {
          Navigator.pop(context, true);
        } else if (state is TransactionDetailDeleted) {
          Navigator.pop(context, true);
        } else if (state is TransactionDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.errorLoading),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TransactionDetailLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(localizations.transactions)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TransactionDetailLoaded) {
          _lastValidState = state;
          if (_originalTransaction == null ||
              _originalTransaction!.id != state.transaction.id) {
            _populateForm(state.transaction);
          }

          final mode = state.mode;
          final isViewMode = mode == TransactionMode.view;
          final isAddMode = mode == TransactionMode.add;
          final isEditMode = mode == TransactionMode.edit;

          String title;
          if (isAddMode) {
            title = localizations.addTransaction;
          } else if (isEditMode) {
            title = localizations.editTransaction;
          } else {
            title = localizations.viewTransaction;
          }

          return PopScope(
            canPop: !isEditMode,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && isEditMode) {
                _cancelEdit(context);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  if (isViewMode)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _switchToEditMode(context),
                    ),
                  if (isAddMode || isEditMode)
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _saveTransaction(context, mode),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: localizations.amount,
                          prefixText: '\$',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        enabled: !isViewMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Field
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: localizations.category,
                          border: const OutlineInputBorder(),
                        ),
                        enabled: !isViewMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Field
                      InkWell(
                        onTap: isViewMode ? null : () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: localizations.date,
                            border: const OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate!)
                                    : localizations.selectDate,
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes Field
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: localizations.notesOptional,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        enabled: !isViewMode,
                      ),
                      const SizedBox(height: 16),

                      // Type Display
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: localizations.type,
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedType == TransactionType.income
                              ? localizations.income
                              : localizations.expense,
                          style: TextStyle(
                            color: _selectedType == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Delete button at bottom for view mode
                      if (isViewMode) ...[
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: () => _deleteTransaction(context),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            localizations.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // If error state but we have a last valid state, show that instead
        if (state is TransactionDetailError && _lastValidState != null) {
          final loadedState = _lastValidState as TransactionDetailLoaded;
          final mode = loadedState.mode;
          final isViewMode = mode == TransactionMode.view;
          final isAddMode = mode == TransactionMode.add;
          final isEditMode = mode == TransactionMode.edit;

          String title;
          if (isAddMode) {
            title = localizations.addTransaction;
          } else if (isEditMode) {
            title = localizations.editTransaction;
          } else {
            title = localizations.viewTransaction;
          }

          return PopScope(
            canPop: !isEditMode,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && isEditMode) {
                _cancelEdit(context);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                actions: [
                  if (isViewMode)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _switchToEditMode(context),
                    ),
                  if (isAddMode || isEditMode)
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _saveTransaction(context, mode),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount Field
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: localizations.amount,
                          prefixText: '\$',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        enabled: !isViewMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Field
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: localizations.category,
                          border: const OutlineInputBorder(),
                        ),
                        enabled: !isViewMode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date Field
                      InkWell(
                        onTap: isViewMode ? null : () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: localizations.date,
                            border: const OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate != null
                                    ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(_selectedDate!)
                                    : localizations.selectDate,
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes Field
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: localizations.notesOptional,
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        enabled: !isViewMode,
                      ),
                      const SizedBox(height: 16),

                      // Type Display
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: localizations.type,
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedType == TransactionType.income
                              ? localizations.income
                              : localizations.expense,
                          style: TextStyle(
                            color: _selectedType == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Delete button at bottom for view mode
                      if (isViewMode) ...[
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: () => _deleteTransaction(context),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            localizations.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(localizations.transactions)),
          body: Center(child: Text(localizations.errorLoading)),
        );
      },
    );
  }
}