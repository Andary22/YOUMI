import 'package:flutter/material.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/task_template.dart';

class AnalyticsProvider extends ChangeNotifier {
  final List<ActivityInstance> _instances;
  final Map<String, TaskTemplate> _templatesById;
  final Map<String, Habit> _habitsById;
  DateTimeRange _range;
  TaskLabel? _labelFilter;

  AnalyticsProvider({DateTime? referenceDate})
    : _instances = List<ActivityInstance>.from(MockData.activityInstances),
      _templatesById = {
        for (final template in MockData.taskTemplates) template.id: template,
      },
      _habitsById = {for (final habit in MockData.habits) habit.id: habit},
      _range = _defaultRange(referenceDate ?? DateTime.now()),
      _labelFilter = null;

  DateTimeRange get range => _range;
  TaskLabel? get labelFilter => _labelFilter;

  List<ActivityInstance> get completedItems {
    final items = _filteredInstances()
        .where((item) => item.status == ActivityStatus.success)
        .toList();
    items.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return items;
  }

  List<LabelCount> get completionCountsByLabel {
    final counts = <TaskLabel, int>{
      for (final label in TaskLabel.values) label: 0,
    };
    for (final item in completedItems) {
      final label = _resolveLabel(item);
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return [
      for (final label in TaskLabel.values)
        LabelCount(label: label, count: counts[label] ?? 0),
    ];
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
      final accumulator = accumulators.putIfAbsent(
        label,
        () => _DurationAccumulator(),
      );
      accumulator.add(template.expectedDuration, actual);
    }

    return [
      for (final label in TaskLabel.values)
        if (accumulators.containsKey(label))
          LabelDurationStats(
            label: label,
            expectedAverage: accumulators[label]!.expectedAverage,
            actualAverage: accumulators[label]!.actualAverage,
            sampleCount: accumulators[label]!.count,
          ),
    ];
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
    return _instances.where((item) {
      if (!_isInRange(item.scheduledDate)) {
        return false;
      }
      if (_labelFilter == null) {
        return true;
      }
      return _resolveLabel(item) == _labelFilter;
    }).toList();
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

  Duration get expectedAverage => _averageDuration(_expectedTotal, count);
  Duration get actualAverage => _averageDuration(_actualTotal, count);

  Duration _averageDuration(Duration total, int count) {
    if (count == 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: total.inMilliseconds ~/ count);
  }
}
