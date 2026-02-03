import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/entity/Transaction.dart';
import '../../localization/localization.dart';
import '../transaction/transaction_screen.dart';
import 'transaction_list_bloc.dart';
import 'transaction_list_event.dart';
import 'transaction_list_state.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionListBloc, TransactionListState>(
      builder: (context, state) {
        if (state is TransactionListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionListError) {
          return _buildErrorWidget(context);
        } else if (state is TransactionListLoaded) {
          if (state.transactions.isEmpty) {
            return _buildEmptyWidget(context);
          }
          return _buildTransactionList(context, state.transactions);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localizations.errorLoading,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionListBloc>().add(LoadTransactions());
            },
            child: Text(localizations.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Text(
        localizations.noTransactions,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<Transaction> transactions) {
    return ListView.builder(
      itemCount: transactions.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionListItem(
          transaction: transaction,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionScreen(
                  transactionId: transaction.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionListItem({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              isIncome ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(transaction.date)),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                transaction.notes!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
