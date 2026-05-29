// ExecutionProvider: activity instance queries and execution state updates.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/core/supabase_api.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/labels.dart';

class ExecutionProvider extends ChangeNotifier {
  final List<ActivityInstance> _items = [];
  final Map<DateTime, List<ActivityInstance>> _monthEvents = {};
  DateTime? _monthStart;
  DateTime? _monthEnd;
  bool _isLoading = false;
  String? _lastError;

  List<ActivityInstance> get items => List<ActivityInstance>.unmodifiable(_items);
  Map<DateTime, List<ActivityInstance>> get monthEvents => _monthEvents;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

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

    final userId = SupabaseApi.instance.userId;
    if (userId == null) {
      return;
    }

    _setLoading(true);
    try {
      final data = await SupabaseApi.instance.fetchActivityInstances(
        userId,
        start,
        end,
      );

      _items
        ..clear()
        ..addAll(data);

      _groupInstancesByDate(data);
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItem(ActivityInstance item) async {
    final saved = await SupabaseApi.instance.upsertActivityInstance(item);
    _items.add(saved);
    if (_isWithinMonth(saved.scheduledDate)) {
      final key = _dateKey(saved.scheduledDate);
      final bucket = _monthEvents.putIfAbsent(key, () => []);
      bucket.add(saved);
    }
    notifyListeners();
  }

  Future<void> updateItemTime(String id, DateTime newTime) async {
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
    await SupabaseApi.instance.updateActivityInstance(id, {
      'scheduled_date': newTime.toIso8601String(),
    });
  }

  Future<void> updateItemNote(String id, String? note) async {
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
    await SupabaseApi.instance.updateActivityInstance(id, {'note': note});
  }

  Future<void> updateItemLabel(String id, TaskLabel label) async {
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
    await SupabaseApi.instance.updateActivityInstance(id, {
      'label': label.name,
    });
  }

  Future<void> updateItemStatus(String id, ActivityStatus status) async {
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
      status: status,
      actualDuration: current.actualDuration,
      note: current.note,
      subTaskStates: current.subTaskStates,
    );

    _groupInstancesByDate(_items);
    await SupabaseApi.instance.updateActivityInstance(id, {
      'status': status.name,
    });
  }

  Future<void> removeItem(String id) async {
    await SupabaseApi.instance.deleteActivityInstance(id);
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
