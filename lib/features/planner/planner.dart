import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/providers/execution_provider.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  static const int _demoMonthRange = 6;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExecutionProvider>().fetchMonthData(
        _focusedDay,
        monthsBefore: _monthsBefore,
        monthsAfter: _monthsAfter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final execution = context.watch<ExecutionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Planner',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildScheduleTab(theme, execution),
    );
  }

  Widget _buildScheduleTab(ThemeData theme, ExecutionProvider execution) {
    final selected = _selectedDay ?? _focusedDay;
    final eventsForSelected = execution.eventsForDate(selected);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TableCalendar<ActivityInstance>(
          firstDay: DateTime(2010, 1, 1),
          lastDay: DateTime(2028, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
            execution.fetchMonthData(
              focusedDay,
              monthsBefore: _monthsBefore,
              monthsAfter: _monthsAfter,
            );
          },
          eventLoader: execution.eventsForDate,
          daysOfWeekHeight: 28,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.onSurface,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(_formatFullDate(selected), style: theme.textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showQuickAddSheet(context, selected),
              icon: const Icon(Icons.add),
              label: const Text('Quick Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (eventsForSelected.isEmpty)
          Text('No scheduled items.', style: theme.textTheme.bodyMedium)
        else
          ...eventsForSelected.map((item) => _buildEventTile(theme, item)),
      ],
    );
  }

  Widget _buildEventTile(ThemeData theme, ActivityInstance item) {
    final blueprint = context.read<BlueprintProvider>();
    final isHabit = item.habitId != null;
    final title = _resolveTitle(item, blueprint);
    final label = _resolveLabel(item, blueprint);
    final timeText = isHabit
        ? 'Habit'
        : _formatTime(item.scheduledDate, MaterialLocalizations.of(context));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(timeText, style: theme.textTheme.bodySmall),
          InkWell(
            onTap: () => _editItemLabel(item),
            child: Text(
              '# ${_labelText(label)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: isHabit ? null : () => _editItemTime(item),
          ),
          IconButton(
            icon: const Icon(Icons.note_alt_outlined),
            onPressed: () => _editItemNote(item),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            onPressed: () {
              context.read<ExecutionProvider>().removeItem(item.id);
              _showAddFeedback(context, 'Deleted $title');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showQuickAddSheet(BuildContext context, DateTime date) async {
    final blueprint = context.read<BlueprintProvider>();
    final execution = context.read<ExecutionProvider>();
    final userId = context.read<AppProvider>().currentUser.id;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Templates', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...blueprint.templates.map(
                  (template) => ListTile(
                    title: Text(template.title),
                    subtitle: Text(_labelText(template.label)),
                    onTap: () async {
                      final picked = await _pickTime(sheetContext);
                      if (picked == null) {
                        return;
                      }
                      final scheduled = _combineDateAndTime(date, picked);
                      final subTaskStates = {
                        for (final subTask in template.subTasks)
                          subTask.id: false,
                      };
                      execution.addItem(
                        ActivityInstance(
                          id: _newId(),
                          userId: userId,
                          taskTemplateId: template.id,
                          label: template.label,
                          scheduledDate: scheduled,
                          status: ActivityStatus.pending,
                          note: null,
                          subTaskStates: subTaskStates,
                        ),
                      );
                      _showAddFeedback(context, 'Added ${template.title}');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text('Habits', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...blueprint.habits.map(
                  (habit) => ListTile(
                    title: Text(habit.title),
                    subtitle: Text(_labelText(habit.label)),
                    onTap: () async {
                      final scheduled = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );
                      execution.addItem(
                        ActivityInstance(
                          id: _newId(),
                          userId: userId,
                          habitId: habit.id,
                          label: habit.label,
                          scheduledDate: scheduled,
                          status: ActivityStatus.pending,
                          note: null,
                          subTaskStates: const {},
                        ),
                      );
                      _showAddFeedback(context, 'Added ${habit.title}');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editItemTime(ActivityInstance item) async {
    final execution = context.read<ExecutionProvider>();
    final picked = await _pickTime(context, initial: item.scheduledDate);
    if (picked == null) {
      return;
    }
    final scheduled = _combineDateAndTime(item.scheduledDate, picked);
    execution.updateItemTime(item.id, scheduled);
  }

  Future<void> _editItemNote(ActivityInstance item) async {
    var draft = item.note ?? '';
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Note', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: draft,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Add a note'),
                  onChanged: (value) => draft = value,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      final trimmed = draft.trim();
                      Navigator.of(
                        sheetContext,
                      ).pop(trimmed.isEmpty ? null : trimmed);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null) {
      context.read<ExecutionProvider>().updateItemNote(item.id, result);
      _showAddFeedback(context, 'Note saved');
    }
  }

  Future<void> _editItemLabel(ActivityInstance item) async {
    final selected = await showModalBottomSheet<TaskLabel>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Label', style: theme.textTheme.titleMedium),
              ),
              ...TaskLabel.values.map(
                (label) => ListTile(
                  title: Text(_labelText(label)),
                  onTap: () => Navigator.of(sheetContext).pop(label),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      context.read<ExecutionProvider>().updateItemLabel(item.id, selected);
      _showAddFeedback(context, 'Label updated');
    }
  }

  Future<TimeOfDay?> _pickTime(
    BuildContext context, {
    DateTime? initial,
  }) async {
    final base = initial == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(initial);
    return showTimePicker(context: context, initialTime: base);
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _showAddFeedback(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(title)));
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

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  String _labelText(TaskLabel label) {
    final raw = label.name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
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
