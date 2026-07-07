import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/core/utils.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/task_template.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';
import 'package:youmi_dev/style/common_widgets.dart';
import 'package:youmi_dev/style/label_style.dart';
import 'package:youmi_dev/style/paper_widgets.dart';
import 'package:uuid/uuid.dart';

part 'dashboard_widgets.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const DashboardView({super.key, this.onOpenSettings});

  @override
  State<DashboardView> createState() {
    return _DashboardViewState();
  }
}

class _DashboardViewState extends State<DashboardView> {
  final List<String> _completedHabitIds = [];
  bool _showHabitManager = false;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (user != null) {
      await Provider.of<BlueprintProvider>(
        context,
        listen: false,
      ).loadForUser(user.id);
    }
    if (!mounted) {
      return;
    }
    await Provider.of<ExecutionProvider>(
      context,
      listen: false,
    ).fetchMonthData(DateTime.now());
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

  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 5) {
      return 'Good night';
    }
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String _titleFor(ActivityInstance ai, BlueprintProvider blueprint) {
    if (ai.taskTemplateId != null) {
      final TaskTemplate? template = blueprint.templateById(ai.taskTemplateId!);
      if (template != null) {
        return template.title;
      }
      return 'Unnamed';
    }
    if (ai.habitId != null) {
      final Habit? habit = blueprint.habitById(ai.habitId!);
      if (habit != null) {
        return habit.title;
      }
      return 'Unnamed';
    }
    return 'Unnamed';
  }

  TaskTemplate? _templateFor(ActivityInstance ai, BlueprintProvider blueprint) {
    if (ai.taskTemplateId == null) {
      return null;
    }
    return blueprint.templateById(ai.taskTemplateId!);
  }

  void _toggleTask(ActivityInstance ai) {
    ActivityStatus nextStatus = ActivityStatus.success;
    if (ai.status == ActivityStatus.success) {
      nextStatus = ActivityStatus.pending;
    }
    Provider.of<ExecutionProvider>(
      context,
      listen: false,
    ).updateItemStatus(ai.id, nextStatus);
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

  String _newId() {
    return _uuid.v4();
  }

  Future<void> _openNewHabitDialog() async {
    final controller = TextEditingController();
    final String? title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Habit'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (title == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    String? userId;
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (user != null) {
      userId = user.id;
    }
    if (userId == null) {
      _showMessage('Please sign in again.');
      return;
    }
    String titleValue = title;
    if (titleValue.isEmpty) {
      titleValue = 'Untitled';
    }
    final habit = Habit(
      id: _newId(),
      userId: userId,
      title: titleValue,
      label: TaskLabel.health,
      recurrenceMask: 0,
      currentStreak: 0,
    );
    try {
      await Provider.of<BlueprintProvider>(
        context,
        listen: false,
      ).saveHabit(habit);
      if (!mounted) {
        return;
      }
      _showMessage('Habit added');
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showMessage('Could not add habit: $e');
    }
  }

  Future<void> _openHabitSettingsDialog(Habit habit) async {
    final titleController = TextEditingController(text: habit.title);
    TaskLabel selectedLabel = habit.label;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Habit Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskLabel>(
                    initialValue: selectedLabel,
                    decoration: const InputDecoration(labelText: 'Label'),
                    items: TaskLabel.values.map((label) {
                      final style = labelStyleFor(
                        label,
                        Theme.of(dialogContext).colorScheme,
                      );
                      return DropdownMenuItem(
                        value: label,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(style.icon, size: 16, color: style.color),
                            const SizedBox(width: 8),
                            Text(style.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedLabel = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    String newTitle = titleController.text.trim();
                    if (newTitle.isEmpty) {
                      newTitle = habit.title;
                    }
                    final updated = Habit(
                      id: habit.id,
                      userId: habit.userId,
                      title: newTitle,
                      label: selectedLabel,
                      recurrenceMask: habit.recurrenceMask,
                      currentStreak: habit.currentStreak,
                    );
                    try {
                      await Provider.of<BlueprintProvider>(
                        context,
                        listen: false,
                      ).saveHabit(updated);
                    } catch (e) {
                      _showMessage(e.toString());
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _habitRecurrenceLabel(Habit habit) {
    return formatRecurrenceMask(habit.recurrenceMask);
  }

  String _formatTime(DateTime dt) {
    final int hour = dt.hour;
    String minute = '${dt.minute}';
    if (dt.minute < 10) {
      minute = '0${dt.minute}';
    }
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
    }
    int displayHour = hour % 12;
    if (displayHour == 0) {
      displayHour = 12;
    }
    return '$displayHour:$minute $period';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) {
      return '';
    }
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min';
    }
    final int hours = duration.inHours;
    final int mins = duration.inMinutes.remainder(60);
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}min';
  }

  int _bestStreak() {
    int best = 0;
    final habits = Provider.of<BlueprintProvider>(
      context,
      listen: false,
    ).habits;
    for (final habit in habits) {
      if (habit.currentStreak > best) {
        best = habit.currentStreak;
      }
    }
    return best;
  }

  List<ActivityInstance> _todaysInstances(
    DateTime today,
    List<ActivityInstance> items,
  ) {
    List<ActivityInstance> todays = [];
    for (int i = 0; i < items.length; i++) {
      final inst = items[i];
      if (inst.scheduledDate.year == today.year &&
          inst.scheduledDate.month == today.month &&
          inst.scheduledDate.day == today.day) {
        todays.add(inst);
      }
    }
    todays.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
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
    BlueprintProvider blueprint,
  ) {
    final execution = Provider.of<ExecutionProvider>(context, listen: false);
    List<Widget> children = [];
    if (blueprint.lastError != null || execution.lastError != null) {
      String message = blueprint.lastError ?? execution.lastError ?? 'Unknown error';
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: ErrorBanner(
            message: message,
            onRetry: _refresh,
          ),
        ),
      );
    }
    children.add(_buildHeader(today, completed, total, percent, _bestStreak()));
    children.add(const SizedBox(height: 8));
    children.add(_buildUpcomingTasks(todays, blueprint));
    children.add(const SizedBox(height: 8));
    children.add(_buildHabitsSection(blueprint));
    children.add(const SizedBox(height: 12));

    return RefreshIndicator(
      onRefresh: _refresh,
      child: RuledPage(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: children),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final execution = Provider.of<ExecutionProvider>(context);
    final blueprint = Provider.of<BlueprintProvider>(context);
    final DateTime today = DateTime.now();
    final List<ActivityInstance> todays = _todaysInstances(
      today,
      execution.items,
    );
    final int total = todays.length;
    final int completed = _completedCount(todays);
    int percent = 0;
    if (total != 0) {
      percent = (completed / total * 100).toInt();
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _buildBody(today, todays, completed, total, percent, blueprint),
      ),
    );
  }
}