import 'package:youmi_dev/core/utils.dart';
import 'package:youmi_dev/models/labels.dart';

enum ActivityStatus { success, missed, pending }

ActivityStatus activityStatusFromDb(String value) {
  for (int i = 0; i < ActivityStatus.values.length; i++) {
    final status = ActivityStatus.values[i];
    if (status.name == value) {
      return status;
    }
  }
  return ActivityStatus.pending;
}

String activityStatusToDb(ActivityStatus status) {
  return status.name;
}

class ActivityInstance {
  final String id;
  final String userId;
  final String? taskTemplateId;
  final String? habitId;
  final TaskLabel? label;
  final DateTime scheduledDate;
  final ActivityStatus status;
  final Duration? actualDuration;
  final String? note;
  final Map<String, bool> subTaskStates;

  ActivityInstance({
    required this.id,
    required this.userId,
    required this.scheduledDate,
    required this.status,
    this.taskTemplateId,
    this.habitId,
    this.label,
    this.actualDuration,
    this.note,
    Map<String, bool>? subTaskStates,
  }) : subTaskStates = _normalizeSubTaskStates(subTaskStates) {
    assert(
      (taskTemplateId == null) != (habitId == null),
      'Exactly one of taskTemplateId or habitId must be set.',
    );
  }

  factory ActivityInstance.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawStates = const {};
    if (json['sub_tasks_states'] is Map<String, dynamic>) {
      rawStates = json['sub_tasks_states'] as Map<String, dynamic>;
    }
    TaskLabel? labelValue;
    if (json['label'] != null) {
      labelValue = taskLabelFromDb(json['label'] as String);
    }
    Duration? actual;
    if (json['actual_duration'] != null) {
      actual = parseInterval(json['actual_duration']);
    }
    final Map<String, bool> states = {};
    rawStates.forEach((key, value) {
      states[key] = value == true;
    });
    return ActivityInstance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskTemplateId: json['task_template_id'] as String?,
      habitId: json['habit_id'] as String?,
      label: labelValue,
      scheduledDate: _parseTimestamp(json['scheduled_date']),
      status: activityStatusFromDb(json['status'] as String),
      actualDuration: actual,
      note: json['note'] as String?,
      subTaskStates: states,
    );
  }

  Map<String, dynamic> toJson() {
    String? labelValue;
    if (label != null) {
      labelValue = taskLabelToDb(label!);
    }
    String? actualDurationValue;
    if (actualDuration != null) {
      actualDurationValue = formatInterval(actualDuration!);
    }
    return {
      'id': id,
      'user_id': userId,
      'task_template_id': taskTemplateId,
      'habit_id': habitId,
      'label': labelValue,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': activityStatusToDb(status),
      'actual_duration': actualDurationValue,
      'note': note,
      'sub_tasks_states': subTaskStates,
    };
  }
}

Map<String, bool> _normalizeSubTaskStates(Map<String, bool>? states) {
  if (states == null) {
    return Map<String, bool>.from(const {});
  }
  return Map<String, bool>.from(states);
}

DateTime _parseTimestamp(dynamic value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.parse(value);
  }
  throw FormatException('Invalid timestamp value: $value');
}
