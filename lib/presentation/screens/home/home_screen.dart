import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/entity/Transaction.dart';
import '../../../core/repository/transactions_repository.dart';
import '../../localization/localization.dart';
import '../../theme/theme_block.dart';
import '../category/category_list_bloc.dart';
import '../category/category_list_screen.dart';
import '../charts/charts_bloc.dart';
import '../charts/charts_screen.dart';
import '../transaction/transaction_screen.dart';
import '../transaction_list/transaction_list_bloc.dart';
import '../transaction_list/transaction_list_event.dart';
import '../transaction_list/transaction_list_screen.dart';
import '../transaction_list/transaction_list_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionListBloc(
            transactionsRepository: getIt<TransactionsRepository>(),
          )..add(LoadTransactions()),
        ),
        BlocProvider(create: (context) => CategoryListBloc()),
        BlocProvider(create: (context) => ChartsBloc()),
      ],
      child: const _HomeScreenContent(),
    );
  }
}

const tabCount = 3;

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  Future<void> _addTransaction(TransactionType type) async {
    setState(() {
      _isFabExpanded = false;
    });

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionScreen(initialType: type),
      ),
    );

    if (result == true && mounted) {
      context.read<TransactionListBloc>().add(RefreshTransactions());
    }
  }

  void _showFilterDialog(BuildContext context) {
    final bloc = context.read<TransactionListBloc>();
    final currentState = bloc.state;

    TransactionType? selectedType;
    DateTime? startDate;
    DateTime? endDate;

    if (currentState is TransactionListLoaded) {
      selectedType = currentState.filterType;
      startDate = currentState.filterStartDate;
      endDate = currentState.filterEndDate;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final localizations = AppLocalizations.of(context);

          return AlertDialog(
            title: Text(localizations.filter),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type filter
                  Text(
                    localizations.type,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<TransactionType?>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: null,
                          label: SizedBox.expand(
                            child: Center(child: Text(localizations.all)),
                          ),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: SizedBox.expand(
                            child: Center(child: Text(localizations.income)),
                          ),
                        ),
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: SizedBox.expand(
                            child: Center(child: Text(localizations.expense)),
                          ),
                        ),
                      ],
                      selected: {selectedType},
                      onSelectionChanged: (Set<TransactionType?> newSelection) {
                        setDialogState(() {
                          selectedType = newSelection.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date range filter
                  Text(
                    localizations.dateRange,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            startDate != null
                                ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                : 'Start',
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('to'),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            endDate != null
                                ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                                : 'End',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  bloc.add(ClearFilters());
                  Navigator.pop(dialogContext);
                },
                child: Text(localizations.clearFilters),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(localizations.cancel),
              ),
              FilledButton(
                onPressed: () {
                  bloc.add(FilterTransactions(
                    type: selectedType,
                    startDate: startDate,
                    endDate: endDate,
                  ));
                  Navigator.pop(dialogContext);
                },
                child: Text(localizations.applyFilters),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.transactions),
            Tab(text: localizations.categories),
            Tab(text: localizations.charts),
          ],
        ),
        actions: [
          BlocBuilder<TransactionListBloc, TransactionListState>(
            builder: (context, state) {
              if (state is TransactionListLoaded) {
                final isPositive = state.balance >= 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      '\$${state.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                BlocBuilder<TransactionListBloc, TransactionListState>(
                  builder: (context, state) {
                    if (state is TransactionListLoaded && state.hasActiveFilters) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TransactionListScreen(),
          CategoryListScreen(),
          ChartsScreen(),
        ],
      ),
      floatingActionButton: _buildExpandableFab(context, localizations),
    );
  }

  Widget _buildExpandableFab(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildFabOption(
            context: context,
            label: localizations.addIncome,
            icon: Icons.arrow_downward,
            color: Colors.green,
            onPressed: () => _addTransaction(TransactionType.income),
          ),
          const SizedBox(height: 12),
          _buildFabOption(
            context: context,
            label: localizations.addExpense,
            icon: Icons.arrow_upward,
            color: Colors.red,
            onPressed: () => _addTransaction(TransactionType.expense),
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: _toggleFab,
          child: AnimatedRotation(
            turns: _isFabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(label),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: color,
          mini: true,
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }
}
