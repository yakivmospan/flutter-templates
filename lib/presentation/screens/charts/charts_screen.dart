import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/entity/Transaction.dart';
import '../../localization/localization.dart';
import 'charts_bloc.dart';
import 'charts_event.dart';
import 'charts_state.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartsBloc, ChartsState>(
      builder: (context, state) {
        if (state is ChartsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChartsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).errorLoading,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ChartsBloc>().add(LoadCharts());
                  },
                  child: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          );
        } else if (state is ChartsLoaded) {
          return _buildCharts(context, state.transactions);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCharts(BuildContext context, List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenses.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).noExpensesToDisplay,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var transaction in expenses) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    // Sort by amount
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).spendingByCategory,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildPieChart(context, sortedEntries, total),
          const SizedBox(height: 24),
          _buildCategoryList(context, sortedEntries, total),
        ],
      ),
    );
  }

  Widget _buildPieChart(
      BuildContext context,
      List<MapEntry<String, double>> entries,
      double total,
      ) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: PieChartPainter(entries, total),
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context,
      List<MapEntry<String, double>> entries,
      double total,
      ) {
    final colors = _generateColors(entries.length);

    return Column(
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value.key;
        final amount = entry.value.value;
        final percentage = (amount / total * 100).toStringAsFixed(1);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$$percentage% ${AppLocalizations.of(context).ofTotal}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Color> _generateColors(int count) {
    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      final hue = (i * 360 / count) % 360;
      colors.add(HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor());
    }
    return colors;
  }
}

class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;

  PieChartPainter(this.entries, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.8;

    double startAngle = -pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = (entries[i].value / total) * 2 * pi;
      final color = _getColor(i, entries.length);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw white circle in center to make it a donut chart
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  Color _getColor(int index, int total) {
    final hue = (index * 360 / total) % 360;
    return HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}