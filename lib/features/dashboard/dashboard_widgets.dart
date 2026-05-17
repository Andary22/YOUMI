part of 'dashboard.dart';

extension _DashboardWidgets on _DashboardViewState {
  Widget _buildHeader(
    DateTime today,
    int completed,
    int total,
    int percent,
    int bestStreak,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YOUMI'),
                    const SizedBox(height: 4),
                    Text(
                      '${_weekdayName(today.weekday)}, ${_monthName(today.month)} ${today.day}, ${today.year}',
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const SettingsView();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Tasks Done',
                  value: '$completed/$total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(label: 'Complete', value: '$percent%'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(label: 'Best Streak', value: '$bestStreak'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasks(List<ActivityInstance> todays) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Tasks'),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Plan Day'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTaskList(todays),
        ],
      ),
    );
  }

  Widget _buildHabitsSection() {
    String sectionTitle = "Today's Habits";
    if (_showHabitManager) {
      sectionTitle = 'Habits';
    }

    Widget sectionAction;
    if (_showHabitManager) {
      sectionAction = Row(
        children: [
          TextButton(
            onPressed: () {
              _setShowHabitManager(false);
            },
            child: const Text('Back'),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () {},
            child: Row(
              children: const [
                Icon(Icons.add, size: 16),
                SizedBox(width: 4),
                Text('New'),
              ],
            ),
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
      habitsContent = _buildHabitManagerList();
    } else {
      habitsContent = _buildTodayHabitsList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(sectionTitle), sectionAction],
          ),
          const SizedBox(height: 8),
          habitsContent,
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTaskSubtitleRow(
    ActivityInstance instance,
    Duration? duration,
    String labelName,
  ) {
    List<Widget> rowItems = [];
    rowItems.add(const Icon(Icons.schedule, size: 13));
    rowItems.add(const SizedBox(width: 4));
    rowItems.add(Text(_formatTime(instance.scheduledDate)));
    if (duration != null) {
      rowItems.add(const SizedBox(width: 6));
      rowItems.add(Text(_formatDuration(duration)));
    }
    if (labelName != '') {
      rowItems.add(const SizedBox(width: 8));
      rowItems.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(labelName),
        ),
      );
    }
    return Row(children: rowItems);
  }

  Widget _buildTaskList(List<ActivityInstance> todays) {
    List<Widget> cards = [];
    for (int i = 0; i < todays.length; i++) {
      final instance = todays[i];
      final TaskTemplate? template = _templateFor(instance);
      final bool done = instance.status == ActivityStatus.success;
      String labelName = '';
      Duration? duration;
      if (template != null) {
        labelName = template.label.name;
        duration = template.expectedDuration;
      }
      cards.add(
        _CheckableCard(
          checked: done,
          onPressed: () {
            _toggleTask(instance);
          },
          title: _titleFor(instance),
          subtitle: _buildTaskSubtitleRow(instance, duration, labelName),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
  }

  Widget _buildTodayHabitsList() {
    List<Widget> cards = [];
    for (int i = 0; i < MockData.habits.length; i++) {
      final habit = MockData.habits[i];
      cards.add(
        _CheckableCard(
          checked: _completedHabitIds.contains(habit.id),
          onPressed: () {
            _toggleHabit(habit.id);
          },
          title: habit.title,
          titleGap: 4,
          subtitle: Text('${habit.currentStreak} day streak'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
  }

  Widget _buildHabitManagerList() {
    List<Widget> items = [
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('Build consistency with daily habits'),
      ),
    ];
    for (int i = 0; i < MockData.habits.length; i++) {
      final habit = MockData.habits[i];
      items.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title),
                    const SizedBox(height: 4),
                    Text(
                      '${_habitRecurrenceLabel(habit)}  •  ${_habitTimeLabel(habit)}',
                    ),
                    const SizedBox(height: 4),
                    Text('${habit.currentStreak} day streak'),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
            ],
          ),
        ),
      );
    }
    items.add(const SizedBox(height: 12));
    items.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('How Habits Work'),
              SizedBox(height: 8),
              Text('• Habits are automatically added to your daily plan'),
              Text('• Build streaks by completing them consistently'),
              Text('• Get reminded at your chosen time'),
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
    this.titleGap = 5,
  });

  @override
  Widget build(BuildContext context) {
    Widget checkIcon = const SizedBox(width: 0, height: 0);
    if (checked) {
      checkIcon = const Icon(Icons.check, size: 15);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(26, 26),
            ),
            onPressed: onPressed,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: checkIcon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                SizedBox(height: titleGap),
                subtitle,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    List<Widget> statChildren = [];
    statChildren.add(Text(value));
    statChildren.add(const SizedBox(height: 6));
    statChildren.add(Text(label));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: statChildren,
        ),
      ),
    );
  }
}
