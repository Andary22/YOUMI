import 'package:youmi_dev/core/utils.dart';
import 'package:youmi_dev/models/labels.dart';

class SubTask {
  final String id;
  final String title;
  final int position;

  const SubTask({
    required this.id,
    required this.title,
    required this.position,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      position: json['position'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'position': position};
  }
}

class TaskTemplate {
  final String id;
  final String userId;
  final String title;
  final TaskLabel label;
  final Duration expectedDuration;
  final List<SubTask> subTasks;
  final String? taskFolderId;

  const TaskTemplate({
    required this.id,
    required this.userId,
    required this.title,
    required this.label,
    required this.expectedDuration,
    required this.subTasks,
    this.taskFolderId,
  });

  factory TaskTemplate.fromJson(Map<String, dynamic> json) {
    final rawSubTasks = (json['sub_tasks'] as List?) ?? const [];
    return TaskTemplate(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      label: taskLabelFromDb(json['label'] as String),
      expectedDuration: parseInterval(json['expected_duration']),
      subTasks: rawSubTasks
          .map((item) => SubTask.fromJson(item as Map<String, dynamic>))
          .toList(),
      taskFolderId: json['task_folder_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'label': taskLabelToDb(label),
      'expected_duration': formatInterval(expectedDuration),
      'sub_tasks': subTasks.map((task) => task.toJson()).toList(),
      'task_folder_id': taskFolderId,
    };
  }
}
