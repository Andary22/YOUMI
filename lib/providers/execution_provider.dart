// ExecutionProvider: activity instance queries and execution state updates.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/mock_data.dart';

class ExecutionProvider extends ChangeNotifier {
  final List<ActivityInstance> _items = [];
  final Map<DateTime, List<ActivityInstance>> _monthEvents = {};
  DateTime? _monthStart;
  DateTime? _monthEnd;

  List<ActivityInstance> get items => _items;
  Map<DateTime, List<ActivityInstance>> get monthEvents => _monthEvents;

  List<ActivityInstance> eventsForDate(DateTime date) {
    return _monthEvents[_dateKey(date)] ?? const [];
  }

  Future<void> fetchMonthData(
    DateTime targetMonth, {
    int monthsBefore = 0,
    int monthsAfter = 0,
  }) async {
    final start = DateTime(
      targetMonth.year,
      targetMonth.month - monthsBefore,
      1,
    );
    final end = DateTime(
      targetMonth.year,
      targetMonth.month + monthsAfter + 1,
      0,
      23,
      59,
      59,
    );

    _monthStart = start;
    _monthEnd = end;

    final data = MockData.activityInstances
        .where(
          (item) =>
              !item.scheduledDate.isBefore(start) &&
              !item.scheduledDate.isAfter(end),
        )
        .toList();

    _items
      ..clear()
      ..addAll(data);

    _groupInstancesByDate(data);
  }

  void addItem(ActivityInstance item) {
    _items.add(item);
    if (_isWithinMonth(item.scheduledDate)) {
      final key = _dateKey(item.scheduledDate);
      final bucket = _monthEvents.putIfAbsent(key, () => []);
      bucket.add(item);
    }
    notifyListeners();
  }

  void updateItemTime(String id, DateTime newTime) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    _items[index] = ActivityInstance(
      id: current.id,
      userId: current.userId,
      taskTemplateId: current.taskTemplateId,
      habitId: current.habitId,
      label: current.label,
      scheduledDate: newTime,
      status: current.status,
      actualDuration: current.actualDuration,
      note: current.note,
      subTaskStates: current.subTaskStates,
    );

    _groupInstancesByDate(_items);
  }

  void updateItemNote(String id, String? note) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    _items[index] = ActivityInstance(
      id: current.id,
      userId: current.userId,
      taskTemplateId: current.taskTemplateId,
      habitId: current.habitId,
      label: current.label,
      scheduledDate: current.scheduledDate,
      status: current.status,
      actualDuration: current.actualDuration,
      note: note,
      subTaskStates: current.subTaskStates,
    );

    _groupInstancesByDate(_items);
  }

  void updateItemLabel(String id, TaskLabel label) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final current = _items[index];
    _items[index] = ActivityInstance(
      id: current.id,
      userId: current.userId,
      taskTemplateId: current.taskTemplateId,
      habitId: current.habitId,
      label: label,
      scheduledDate: current.scheduledDate,
      status: current.status,
      actualDuration: current.actualDuration,
      note: current.note,
      subTaskStates: current.subTaskStates,
    );

    _groupInstancesByDate(_items);
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _groupInstancesByDate(_items);
  }

  void _groupInstancesByDate(List<ActivityInstance> instances) {
    _monthEvents.clear();
    for (final instance in instances) {
      final key = _dateKey(instance.scheduledDate);
      final bucket = _monthEvents.putIfAbsent(key, () => []);
      bucket.add(instance);
    }
    notifyListeners();
  }

  bool _isWithinMonth(DateTime date) {
    if (_monthStart == null || _monthEnd == null) {
      return false;
    }
    return !date.isBefore(_monthStart!) && !date.isAfter(_monthEnd!);
  }

  DateTime _dateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
