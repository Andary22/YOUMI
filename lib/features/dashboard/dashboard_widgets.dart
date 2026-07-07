part of 'dashboard.dart';

extension _DashboardWidgets on _DashboardViewState {
  Widget _buildHeader(
    DateTime today,
    int completed,
    int total,
    int percent,
    int bestStreak,
  ) {
    final theme = Theme.of(context);
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    String name = '';
    if (user != null && user.name.trim().isNotEmpty) {
      name = user.name.trim().split(' ').first;
    }
    String greetingLine = _greeting();
    if (name.isNotEmpty) {
      greetingLine = '$greetingLine, $name';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingLine,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        height: 1.05,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_weekdayName(today.weekday)}, ${_monthName(today.month)} ${today.day}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: widget.onOpenSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProgressRing(
                progress: total == 0 ? 0 : completed / total,
                centerValue: '$percent%',
                centerLabel: 'today',
                size: 128,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SidePill(
                      icon: Icons.task_alt_rounded,
                      color: theme.colorScheme.primary,
                      value: '$completed/$total',
                      label: 'Tasks done today',
                    ),
                    const SizedBox(height: 10),
                    _SidePill(
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFE0665C),
                      value: '$bestStreak',
                      label: 'Best streak',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasks(
    List<ActivityInstance> todays,
    BlueprintProvider blueprint,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Tasks", style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (todays.isEmpty)
            const EmptyState(
              icon: Icons.wb_sunny_outlined,
              title: 'Nothing scheduled today',
              message: 'Add tasks from the Planner tab to see them here.',
            )
          else
            _buildTaskList(todays, blueprint),
        ],
      ),
    );
  }

  Widget _buildHabitsSection(BlueprintProvider blueprint) {
    final theme = Theme.of(context);
    String sectionTitle = "Today's Habits";
    if (_showHabitManager) {
      sectionTitle = 'Habits';
    }

    Widget sectionAction;
    if (_showHabitManager) {
      sectionAction = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              _setShowHabitManager(false);
            },
            child: const Text('Back'),
          ),
          const SizedBox(width: 4),
          FilledButton.tonalIcon(
            onPressed: () {
              _openNewHabitDialog();
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('New'),
          ),
        ],
      );
    } else {
      sectionAction = TextButton(
        onPressed: () {
          _setShowHabitManager(true);
        },
        child: const Text('Manage'),
      );
    }

    Widget habitsContent;
    if (_showHabitManager) {
      habitsContent = _buildHabitManagerList(blueprint);
    } else if (blueprint.habits.isEmpty) {
      habitsContent = const EmptyState(
        icon: Icons.self_improvement_rounded,
        title: 'No habits yet',
        message: 'Tap Manage to create your first daily habit.',
      );
    } else {
      habitsContent = _buildTodayHabitsList(blueprint);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionTitle, style: theme.textTheme.titleMedium),
              sectionAction,
            ],
          ),
          const SizedBox(height: 12),
          habitsContent,
        ],
      ),
    );
  }

  Widget _buildTaskSubtitleRow(
    ActivityInstance instance,
    Duration? duration,
    TaskLabel? label,
  ) {
    final theme = Theme.of(context);
    List<Widget> rowItems = [];
    rowItems.add(
      Icon(Icons.schedule, size: 13, color: theme.colorScheme.onSurfaceVariant),
    );
    rowItems.add(const SizedBox(width: 4));
    rowItems.add(
      Text(
        _formatTime(instance.scheduledDate),
        style: theme.textTheme.bodySmall,
      ),
    );
    if (duration != null) {
      rowItems.add(const SizedBox(width: 8));
      rowItems.add(Text('•', style: theme.textTheme.bodySmall));
      rowItems.add(const SizedBox(width: 8));
      rowItems.add(
        Text(_formatDuration(duration), style: theme.textTheme.bodySmall),
      );
    }
    if (label != null) {
      rowItems.add(const SizedBox(width: 8));
      rowItems.add(TabChip(label: label, dense: true));
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: rowItems,
    );
  }

  Widget _buildTaskList(
    List<ActivityInstance> todays,
    BlueprintProvider blueprint,
  ) {
    List<Widget> cards = [];
    for (int i = 0; i < todays.length; i++) {
      final instance = todays[i];
      final TaskTemplate? template = _templateFor(instance, blueprint);
      final bool done = instance.status == ActivityStatus.success;
      TaskLabel? label = instance.label;
      Duration? duration;
      if (template != null) {
        label ??= template.label;
        duration = template.expectedDuration;
      }
      cards.add(
        _CheckableCard(
          checked: done,
          onPressed: () {
            _toggleTask(instance);
          },
          title: _titleFor(instance, blueprint),
          subtitle: _buildTaskSubtitleRow(instance, duration, label),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
  }

  Widget _buildTodayHabitsList(BlueprintProvider blueprint) {
    final theme = Theme.of(context);
    List<Widget> cards = [];
    final habits = blueprint.habits;
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      cards.add(
        _CheckableCard(
          checked: _completedHabitIds.contains(habit.id),
          onPressed: () {
            _toggleHabit(habit.id);
          },
          title: habit.title,
          titleGap: 4,
          subtitle: Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${habit.currentStreak} day streak',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              TabChip(label: habit.label, dense: true),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
  }

  Widget _buildHabitManagerList(BlueprintProvider blueprint) {
    final theme = Theme.of(context);
    List<Widget> items = [];
    final habits = blueprint.habits;
    if (habits.isEmpty) {
      items.add(
        const EmptyState(
          icon: Icons.self_improvement_rounded,
          title: 'No habits yet',
          message: 'Tap New to build your first daily habit.',
        ),
      );
    }
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      items.add(
        Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          TabChip(label: habit.label, dense: true),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_habitRecurrenceLabel(habit)}  •  ${habit.currentStreak}d streak',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _openHabitSettingsDialog(habit);
                  },
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        ),
      );
    }
    items.add(const SizedBox(height: 4));
    items.add(
      Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text('How Habits Work', style: theme.textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• Habits are automatically added to your daily plan\n'
                '• Build streaks by completing them consistently\n'
                '• Choose which days they repeat on',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}

class _CheckableCard extends StatelessWidget {
  final bool checked;
  final void Function() onPressed;
  final String title;
  final Widget subtitle;
  final double titleGap;

  const _CheckableCard({
    required this.checked,
    required this.onPressed,
    required this.title,
    required this.subtitle,
    this.titleGap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StampCheckbox(checked: checked, onTap: onPressed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: checked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: checked
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: titleGap),
                    subtitle,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidePill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _SidePill({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: theme.textTheme.titleMedium),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
