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
  List<ActivityInstance> _completedItemsCache = [];
  List<LabelCount> _completionCountsByLabelCache = const [];
  List<LabelDurationStats> _durationStatsByLabelCache = const [];
  DurationStats _overallDurationStatsCache = const DurationStats(
    expectedAverage: Duration.zero,
    actualAverage: Duration.zero,
    sampleCount: 0,
  );

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
    _rebuildDerivedData();
    notifyListeners();
  }

  DateTimeRange get range {
    return _range;
  }

  TaskLabel? get labelFilter {
    return _labelFilter;
  }

  List<ActivityInstance> get completedItems {
    return List<ActivityInstance>.unmodifiable(_completedItemsCache);
  }

  List<LabelCount> get completionCountsByLabel {
    return List<LabelCount>.unmodifiable(_completionCountsByLabelCache);
  }

  List<LabelDurationStats> get durationStatsByLabel {
    return List<LabelDurationStats>.unmodifiable(_durationStatsByLabelCache);
  }

  DurationStats get overallDurationStats {
    return _overallDurationStatsCache;
  }

  void setDateRange(DateTimeRange range) {
    _range = _normalizedRange(range);
    _rebuildDerivedData();
    notifyListeners();
  }

  void setLabelFilter(TaskLabel? label) {
    _labelFilter = label;
    _rebuildDerivedData();
    notifyListeners();
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

  void _rebuildDerivedData() {
    final List<ActivityInstance> completed = [];
    final Map<TaskLabel, int> counts = {
      for (final label in TaskLabel.values) label: 0,
    };
    final Map<TaskLabel, _DurationAccumulator> accumulators = {};

    for (int i = 0; i < _instances.length; i++) {
      final item = _instances[i];
      if (!_isInRange(item.scheduledDate)) {
        continue;
      }
      final TaskLabel resolvedLabel = _resolveLabel(item);
      if (_labelFilter != null && resolvedLabel != _labelFilter) {
        continue;
      }
      if (item.status != ActivityStatus.success) {
        continue;
      }

      completed.add(item);
      counts[resolvedLabel] = (counts[resolvedLabel] ?? 0) + 1;

      final template = _templateFor(item.taskTemplateId);
      final actual = item.actualDuration;
      if (template == null || actual == null) {
        continue;
      }
      final accumulator = accumulators.putIfAbsent(
        resolvedLabel,
        () => _DurationAccumulator(),
      );
      accumulator.add(template.expectedDuration, actual);
    }

    completed.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    _completedItemsCache = completed;
    _completionCountsByLabelCache = [
      for (final label in TaskLabel.values)
        LabelCount(label: label, count: counts[label] ?? 0),
    ];
    _durationStatsByLabelCache = [
      for (final label in TaskLabel.values)
        if (accumulators.containsKey(label))
          LabelDurationStats(
            label: label,
            expectedAverage: accumulators[label]!.expectedAverage,
            actualAverage: accumulators[label]!.actualAverage,
            sampleCount: accumulators[label]!.count,
          ),
    ];

    final overallAccumulator = _DurationAccumulator();
    for (final accumulator in accumulators.values) {
      overallAccumulator.merge(accumulator);
    }
    _overallDurationStatsCache = DurationStats(
      expectedAverage: overallAccumulator.expectedAverage,
      actualAverage: overallAccumulator.actualAverage,
      sampleCount: overallAccumulator.count,
    );
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

  void merge(_DurationAccumulator other) {
    _expectedTotal += other._expectedTotal;
    _actualTotal += other._actualTotal;
    count += other.count;
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
