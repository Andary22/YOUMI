  import 'package:flutter/material.dart';
import 'package:youmi_dev/features/settings/settings.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/task_template.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final List<ActivityInstance> _instances;
  final Set<String> _completedHabitIds = <String>{};
  bool _showHabitManager = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _instances = MockData.activityInstances.map((source) {
      final scheduled = source.scheduledDate;
      return ActivityInstance(
        id: source.id,
        userId: source.userId,
        taskTemplateId: source.taskTemplateId,
        habitId: source.habitId,
        scheduledDate: DateTime(
          now.year,
          now.month,
          now.day,
          scheduled.hour,
          scheduled.minute,
        ),
        status: source.status,
        actualDuration: source.actualDuration,
        note: source.note,
        subTaskStates: source.subTaskStates,
      );
    }).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[weekday - 1];
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  String _titleFor(ActivityInstance ai) {
    if (ai.taskTemplateId != null) {
      return MockData.taskTemplates
          .firstWhere(
            (t) => t.id == ai.taskTemplateId,
            orElse: () => MockData.taskTemplates.first,
          )
          .title;
    }
    if (ai.habitId != null) {
      return MockData.habits
          .firstWhere(
            (h) => h.id == ai.habitId,
            orElse: () => MockData.habits.first,
          )
          .title;
    }
    return 'Unnamed';
  }

  TaskTemplate? _templateFor(ActivityInstance ai) {
    if (ai.taskTemplateId == null) return null;
    try {
      return MockData.taskTemplates.firstWhere(
        (t) => t.id == ai.taskTemplateId,
      );
    } catch (_) {
      return null;
    }
  }

  void _toggleTask(ActivityInstance ai) {
    final index = _instances.indexWhere((item) => item.id == ai.id);
    if (index < 0) return;
    final nextStatus = ai.status == ActivityStatus.success
        ? ActivityStatus.pending
        : ActivityStatus.success;
    setState(() {
      _instances[index] = ActivityInstance(
        id: ai.id,
        userId: ai.userId,
        taskTemplateId: ai.taskTemplateId,
        habitId: ai.habitId,
        scheduledDate: ai.scheduledDate,
        status: nextStatus,
        actualDuration: ai.actualDuration,
        note: ai.note,
        subTaskStates: ai.subTaskStates,
      );
    });
  }

  void _toggleHabit(String habitId) {
    setState(() {
      if (_completedHabitIds.contains(habitId)) {
        _completedHabitIds.remove(habitId);
      } else {
        _completedHabitIds.add(habitId);
      }
    });
  }

  String _habitRecurrenceLabel(Habit habit) {
    if (habit.recurrenceMask == 0 || habit.recurrenceMask == 0x1F) {
      return 'Daily';
    }
    return 'Mon, Wed, Fri';
  }

  String _habitTimeLabel(Habit habit) {
    return '9:00 AM';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    if (duration.inMinutes < 60) return '${duration.inMinutes} min';
    final hours = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return mins == 0 ? '${hours}h' : '${hours}h ${mins}min';
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todays =
        _instances
            .where(
              (i) =>
                  i.scheduledDate.year == today.year &&
                  i.scheduledDate.month == today.month &&
                  i.scheduledDate.day == today.day,
            )
            .toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    final total = todays.length;
    final completed = todays
        .where((i) => i.status == ActivityStatus.success)
        .length;
    final percent = total == 0 ? 0 : (completed / total * 100).toInt();
    final bestStreak = MockData.habits
        .map((h) => h.currentStreak)
        .fold<int>(0, (prev, cur) => prev > cur ? prev : cur);

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsView(),
                          ),
                        ),
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
                        child: _StatCard(
                          label: 'Best Streak',
                          value: bestStreak.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Upcoming Tasks'),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Plan Day'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...todays.map((instance) {
                    final template = _templateFor(instance);
                    final done = instance.status == ActivityStatus.success;
                    final labelName = template?.label.name ?? '';
                    final duration = template?.expectedDuration;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleTask(instance),
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 2),
                              ),
                              child: done
                                  ? const Icon(Icons.check, size: 15)
                                  : const SizedBox.shrink(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_titleFor(instance)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 13),
                                    const SizedBox(width: 4),
                                    Text(_formatTime(instance.scheduledDate)),
                                    if (duration != null) ...[
                                      const SizedBox(width: 6),
                                      Text(_formatDuration(duration)),
                                    ],
                                    if (labelName.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        child: Text(labelName),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_showHabitManager ? 'Habits' : "Today's Habits"),
                      if (_showHabitManager)
                        Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _showHabitManager = false),
                              child: const Text('Back'),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('New'),
                            ),
                          ],
                        )
                      else
                        TextButton(
                          onPressed: () =>
                              setState(() => _showHabitManager = true),
                          child: const Text('Manage'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!_showHabitManager)
                    ...MockData.habits.map((habit) {
                      final done = _completedHabitIds.contains(habit.id);
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleHabit(habit.id),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 2),
                                ),
                                child: done
                                    ? const Icon(Icons.check, size: 15)
                                    : const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(habit.title),
                                  const SizedBox(height: 4),
                                  Text('${habit.currentStreak} day streak'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (_showHabitManager) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('Build consistency with daily habits'),
                    ),
                    ...MockData.habits.map((habit) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
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
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.settings),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('How Habits Work'),
                            SizedBox(height: 8),
                            Text(
                              '• Habits are automatically added to your daily plan',
                            ),
                            Text(
                              '• Build streaks by completing them consistently',
                            ),
                            Text('• Get reminded at your chosen time'),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text(value), const SizedBox(height: 6), Text(label)],
        ),
      ),
    );
  }
}
