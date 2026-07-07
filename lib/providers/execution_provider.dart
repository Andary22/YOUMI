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

  List<ActivityInstance> get items {
    return List<ActivityInstance>.unmodifiable(_items);
  }

  Map<DateTime, List<ActivityInstance>> get monthEvents {
    return _monthEvents;
  }

  bool get isLoading {
    return _isLoading;
  }

  String? get lastError {
    return _lastError;
  }

  List<ActivityInstance> eventsForDate(DateTime date) {
    final key = _dateKey(date);
    if (_monthEvents.containsKey(key)) {
      return List<ActivityInstance>.from(_monthEvents[key]!);
    }
    return <ActivityInstance>[];
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

      _items.clear();
      _items.addAll(data);

      _groupInstancesByDate(data);
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<ActivityInstance> addItem(ActivityInstance item) async {
    final saved = await SupabaseApi.instance.upsertActivityInstance(item);
    _items.add(saved);
    if (_isWithinMonth(saved.scheduledDate)) {
      final key = _dateKey(saved.scheduledDate);
      List<ActivityInstance> bucket;
      if (_monthEvents.containsKey(key)) {
        bucket = _monthEvents[key]!;
      } else {
        bucket = [];
        _monthEvents[key] = bucket;
      }
      bucket.add(saved);
    }
    notifyListeners();
    return saved;
  }

  Future<void> updateItemTime(String id, DateTime newTime) async {
    int index = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        index = i;
        break;
      }
    }
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
    int index = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        index = i;
        break;
      }
    }
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
    int index = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        index = i;
        break;
      }
    }
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
    int index = -1;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].id == id) {
        index = i;
        break;
      }
    }
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
    for (int i = _items.length - 1; i >= 0; i--) {
      if (_items[i].id == id) {
        _items.removeAt(i);
      }
    }
    _groupInstancesByDate(_items);
  }

  void _groupInstancesByDate(List<ActivityInstance> instances) {
    _monthEvents.clear();
    for (final instance in instances) {
      final key = _dateKey(instance.scheduledDate);
      List<ActivityInstance> bucket;
      if (_monthEvents.containsKey(key)) {
        bucket = _monthEvents[key]!;
      } else {
        bucket = [];
        _monthEvents[key] = bucket;
      }
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
