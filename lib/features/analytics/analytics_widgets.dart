part of 'analytics.dart';

extension _AnalyticsWidgets on AnalyticsView {
  Widget _buildRangeAndFilterRow(
    BuildContext context,
    AnalyticsProvider analytics,
  ) {
    final theme = Theme.of(context);
    List<Widget> chips = [];
    chips.add(
      ChoiceChip(
        label: const Text('All'),
        selected: analytics.labelFilter == null,
        onSelected: (_) {
          analytics.setLabelFilter(null);
        },
      ),
    );
    for (int i = 0; i < TaskLabel.values.length; i++) {
      final label = TaskLabel.values[i];
      final style = labelStyleFor(label, theme.colorScheme);
      chips.add(
        ChoiceChip(
          label: Text(_labelText(label)),
          avatar: Icon(style.icon, size: 15),
          selected: analytics.labelFilter == label,
          onSelected: (_) {
            analytics.setLabelFilter(label);
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            _pickRange(context);
          },
          icon: const Icon(Icons.date_range_outlined, size: 18),
          label: Text(_formatRange(analytics.range)),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, AnalyticsProvider analytics) {
    final theme = Theme.of(context);
    final overall = analytics.overallDurationStats;
    final int completed = analytics.completedItems.length;

    String accuracyLabel = 'No timing data yet';
    double? accuracyRatio;
    if (overall.sampleCount > 0 && overall.expectedAverage.inSeconds > 0) {
      accuracyRatio =
          overall.actualAverage.inSeconds / overall.expectedAverage.inSeconds;
      final int percent = (accuracyRatio * 100).round();
      accuracyLabel = '$percent% of planned time';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            ProgressRing(
              progress: accuracyRatio == null ? 0 : accuracyRatio.clamp(0, 1.4) / 1.4,
              centerValue: '$completed',
              centerLabel: 'completed',
              size: 108,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time accuracy', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    accuracyLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Planned avg: ${_formatDuration(overall.expectedAverage)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Actual avg: ${_formatDuration(overall.actualAverage)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, AnalyticsProvider analytics) {
    final theme = Theme.of(context);
    final counts = analytics.completionCountsByLabel;
    int total = 0;
    int maxCount = 1;
    for (int i = 0; i < counts.length; i++) {
      total += counts[i].count;
      if (counts[i].count > maxCount) {
        maxCount = counts[i].count;
      }
    }

    Widget content;
    if (total == 0) {
      content = const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'No completions yet',
        message: 'Finish tasks and habits to see your breakdown here.',
      );
    } else {
      List<Widget> rows = [];
      for (int i = 0; i < counts.length; i++) {
        final item = counts[i];
        final style = labelStyleFor(item.label, theme.colorScheme);
        final double fraction = item.count / maxCount;
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: TabChip(label: item.label, dense: true),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: fraction.clamp(0.03, 1.0),
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: style.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.count}',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      content = Column(children: rows);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completed by label', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard(BuildContext context, AnalyticsProvider analytics) {
    final theme = Theme.of(context);
    final stats = analytics.durationStatsByLabel;

    Widget content;
    if (stats.isEmpty) {
      content = const EmptyState(
        icon: Icons.timer_outlined,
        title: 'No timing data yet',
        message: 'Complete tasks with expected durations to compare here.',
      );
    } else {
      int maxMinutes = 1;
      for (int i = 0; i < stats.length; i++) {
        final expected = stats[i].expectedAverage.inMinutes;
        final actual = stats[i].actualAverage.inMinutes;
        if (expected > maxMinutes) maxMinutes = expected;
        if (actual > maxMinutes) maxMinutes = actual;
      }
      List<Widget> rows = [];
      for (int i = 0; i < stats.length; i++) {
        final stat = stats[i];
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabChip(label: stat.label, dense: true),
                const SizedBox(height: 8),
                _durationBar(
                  theme,
                  'Planned',
                  stat.expectedAverage.inMinutes,
                  maxMinutes,
                  theme.colorScheme.secondary,
                ),
                const SizedBox(height: 4),
                _durationBar(
                  theme,
                  'Actual',
                  stat.actualAverage.inMinutes,
                  maxMinutes,
                  theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      }
      content = Column(children: rows);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Planned vs. actual time', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _durationBar(
    ThemeData theme,
    String label,
    int minutes,
    int maxMinutes,
    Color color,
  ) {
    final double fraction = maxMinutes == 0 ? 0 : minutes / maxMinutes;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: theme.textTheme.labelSmall),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.02, 1.0),
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${minutes}m',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildExecutionLog(BuildContext context, AnalyticsProvider analytics) {
    final theme = Theme.of(context);
    final blueprint = Provider.of<BlueprintProvider>(context, listen: false);
    final items = analytics.completedItems;

    Widget content;
    if (items.isEmpty) {
      content = const EmptyState(
        icon: Icons.history_rounded,
        title: 'Nothing completed in this range',
        message: 'Completed tasks and habits will show up here.',
      );
    } else {
      List<Widget> rows = [];
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        String title = 'Activity';
        if (item.taskTemplateId != null) {
          final template = blueprint.templateById(item.taskTemplateId!);
          if (template != null) {
            title = template.title;
          } else {
            title = 'Task';
          }
        } else if (item.habitId != null) {
          final habit = blueprint.habitById(item.habitId!);
          if (habit != null) {
            title = habit.title;
          } else {
            title = 'Habit';
          }
        }
        String note = '';
        if (item.note != null && item.note!.trim().isNotEmpty) {
          note = item.note!.trim();
        }
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodyMedium),
                      if (note.isNotEmpty)
                        Text(
                          note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatItemDate(item.scheduledDate),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
        if (i != items.length - 1) {
          rows.add(Divider(color: theme.colorScheme.outline, height: 1));
        }
      }
      content = Column(children: rows);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity log', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }
}