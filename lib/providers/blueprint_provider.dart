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

  List<TaskFolder> get folders => List<TaskFolder>.unmodifiable(_folders);
  List<TaskTemplate> get templates => List<TaskTemplate>.unmodifiable(_templates);
  List<Habit> get habits => List<Habit>.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> loadForUser(String userId) async {
    _setLoading(true);
    try {
      final api = SupabaseApi.instance;
      final results = await Future.wait([
        api.fetchTaskFolders(userId),
        api.fetchTaskTemplates(userId),
        api.fetchHabits(userId),
      ]);
      _folders
        ..clear()
        ..addAll(results[0] as List<TaskFolder>);
      _templates
        ..clear()
        ..addAll(results[1] as List<TaskTemplate>);
      _habits
        ..clear()
        ..addAll(results[2] as List<Habit>);
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
    final index = _templates.indexWhere((item) => item.id == saved.id);
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
    final index = _habits.indexWhere((item) => item.id == saved.id);
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
    final index = _folders.indexWhere((item) => item.id == saved.id);
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
    _templates.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await SupabaseApi.instance.deleteHabit(id);
    _habits.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> deleteFolder(String id) async {
    await SupabaseApi.instance.deleteTaskFolder(id);
    _folders.removeWhere((item) => item.id == id);
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
