  // BlueprintProvider: CRUD and lookup for task templates, habits, and folders.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/core/supabase_api.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';

class BlueprintProvider extends ChangeNotifier {
  final List<TaskFolder> _folders = [];
  final List<TaskTemplate> _templates = [];
  final List<Habit> _habits = [];
  bool _isLoading = false;
  String? _lastError;

  List<TaskFolder> get folders {
    return List<TaskFolder>.unmodifiable(_folders);
  }

  List<TaskTemplate> get templates {
    return List<TaskTemplate>.unmodifiable(_templates);
  }

  List<Habit> get habits {
    return List<Habit>.unmodifiable(_habits);
  }

  bool get isLoading {
    return _isLoading;
  }

  String? get lastError {
    return _lastError;
  }

  Future<void> loadForUser(String userId) async {
    _setLoading(true);
    try {
      final api = SupabaseApi.instance;
      final results = await Future.wait([
        api.fetchTaskFolders(userId),
        api.fetchTaskTemplates(userId),
        api.fetchHabits(userId),
      ]);
      _folders.clear();
      _folders.addAll(results[0] as List<TaskFolder>);
      _templates.clear();
      _templates.addAll(results[1] as List<TaskTemplate>);
      _habits.clear();
      _habits.addAll(results[2] as List<Habit>);
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskTemplate> saveTemplate(TaskTemplate template) async {
    final api = SupabaseApi.instance;
    final saved = await api.upsertTaskTemplate(template);
    int index = -1;
    for (int i = 0; i < _templates.length; i++) {
      if (_templates[i].id == saved.id) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      _templates[index] = saved;
    } else {
      _templates.add(saved);
    }
    notifyListeners();
    return saved;
  }

  Future<Habit> saveHabit(Habit habit) async {
    final api = SupabaseApi.instance;
    final saved = await api.upsertHabit(habit);
    int index = -1;
    for (int i = 0; i < _habits.length; i++) {
      if (_habits[i].id == saved.id) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      _habits[index] = saved;
    } else {
      _habits.add(saved);
    }
    notifyListeners();
    return saved;
  }

  Future<TaskFolder> saveFolder(TaskFolder folder) async {
    final api = SupabaseApi.instance;
    final saved = await api.upsertTaskFolder(folder);
    int index = -1;
    for (int i = 0; i < _folders.length; i++) {
      if (_folders[i].id == saved.id) {
        index = i;
        break;
      }
    }
    if (index >= 0) {
      _folders[index] = saved;
    } else {
      _folders.add(saved);
    }
    notifyListeners();
    return saved;
  }

  Future<void> deleteTemplate(String id) async {
    await SupabaseApi.instance.deleteTaskTemplate(id);
    for (int i = _templates.length - 1; i >= 0; i--) {
      if (_templates[i].id == id) {
        _templates.removeAt(i);
      }
    }
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await SupabaseApi.instance.deleteHabit(id);
    for (int i = _habits.length - 1; i >= 0; i--) {
      if (_habits[i].id == id) {
        _habits.removeAt(i);
      }
    }
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await SupabaseApi.instance.deleteTaskFolder(id);
    for (int i = _folders.length - 1; i >= 0; i--) {
      if (_folders[i].id == id) {
        _folders.removeAt(i);
      }
    }
    notifyListeners();
  }

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
