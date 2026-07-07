import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';
import 'package:youmi_dev/style/common_widgets.dart';
import 'package:youmi_dev/style/label_style.dart';
import 'package:youmi_dev/style/paper_widgets.dart';

part 'planner_widgets.dart';
part 'planner_edit_pages.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() {
    return _PlannerViewState();
  }
}

class _PlannerViewState extends State<PlannerView> {
  static const int _demoMonthRange = 6;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExecutionProvider>(context, listen: false).fetchMonthData(
        _focusedDay,
        monthsBefore: _monthsBefore,
        monthsAfter: _monthsAfter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final execution = Provider.of<ExecutionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Planner'), centerTitle: false),
      body: execution.lastError != null
          ? RuledPage(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ErrorBanner(
                    message: execution.lastError!,
                    onRetry: () {
                      execution.fetchMonthData(
                        _focusedDay,
                        monthsBefore: _monthsBefore,
                        monthsAfter: _monthsAfter,
                      );
                    },
                  ),
                  _buildCalendarCard(theme, execution),
                ],
              ),
            )
          : _buildScheduleTab(theme, execution),
    );
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  void _selectCalendarDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      _focusedDay = DateTime(day.year, day.month, day.day);
    });
  }

  Future<void> _openQuickAddPage(DateTime date) async {
    final blueprint = Provider.of<BlueprintProvider>(context, listen: false);
    final execution = Provider.of<ExecutionProvider>(context, listen: false);
    String? userId;
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;

    if (user != null) {
      userId = user.id;
    }
    if (userId == null) {
      _showAddFeedback(context, 'Sign in to add items');
      return;
    }
    final String resolvedUserId = userId;

    final result = await Navigator.push<_QuickAddResult>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _QuickAddPage(
            templates: blueprint.templates,
            habits: blueprint.habits,
            labelText: _labelText,
          );
        },
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    ActivityInstance? newItem;

    if (result.type == 'template' && result.template != null) {
      final template = result.template!;
      Map<String, bool> subTaskStates = {};
      for (int i = 0; i < template.subTasks.length; i++) {
        final subTask = template.subTasks[i];
        subTaskStates[subTask.id] = false;
      }

      newItem = ActivityInstance(
        id: _newId(),
        userId: resolvedUserId,
        taskTemplateId: template.id,
        label: template.label,
        scheduledDate: DateTime(date.year, date.month, date.day, 9, 0),
        status: ActivityStatus.pending,
        note: null,
        subTaskStates: subTaskStates,
      );

      newItem = await execution.addItem(newItem);
      _showAddFeedback(context, 'Added ${template.title}');
    }

    if (result.type == 'habit' && result.habit != null) {
      final habit = result.habit!;
      newItem = ActivityInstance(
        id: _newId(),
        userId: resolvedUserId,
        habitId: habit.id,
        label: habit.label,
        scheduledDate: DateTime(date.year, date.month, date.day),
        status: ActivityStatus.pending,
        note: null,
        subTaskStates: const {},
      );

      newItem = await execution.addItem(newItem);
      _showAddFeedback(context, 'Added ${habit.title}');
    }

    if (newItem != null && mounted) {
      await _editItemTime(newItem);
    }
  }

  Future<void> _editItemTime(ActivityInstance item) async {
    final initialTime = TimeOfDay.fromDateTime(item.scheduledDate);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }
    final newScheduledDate = DateTime(
      item.scheduledDate.year,
      item.scheduledDate.month,
      item.scheduledDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!mounted) {
      return;
    }

    final execution = Provider.of<ExecutionProvider>(context, listen: false);
    execution.updateItemTime(item.id, newScheduledDate);

    if (!mounted) {
      return;
    }
    _showAddFeedback(context, 'Time updated to ${pickedTime.format(context)}');
  }

  Future<void> _editItemNote(ActivityInstance item) async {
    String initialNote = '';
    if (item.note != null) {
      initialNote = item.note!;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _NoteEditorPage(initialNote: initialNote);
        },
      ),
    );
    if (!mounted) {
      return;
    }
    if (result != null) {
      Provider.of<ExecutionProvider>(
        context,
        listen: false,
      ).updateItemNote(item.id, result);
      _showAddFeedback(context, 'Note saved');
    }
  }

  Future<void> _editItemLabel(ActivityInstance item) async {
    final selected = await Navigator.push<TaskLabel>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _LabelPickerPage(labelText: _labelText);
        },
      ),
    );
    if (!mounted) {
      return;
    }
    if (selected != null) {
      Provider.of<ExecutionProvider>(
        context,
        listen: false,
      ).updateItemLabel(item.id, selected);
      _showAddFeedback(context, 'Label updated');
    }
  }

  Future<void> _deleteItem(ActivityInstance item, String title) async {
    final bool confirmed = await confirmDelete(
      context,
      itemName: title,
      itemLabel: 'this item',
    );
    if (!confirmed || !mounted) {
      return;
    }
    Provider.of<ExecutionProvider>(context, listen: false).removeItem(item.id);
    _showAddFeedback(context, 'Deleted $title');
  }

  void _showAddFeedback(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
  }

  String _resolveTitle(ActivityInstance item, BlueprintProvider blueprint) {
    if (item.taskTemplateId != null) {
      final template = blueprint.templateById(item.taskTemplateId!);
      if (template != null) {
        return template.title;
      }
      return 'Task';
    }
    if (item.habitId != null) {
      final habit = blueprint.habitById(item.habitId!);
      if (habit != null) {
        return habit.title;
      }
      return 'Habit';
    }
    return 'Activity';
  }

  TaskLabel _resolveLabel(ActivityInstance item, BlueprintProvider blueprint) {
    if (item.label != null) {
      return item.label!;
    }
    if (item.taskTemplateId != null) {
      final template = blueprint.templateById(item.taskTemplateId!);
      if (template != null) {
        return template.label;
      }
      return TaskLabel.work;
    }
    if (item.habitId != null) {
      final habit = blueprint.habitById(item.habitId!);
      if (habit != null) {
        return habit.label;
      }
      return TaskLabel.work;
    }
    return TaskLabel.work;
  }

  String _formatFullDate(DateTime date) {
    final month = _monthName(date.month);
    return '$month ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date, MaterialLocalizations localizations) {
    return localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date));
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _newId() {
    return _uuid.v4();
  }

  String _labelText(TaskLabel label) {
    final raw = label.name.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
      return '${match.group(1)} ${match.group(2)}';
    });
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int get _monthsBefore {
    final span = _demoMonthRange - 1;
    return span ~/ 2;
  }

  int get _monthsAfter {
    final span = _demoMonthRange - 1;
    return span - _monthsBefore;
  }
}