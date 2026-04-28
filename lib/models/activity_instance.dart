import 'package:youmi_dev/core/utils.dart';

enum ActivityStatus { success, missed, pending }

ActivityStatus activityStatusFromDb(String value) {
  return ActivityStatus.values.firstWhere((status) => status.name == value);
}

String activityStatusToDb(ActivityStatus status) {
  return status.name;
}

class ActivityInstance {
  final String id;
  final String userId;
  final String? taskTemplateId;
  final String? habitId;
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
    this.actualDuration,
    this.note,
    Map<String, bool>? subTaskStates,
  }) : subTaskStates = Map<String, bool>.from(subTaskStates ?? const {}) {
    assert(
      (taskTemplateId == null) != (habitId == null),
      'Exactly one of taskTemplateId or habitId must be set.',
    );
  }

  factory ActivityInstance.fromJson(Map<String, dynamic> json) {
    final rawStates =
        (json['sub_tasks_states'] as Map<String, dynamic>?) ?? const {};
    return ActivityInstance(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      taskTemplateId: json['task_template_id'] as String?,
      habitId: json['habit_id'] as String?,
      scheduledDate: _parseTimestamp(json['scheduled_date']),
      status: activityStatusFromDb(json['status'] as String),
      actualDuration: json['actual_duration'] == null
          ? null
          : parseInterval(json['actual_duration']),
      note: json['note'] as String?,
      subTaskStates: rawStates.map(
        (key, value) => MapEntry(key, value == true),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'task_template_id': taskTemplateId,
      'habit_id': habitId,
      'scheduled_date': scheduledDate.toIso8601String(),
      'status': activityStatusToDb(status),
      'actual_duration': actualDuration == null
          ? null
          : formatInterval(actualDuration!),
      'note': note,
      'sub_tasks_states': subTaskStates,
    };
  }
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
