import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/services/focus_stats_calculator.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../export/view/export_sheet.dart';
import '../../focus_timer/viewmodel/focus_timer_view_model.dart';
import '../viewmodel/insights_view_model.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyFocusTotalsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final todaysSummaryAsync = ref.watch(todaysFocusSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: 'Export this week',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ExportSheet(),
            ),
          ),
        ],
      ),
      body: weeklyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Something went wrong: $error')),
        data: (dailyTotals) {
          final hasAnyData = dailyTotals.any((d) => d.sessionCount > 0);
          if (!hasAnyData) {
            return const EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'Complete a session to see stats',
              message:
                  'Focus-time trends and streaks show up here once you\u2019ve logged a session.',
            );
          }

          final weekTotalSeconds =
              dailyTotals.fold<int>(0, (sum, d) => sum + d.totalSeconds);
          final weekSessionCount =
              dailyTotals.fold<int>(0, (sum, d) => sum + d.sessionCount);
          final todaySeconds =
              todaysSummaryAsync.valueOrNull?.totalSeconds ?? 0;
          final streak = streakAsync.valueOrNull ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                        label: 'Today', value: _formatDuration(todaySeconds)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Day streak',
                      value: '$streak',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        label: 'This week',
                        value: _formatDuration(weekTotalSeconds)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Last 7 days',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                  height: 180, child: _WeeklyBarChart(totals: dailyTotals)),
              const SizedBox(height: 12),
              Text(
                '$weekSessionCount focus session${weekSessionCount == 1 ? '' : 's'} this week',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.totals});

  final List<DailyFocusTotal> totals;

  @override
  Widget build(BuildContext context) {
    final minutesPerDay = totals.map((d) => d.totalSeconds / 60).toList();
    final maxMinutes = minutesPerDay.fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxMinutes <= 0 ? 30.0 : maxMinutes * 1.25;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMax,
        barTouchData: BarTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= totals.length)
                  return const SizedBox.shrink();
                final label =
                    DateFormat('E').format(totals[index].date).substring(0, 1);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(label,
                      style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < totals.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: minutesPerDay[i],
                  color: primary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
