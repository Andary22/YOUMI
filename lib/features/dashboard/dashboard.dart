import 'package:flutter/material.dart';
import 'package:youmi_dev/features/settings/settings.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/task_template.dart';

part 'dashboard_widgets.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() {
    return _DashboardViewState();
  }
}

class _DashboardViewState extends State<DashboardView> {
  final List<String> _completedHabitIds = [];
  bool _showHabitManager = false;
  List<ActivityInstance> _instances = [];
  bool _instancesLoaded = false;

  void _loadInstances() {
    if (_instancesLoaded) return;
    final now = DateTime.now();
    List<ActivityInstance> loadedInstances = [];

    for (int i = 0; i < MockData.activityInstances.length; i++) {
      final source = MockData.activityInstances[i];
      final scheduled = source.scheduledDate;
      loadedInstances.add(
        ActivityInstance(
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
        ),
      );
    }

    loadedInstances.sort((first, second) {
      return first.scheduledDate.compareTo(second.scheduledDate);
    });

    _instances = loadedInstances;
    _instancesLoaded = true;
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
    for (final template in MockData.taskTemplates) {
      if (template.id == ai.taskTemplateId) {
        return template.title;
      }
    }
    for (final habit in MockData.habits) {
      if (habit.id == ai.habitId) {
        return habit.title;
      }
    }
    return 'Unnamed';
  }

  TaskTemplate? _templateFor(ActivityInstance ai) {
    for (final template in MockData.taskTemplates) {
      if (template.id == ai.taskTemplateId) {
        return template;
      }
    }
    return null;
  }

  void _toggleTask(ActivityInstance ai) {
    int index = -1;
    for (int i = 0; i < _instances.length; i++) {
      if (_instances[i].id == ai.id) {
        index = i;
        break;
      }
    }
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

  void _setShowHabitManager(bool value) {
    setState(() {
      _showHabitManager = value;
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
    final int hour = dt.hour;
    final String minute = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    if (duration.inMinutes < 60) return '${duration.inMinutes} min';
    final int hours = duration.inHours;
    final int mins = duration.inMinutes.remainder(60);
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}min';
  }

  int _bestStreak() {
    int best = 0;
    for (final habit in MockData.habits) {
      if (habit.currentStreak > best) {
        best = habit.currentStreak;
      }
    }
    return best;
  }

  List<ActivityInstance> _todaysInstances(DateTime today) {
    List<ActivityInstance> todays = [];
    for (int i = 0; i < _instances.length; i++) {
      final inst = _instances[i];
      if (inst.scheduledDate.year == today.year &&
          inst.scheduledDate.month == today.month &&
          inst.scheduledDate.day == today.day) {
        todays.add(inst);
      }
    }
    return todays;
  }

  int _completedCount(List<ActivityInstance> todays) {
    int completed = 0;
    for (int i = 0; i < todays.length; i++) {
      if (todays[i].status == ActivityStatus.success) {
        completed++;
      }
    }
    return completed;
  }

  Widget _buildBody(
    DateTime today,
    List<ActivityInstance> todays,
    int completed,
    int total,
    int percent,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(today, completed, total, percent, _bestStreak()),
          const SizedBox(height: 20),
          _buildUpcomingTasks(todays),
          const SizedBox(height: 8),
          _buildHabitsSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadInstances();
    final DateTime today = DateTime.now();
    final List<ActivityInstance> todays = _todaysInstances(today);
    final int total = todays.length;
    final int completed = _completedCount(todays);
    final int percent = total == 0 ? 0 : (completed / total * 100).toInt();

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: _buildBody(today, todays, completed, total, percent),
    );
  }
}
