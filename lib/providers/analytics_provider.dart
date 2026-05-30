import 'package:flutter/material.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/task_template.dart';

class AnalyticsProvider extends ChangeNotifier {
  List<ActivityInstance> _instances = [];
  Map<String, TaskTemplate> _templatesById = {};
  Map<String, Habit> _habitsById = {};
  DateTimeRange _range;
  TaskLabel? _labelFilter;

  AnalyticsProvider({DateTime? referenceDate})
      : _range = _defaultRange(DateTime.now()),
        _labelFilter = null {
    if (referenceDate != null) {
      _range = _defaultRange(referenceDate);
    }
  }

  void syncData({
    required List<ActivityInstance> instances,
    required List<TaskTemplate> templates,
    required List<Habit> habits,
  }) {
    _instances = List<ActivityInstance>.from(instances);
    _templatesById = {};
    for (int i = 0; i < templates.length; i++) {
      final template = templates[i];
      _templatesById[template.id] = template;
    }
    _habitsById = {};
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      _habitsById[habit.id] = habit;
    }
    notifyListeners();
  }

  DateTimeRange get range {
    return _range;
  }

  TaskLabel? get labelFilter {
    return _labelFilter;
  }

  List<ActivityInstance> get completedItems {
    final List<ActivityInstance> items = [];
    final List<ActivityInstance> filtered = _filteredInstances();
    for (int i = 0; i < filtered.length; i++) {
      final item = filtered[i];
      if (item.status == ActivityStatus.success) {
        items.add(item);
      }
    }
    items.sort((a, b) {
      return b.scheduledDate.compareTo(a.scheduledDate);
    });
    return items;
  }

  List<LabelCount> get completionCountsByLabel {
    final Map<TaskLabel, int> counts = {};
    for (int i = 0; i < TaskLabel.values.length; i++) {
      counts[TaskLabel.values[i]] = 0;
    }
    for (final item in completedItems) {
      final label = _resolveLabel(item);
      int current = 0;
      if (counts[label] != null) {
        current = counts[label]!;
      }
      counts[label] = current + 1;
    }
    final List<LabelCount> results = [];
    for (int i = 0; i < TaskLabel.values.length; i++) {
      final label = TaskLabel.values[i];
      int count = 0;
      if (counts[label] != null) {
        count = counts[label]!;
      }
      results.add(LabelCount(label: label, count: count));
    }
    return results;
  }

  List<LabelDurationStats> get durationStatsByLabel {
    final accumulators = <TaskLabel, _DurationAccumulator>{};
    for (final item in completedItems) {
      final template = _templateFor(item.taskTemplateId);
      if (template == null) {
        continue;
      }
      final actual = item.actualDuration;
      if (actual == null) {
        continue;
      }
      final label = _resolveLabel(item);
      if (!accumulators.containsKey(label)) {
        accumulators[label] = _DurationAccumulator();
      }
      final accumulator = accumulators[label]!;
      accumulator.add(template.expectedDuration, actual);
    }

    final List<LabelDurationStats> stats = [];
    for (int i = 0; i < TaskLabel.values.length; i++) {
      final label = TaskLabel.values[i];
      if (!accumulators.containsKey(label)) {
        continue;
      }
      final accumulator = accumulators[label]!;
      stats.add(
        LabelDurationStats(
          label: label,
          expectedAverage: accumulator.expectedAverage,
          actualAverage: accumulator.actualAverage,
          sampleCount: accumulator.count,
        ),
      );
    }
    return stats;
  }

  DurationStats get overallDurationStats {
    final accumulator = _DurationAccumulator();
    for (final item in completedItems) {
      final template = _templateFor(item.taskTemplateId);
      if (template == null) {
        continue;
      }
      final actual = item.actualDuration;
      if (actual == null) {
        continue;
      }
      accumulator.add(template.expectedDuration, actual);
    }
    return DurationStats(
      expectedAverage: accumulator.expectedAverage,
      actualAverage: accumulator.actualAverage,
      sampleCount: accumulator.count,
    );
  }

  void setDateRange(DateTimeRange range) {
    _range = _normalizedRange(range);
    notifyListeners();
  }

  void setLabelFilter(TaskLabel? label) {
    _labelFilter = label;
    notifyListeners();
  }

  List<ActivityInstance> _filteredInstances() {
    final List<ActivityInstance> results = [];
    for (int i = 0; i < _instances.length; i++) {
      final item = _instances[i];
      if (!_isInRange(item.scheduledDate)) {
        continue;
      }
      if (_labelFilter == null) {
        results.add(item);
        continue;
      }
      if (_resolveLabel(item) == _labelFilter) {
        results.add(item);
      }
    }
    return results;
  }

  TaskTemplate? _templateFor(String? templateId) {
    if (templateId == null) {
      return null;
    }
    return _templatesById[templateId];
  }

  TaskLabel _resolveLabel(ActivityInstance item) {
    if (item.label != null) {
      return item.label!;
    }
    if (item.taskTemplateId != null) {
      final template = _templatesById[item.taskTemplateId!];
      if (template != null) {
        return template.label;
      }
    }
    if (item.habitId != null) {
      final habit = _habitsById[item.habitId!];
      if (habit != null) {
        return habit.label;
      }
    }
    return TaskLabel.work;
  }

  bool _isInRange(DateTime date) {
    return !date.isBefore(_range.start) && !date.isAfter(_range.end);
  }

  static DateTimeRange _defaultRange(DateTime referenceDate) {
    final end = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      23,
      59,
      59,
    );
    final start = end.subtract(const Duration(days: 30));
    return DateTimeRange(start: start, end: end);
  }

  static DateTimeRange _normalizedRange(DateTimeRange range) {
    if (!range.start.isAfter(range.end)) {
      return range;
    }
    return DateTimeRange(start: range.end, end: range.start);
  }
}

class LabelCount {
  final TaskLabel label;
  final int count;

  const LabelCount({required this.label, required this.count});
}

class LabelDurationStats {
  final TaskLabel label;
  final Duration expectedAverage;
  final Duration actualAverage;
  final int sampleCount;

  const LabelDurationStats({
    required this.label,
    required this.expectedAverage,
    required this.actualAverage,
    required this.sampleCount,
  });
}

class DurationStats {
  final Duration expectedAverage;
  final Duration actualAverage;
  final int sampleCount;

  const DurationStats({
    required this.expectedAverage,
    required this.actualAverage,
    required this.sampleCount,
  });
}

class _DurationAccumulator {
  Duration _expectedTotal = Duration.zero;
  Duration _actualTotal = Duration.zero;
  int count = 0;

  void add(Duration expected, Duration actual) {
    _expectedTotal += expected;
    _actualTotal += actual;
    count += 1;
  }

  Duration get expectedAverage {
    return _averageDuration(_expectedTotal, count);
  }

  Duration get actualAverage {
    return _averageDuration(_actualTotal, count);
  }

  Duration _averageDuration(Duration total, int count) {
    if (count == 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: total.inMilliseconds ~/ count);
  }
}
