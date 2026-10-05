import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/atomic.dart';
import '../../../domain/services/focus_stats_calculator.dart';
import '../../../shared_widgets/empty_state.dart';
import '../../../shared_widgets/settings_action.dart';
import '../../../shared_widgets/error_view.dart';
import '../../export/view/export_sheet.dart';
import '../../focus_timer/viewmodel/focus_timer_view_model.dart';
import '../viewmodel/insights_view_model.dart';
import '../../../l10n/l10n.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklyFocusTotalsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    final todaysSummaryAsync = ref.watch(todaysFocusSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.navInsights),
        actions: [
          AtomicIconButton(
            icon: AtomicIcons.export,
            semanticLabel: context.l10n.exportThisWeek,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ExportSheet(),
            ),
          ),
          const SettingsAction(),
        ],
      ),
      body: weeklyAsync.when(
        loading: () => AtomicLoading(label: context.l10n.loadingInsights),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(recentFocusSessionsProvider),
        ),
        data: (dailyTotals) {
          final hasAnyData = dailyTotals.any((d) => d.sessionCount > 0);
          if (!hasAnyData) {
            return EmptyState(
              icon: AtomicIcons.review,
              title: context.l10n.insightsEmptyTitle,
              message: context.l10n.insightsEmptyMessage,
            );
          }

          final weekTotalSeconds =
              dailyTotals.fold<int>(0, (sum, d) => sum + d.totalSeconds);
          final weekSessionCount =
              dailyTotals.fold<int>(0, (sum, d) => sum + d.sessionCount);
          final todaySeconds = todaysSummaryAsync.value?.totalSeconds ?? 0;
          final streak = streakAsync.value ?? 0;

          return ListView(
            padding: const EdgeInsets.all(AtomicSpace.screenMargin),
            children: [
              _StatCards(cards: [
                _StatCard(
                    label: context.l10n.navToday,
                    value: _formatDuration(context.l10n, todaySeconds)),
                _StatCard(
                  label: context.l10n.dayStreak,
                  value: '$streak',
                  icon: AtomicIcons.streak,
                ),
                _StatCard(
                    label: context.l10n.thisWeek,
                    value: _formatDuration(context.l10n, weekTotalSeconds)),
              ]),
              const SizedBox(height: AtomicSpace.xxl),
              AtomicSectionLabel(context.l10n.last7Days),
              const SizedBox(height: AtomicSpace.m),
              SizedBox(
                  height: _chartHeight,
                  child: _WeeklyBarChart(totals: dailyTotals)),
              const SizedBox(height: AtomicSpace.s),
              AtomicText.mono(
                context.l10n.weekSessionCount(weekSessionCount),
                style: AtomicType.caption,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  static const _chartHeight = 180.0;

  String _formatDuration(AppLocalizations l10n, int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    return hours > 0
        ? l10n.durationHoursMinutes(hours, minutes)
        : l10n.durationMinutes(minutes);
  }
}

/// Three stat cards in a row of equal height; stacked full-width when
/// large text would break their words mid-way (seen in the 200% goldens).
class _StatCards extends StatelessWidget {
  const _StatCards({required this.cards});

  final List<_StatCard> cards;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 14 * 1.3;
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, card) in cards.indexed) ...[
            if (i > 0) const SizedBox(height: AtomicSpace.s),
            card,
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, card) in cards.indexed) ...[
            if (i > 0) const SizedBox(width: AtomicSpace.s),
            Expanded(child: card),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return AtomicCard(
      kind: AtomicCardKind.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The icon slot is always there, so values line up across cards.
          SizedBox(
            height: AtomicSize.iconTiny,
            child: icon == null
                ? null
                : Icon(icon, size: AtomicSize.iconTiny, color: p.accentText),
          ),
          const SizedBox(height: AtomicSpace.xs),
          // A hero number: Display, the real value (system §9.8).
          AtomicText.display(value, style: AtomicType.pushedTitle),
          const SizedBox(height: AtomicSpace.xxs),
          AtomicText.mono(label, style: AtomicType.caption),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.totals});

  static const _barWidth = 18.0;
  static final _labelSize = AtomicType.caption.fontSize!;

  final List<DailyFocusTotal> totals;

  @override
  Widget build(BuildContext context) {
    final minutesPerDay = totals.map((d) => d.totalSeconds / 60).toList();
    final maxMinutes = minutesPerDay.fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxMinutes <= 0 ? 30.0 : maxMinutes * 1.25;
    final p = context.atomic.palette;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMax,
        barTouchData: const BarTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        // Only a baseline: an ink rule, no grid, no box (docs/05 DS-10).
        borderData: FlBorderData(
          show: true,
          border: Border(
              bottom: BorderSide(color: p.rule, width: AtomicStroke.rule)),
        ),
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
              // Room for the day letter at any text size (fl_chart's
              // default height clips it at 200%).
              reservedSize: MediaQuery.textScalerOf(context).scale(_labelSize) +
                  AtomicSpace.m,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= totals.length) {
                  return const SizedBox.shrink();
                }
                final label = context.l10n.weekdayNarrow(totals[index].date);
                return Padding(
                  padding: const EdgeInsets.only(top: AtomicSpace.xs),
                  child: AtomicText.mono(label, style: AtomicType.caption),
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
                // Square Signal bars: no rounding, no gradient.
                BarChartRodData(
                  toY: minutesPerDay[i],
                  color: p.accentText,
                  width: _barWidth,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
