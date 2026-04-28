// BlueprintProvider: CRUD and lookup for task templates, habits, and folders.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';

class BlueprintProvider extends ChangeNotifier {
  final List<TaskFolder> _folders = List<TaskFolder>.unmodifiable(
    MockData.taskFolders,
  );
  final List<TaskTemplate> _templates = List<TaskTemplate>.unmodifiable(
    MockData.taskTemplates,
  );
  final List<Habit> _habits = List<Habit>.unmodifiable(MockData.habits);

  List<TaskFolder> get folders => _folders;
  List<TaskTemplate> get templates => _templates;
  List<Habit> get habits => _habits;

  TaskTemplate? templateById(String id) {
    for (final template in _templates) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  Habit? habitById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) {
        return habit;
      }
    }
    return null;
  }

  TaskFolder? folderById(String id) {
    for (final folder in _folders) {
      if (folder.id == id) {
        return folder;
      }
    }
    return null;
  }
}
