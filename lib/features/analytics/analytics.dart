import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/providers/analytics_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';

// Analytics screen with filters, charts, and execution log.
class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analytics = context.watch<AnalyticsProvider>();
    final blueprint = context.watch<BlueprintProvider>();
    final logItems = analytics.completedItems;
    final labelCounts = analytics.completionCountsByLabel;
    final durationStats = analytics.durationStatsByLabel;
    final overallStats = analytics.overallDurationStats;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _buildFiltersSection(context, analytics),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Completion by label',
                    child: _CompletionCharts(labelCounts: labelCounts),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Duration accuracy',
                    trailing: Text(
                      _formatDurationSummary(overallStats),
                      style: theme.textTheme.bodySmall,
                    ),
                    child: _DurationChart(stats: durationStats),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Habit streaks',
                    child: _HabitStreaksList(habits: blueprint.habits),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text('Execution log', style: theme.textTheme.titleMedium),
            ),
          ),
          if (logItems.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'No completed tasks for this range.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildLogTile(context, logItems[index], blueprint),
                  childCount: logItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(
    BuildContext context,
    AnalyticsProvider analytics,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filters', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  initialDateRange: analytics.range,
                  firstDate: DateTime(2020, 1, 1),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  analytics.setDateRange(picked);
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(_formatRange(context, analytics.range)),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<TaskLabel?>(
                value: analytics.labelFilter,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All labels'),
                  ),
                  ...TaskLabel.values.map(
                    (label) => DropdownMenuItem(
                      value: label,
                      child: Text(_labelText(label)),
                    ),
                  ),
                ],
                onChanged: analytics.setLabelFilter,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogTile(
    BuildContext context,
    ActivityInstance item,
    BlueprintProvider blueprint,
  ) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final title = _resolveTitle(item, blueprint);
    final label = _resolveLabel(item, blueprint);
    final dateText = localizations.formatShortDate(item.scheduledDate);
    final timeText = item.habitId != null
        ? 'All day'
        : localizations.formatTimeOfDay(
            TimeOfDay.fromDateTime(item.scheduledDate),
          );
    final note = item.note?.trim();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$dateText | $timeText | # ${_labelText(label)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          if (note != null && note.isNotEmpty)
            Text(note, style: theme.textTheme.bodyMedium)
          else
            Text(
              'No note',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  String _resolveTitle(ActivityInstance item, BlueprintProvider blueprint) {
    if (item.taskTemplateId != null) {
      return blueprint.templateById(item.taskTemplateId!)?.title ?? 'Task';
    }
    if (item.habitId != null) {
      return blueprint.habitById(item.habitId!)?.title ?? 'Habit';
    }
    return 'Activity';
  }

  TaskLabel _resolveLabel(ActivityInstance item, BlueprintProvider blueprint) {
    if (item.label != null) {
      return item.label!;
    }
    if (item.taskTemplateId != null) {
      return blueprint.templateById(item.taskTemplateId!)?.label ??
          TaskLabel.work;
    }
    if (item.habitId != null) {
      return blueprint.habitById(item.habitId!)?.label ?? TaskLabel.work;
    }
    return TaskLabel.work;
  }

  String _formatRange(BuildContext context, DateTimeRange range) {
    final localizations = MaterialLocalizations.of(context);
    final start = localizations.formatShortDate(range.start);
    final end = localizations.formatShortDate(range.end);
    return '$start - $end';
  }

  static String _formatDurationSummary(DurationStats stats) {
    if (stats.sampleCount == 0) {
      return 'No samples yet';
    }
    return 'Avg exp ${_formatDuration(stats.expectedAverage)} / Avg act ${_formatDuration(stats.actualAverage)}';
  }

  static String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}

// Card wrapper for analytics sections.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// Bar and pie charts for completion counts by label.
class _CompletionCharts extends StatelessWidget {
  final List<LabelCount> labelCounts;

  const _CompletionCharts({required this.labelCounts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = labelCounts.fold<int>(0, (sum, item) => sum + item.count);
    final colors = _chartColors(theme);

    if (total == 0) {
      return Text('No completed tasks yet.', style: theme.textTheme.bodyMedium);
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: _maxCount(labelCounts).toDouble(),
              barGroups: [
                for (var i = 0; i < labelCounts.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: labelCounts[i].count.toDouble(),
                        width: 14,
                        color: colors[i % colors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _gridInterval(labelCounts),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _gridInterval(labelCounts),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labelCounts.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortLabel(labelCounts[index].label),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final radius = size * 0.32;
              final centerSpaceRadius = size * 0.12;
              final titleStyle =
                  theme.textTheme.labelSmall ?? theme.textTheme.bodySmall;

              return PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: centerSpaceRadius,
                  sections: [
                    for (var i = 0; i < labelCounts.length; i++)
                      if (labelCounts[i].count > 0)
                        PieChartSectionData(
                          value: labelCounts[i].count.toDouble(),
                          color: colors[i % colors.length],
                          title: _percentLabel(labelCounts[i].count, total),
                          radius: radius,
                          titleStyle: titleStyle,
                          titlePositionPercentageOffset: 0.6,
                        ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (var i = 0; i < labelCounts.length; i++)
              if (labelCounts[i].count > 0)
                _LegendItem(
                  color: colors[i % colors.length],
                  label:
                      '${_labelText(labelCounts[i].label)} (${labelCounts[i].count})',
                ),
          ],
        ),
      ],
    );
  }

  static int _maxCount(List<LabelCount> counts) {
    final maxCount = counts.fold<int>(
      0,
      (max, item) => math.max(max, item.count),
    );
    return math.max(1, maxCount);
  }

  static double _gridInterval(List<LabelCount> counts) {
    final maxCount = _maxCount(counts);
    if (maxCount <= 4) {
      return 1;
    }
    return (maxCount / 4).ceilToDouble();
  }

  static String _shortLabel(TaskLabel label) {
    final text = _labelText(label);
    // if (text.length <= 4) {
    return text;
    // }
    // return '${text.substring(0, 4)}...';
  }

  static String _percentLabel(int count, int total) {
    if (total == 0) {
      return '';
    }
    final percent = ((count / total) * 100).round();
    if (percent < 5) {
      return '';
    }
    return '$percent%';
  }
}

// Dual-bar chart comparing expected vs actual durations.
class _DurationChart extends StatelessWidget {
  final List<LabelDurationStats> stats;

  const _DurationChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (stats.isEmpty) {
      return Text('No duration data yet.', style: theme.textTheme.bodyMedium);
    }

    final expectedColor = theme.colorScheme.primary;
    final actualColor = theme.colorScheme.secondary;
    final maxMinutes = _maxMinutes(stats);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: maxMinutes,
              barGroups: [
                for (var i = 0; i < stats.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: stats[i].expectedAverage.inMinutes.toDouble(),
                        width: 7,
                        color: expectedColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      BarChartRodData(
                        toY: stats[i].actualAverage.inMinutes.toDouble(),
                        width: 7,
                        color: actualColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
              ],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _durationInterval(stats),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: _durationInterval(stats),
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${value.toInt()}m',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= stats.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _shortLabel(stats[index].label),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          children: [
            _LegendItem(color: expectedColor, label: 'Expected'),
            _LegendItem(color: actualColor, label: 'Actual'),
          ],
        ),
      ],
    );
  }

  static double _maxMinutes(List<LabelDurationStats> stats) {
    final maxMinutes = stats.fold<int>(
      0,
      (maxValue, item) => math.max(
        maxValue,
        math.max(item.expectedAverage.inMinutes, item.actualAverage.inMinutes),
      ),
    );
    return math.max(1, maxMinutes).toDouble();
  }

  static double _durationInterval(List<LabelDurationStats> stats) {
    final maxMinutes = _maxMinutes(stats);
    if (maxMinutes <= 30) {
      return 10;
    }
    return (maxMinutes / 4).ceilToDouble();
  }

  static String _shortLabel(TaskLabel label) {
    final text = _labelText(label);
    if (text.length <= 4) {
      return text;
    }
    return '${text.substring(0, 4)}...';
  }
}

// Simple list of habit streak values.
class _HabitStreaksList extends StatelessWidget {
  final List<Habit> habits;

  const _HabitStreaksList({required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (habits.isEmpty) {
      return Text('No habits yet.', style: theme.textTheme.bodyMedium);
    }

    return Column(
      children: [
        for (final habit in habits)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(habit.title, style: theme.textTheme.bodyMedium),
                ),
                Text(
                  '${habit.currentStreak} days',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Legend chip for chart colors.
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

List<Color> _chartColors(ThemeData theme) {
  return [
    theme.colorScheme.primary,
    theme.colorScheme.secondary,
    theme.colorScheme.tertiary,
    theme.colorScheme.error,
    theme.colorScheme.primaryContainer,
    theme.colorScheme.secondaryContainer,
  ];
}

String _labelText(TaskLabel label) {
  final raw = label.name.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (match) => '${match.group(1)} ${match.group(2)}',
  );
  return '${raw[0].toUpperCase()}${raw.substring(1)}';
}
