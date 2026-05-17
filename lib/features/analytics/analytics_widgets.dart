part of 'analytics.dart';

extension _AnalyticsWidgets on AnalyticsView {
  Widget _section(BuildContext context, String title, Widget content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AnalyticsProvider analytics) {
    List<DropdownMenuItem<TaskLabel?>> labelItems = [];
    labelItems.add(
      const DropdownMenuItem(value: null, child: Text('All labels')),
    );
    for (int i = 0; i < TaskLabel.values.length; i++) {
      final label = TaskLabel.values[i];
      labelItems.add(
        DropdownMenuItem(value: label, child: Text(_formatLabel(label))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          label: Text(_formatRange(analytics.range)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<TaskLabel?>(
            initialValue: analytics.labelFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Label',
              isDense: true,
            ),
            items: labelItems,
            onChanged: analytics.setLabelFilter,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionChart(ThemeData theme, List<LabelCount> counts) {
    int total = 0;
    int maxCount = 1;
    for (int i = 0; i < counts.length; i++) {
      total = total + counts[i].count;
      if (counts[i].count > maxCount) {
        maxCount = counts[i].count;
      }
    }
    if (counts.isEmpty || total == 0) {
      return Text('No data', style: theme.textTheme.bodyMedium);
    }

    final colors = _chartColors(theme);
    List<Widget> bars = [];
    List<Widget> labels = [];
    for (int i = 0; i < counts.length; i++) {
      bars.add(
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: (counts[i].count / maxCount) * 100,
                width: double.infinity,
                color: colors[i % colors.length],
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              const SizedBox(height: 8),
              Text(
                _formatLabel(counts[i].label),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      if (counts[i].count > 0) {
        labels.add(
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors[i % colors.length].withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_formatLabel(counts[i].label)}: ${counts[i].count} (${((counts[i].count / total) * 100).round()}%)',
              style: theme.textTheme.bodySmall,
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bars,
          ),
        ),
        const SizedBox(height: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: labels),
      ],
    );
  }

  Widget _buildDurationChart(ThemeData theme, List<LabelDurationStats> stats) {
    if (stats.isEmpty) {
      return Text('No data', style: theme.textTheme.bodyMedium);
    }

    int maxMin = 1;
    for (int i = 0; i < stats.length; i++) {
      final expected = stats[i].expectedAverage.inMinutes;
      final actual = stats[i].actualAverage.inMinutes;
      maxMin = math.max(maxMin, math.max(expected, actual));
    }

    List<Widget> rows = [];
    for (int i = 0; i < stats.length; i++) {
      final item = stats[i];
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _formatLabel(item.label),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _durationBar(
                      theme,
                      'Exp',
                      item.expectedAverage.inMinutes,
                      maxMin,
                      theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 4),
                    _durationBar(
                      theme,
                      'Act',
                      item.actualAverage.inMinutes,
                      maxMin,
                      theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _durationBar(
    ThemeData theme,
    String label,
    int value,
    int max,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(label, style: theme.textTheme.labelSmall),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 20,
                    width: 100 * (value / max),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('${value}m', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsStreak(ThemeData theme, List<Habit> habits) {
    if (habits.isEmpty) {
      return Text('No habits', style: theme.textTheme.bodyMedium);
    }
    List<Widget> rows = [];
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(habit.title)),
              Text(
                '${habit.currentStreak} days',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildExecutionLog(
    BuildContext context,
    ThemeData theme,
    BlueprintProvider blueprint,
    List<ActivityInstance> items,
  ) {
    if (items.isEmpty) {
      return Text('No completed tasks', style: theme.textTheme.bodyMedium);
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, i) {
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
            title = 'Activity';
          }
        }

        String note = 'No note';
        if (item.note != null) {
          note = item.note!;
        }

        return ListTile(
          dense: true,
          title: Text(title),
          subtitle: Text(
            '${_formatDate(item.scheduledDate)} | $note',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        );
      },
    );
  }

  String _formatRange(DateTimeRange range) {
    return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatLabel(TaskLabel label) {
    return label.name[0].toUpperCase() + label.name.substring(1);
  }

  List<Color> _chartColors(ThemeData theme) {
    return [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
    ];
  }
}
