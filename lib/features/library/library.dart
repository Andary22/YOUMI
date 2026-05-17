import 'package:flutter/material.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';

part 'library_widgets.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() {
    return _LibraryViewState();
  }
}

class _LibraryViewState extends State<LibraryView> {
  final List<TaskTemplate> _templates = List<TaskTemplate>.from(
    MockData.taskTemplates,
  );
  final List<Habit> _habits = List<Habit>.from(MockData.habits);
  final List<TaskFolder> _folders = List<TaskFolder>.from(MockData.taskFolders);
  String _activeEditor = '';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _subTasksController = TextEditingController();
  TaskLabel _selectedLabel = TaskLabel.work;
  String? _selectedFolderId;
  String? _editingTemplateId;

  final TextEditingController _habitTitleController = TextEditingController();
  final TextEditingController _maskController = TextEditingController();
  TaskLabel _habitSelectedLabel = TaskLabel.health;
  String? _editingHabitId;

  final TextEditingController _folderTitleController = TextEditingController();
  String? _editingFolderId;

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _openTemplateEditor(TaskTemplate? existing) {
    _editingTemplateId = existing?.id;
    _titleController.text = existing?.title ?? '';
    _durationController.text =
        existing?.expectedDuration.inMinutes.toString() ?? '';
    String subStr = '';
    if (existing != null) {
      for (int i = 0; i < existing.subTasks.length; i++) {
        if (i > 0) subStr += ', ';
        subStr += existing.subTasks[i].title;
      }
    }
    _subTasksController.text = subStr;
    _selectedLabel = existing?.label ?? TaskLabel.work;
    _selectedFolderId =
        existing?.taskFolderId ?? (_folders.isNotEmpty ? _folders[0].id : null);
    setState(() {
      _activeEditor = 'template';
    });
  }

  void _openHabitEditor(Habit? existing) {
    _editingHabitId = existing?.id;
    _habitTitleController.text = existing?.title ?? '';
    _maskController.text = existing?.recurrenceMask.toString() ?? '';
    _habitSelectedLabel = existing?.label ?? TaskLabel.health;
    setState(() {
      _activeEditor = 'habit';
    });
  }

  void _openFolderEditor(TaskFolder? existing) {
    _editingFolderId = existing?.id;
    _folderTitleController.text = existing?.title ?? '';
    setState(() {
      _activeEditor = 'folder';
    });
  }

  void _openNewTemplate() {
    _openTemplateEditor(null);
  }

  void _openNewHabit() {
    _openHabitEditor(null);
  }

  void _openNewFolder() {
    _openFolderEditor(null);
  }

  void _closeEditor() {
    setState(() {
      _activeEditor = '';
    });
  }

  void _setSelectedLabel(TaskLabel value) {
    setState(() {
      _selectedLabel = value;
    });
  }

  void _setHabitSelectedLabel(TaskLabel value) {
    setState(() {
      _habitSelectedLabel = value;
    });
  }

  void _setSelectedFolderId(String? value) {
    setState(() {
      _selectedFolderId = value;
    });
  }

  void _saveTemplate() {
    final int minutes = int.tryParse(_durationController.text.trim()) ?? 0;
    final List<String> rawParts = _subTasksController.text.split(',');
    List<SubTask> subTasks = [];
    for (int i = 0; i < rawParts.length; i++) {
      final String part = rawParts[i].trim();
      if (part != '') {
        subTasks.add(SubTask(id: _newId('subtask'), title: part, position: i));
      }
    }
    final String rawTitle = _titleController.text.trim();
    final TaskTemplate template = TaskTemplate(
      id: _editingTemplateId != null ? _editingTemplateId! : _newId('template'),
      userId: MockData.users.first.id,
      title: rawTitle == '' ? 'Untitled' : rawTitle,
      label: _selectedLabel,
      expectedDuration: Duration(minutes: minutes),
      subTasks: subTasks,
      taskFolderId: _selectedFolderId,
    );
    setState(() {
      if (_editingTemplateId == null) {
        _templates.add(template);
      } else {
        for (int i = 0; i < _templates.length; i++) {
          if (_templates[i].id == _editingTemplateId) {
            _templates[i] = template;
            break;
          }
        }
      }
      _activeEditor = '';
    });
  }

  void _saveHabit() {
    final int mask = int.tryParse(_maskController.text.trim()) ?? 0;
    final String rawTitle = _habitTitleController.text.trim();
    final Habit habit = Habit(
      id: _editingHabitId != null ? _editingHabitId! : _newId('habit'),
      userId: MockData.users.first.id,
      title: rawTitle == '' ? 'Untitled' : rawTitle,
      label: _habitSelectedLabel,
      recurrenceMask: mask,
      currentStreak: 0,
    );
    setState(() {
      if (_editingHabitId == null) {
        _habits.add(habit);
      } else {
        for (int i = 0; i < _habits.length; i++) {
          if (_habits[i].id == _editingHabitId) {
            _habits[i] = habit;
            break;
          }
        }
      }
      _activeEditor = '';
    });
  }

  void _saveFolder() {
    final String rawTitle = _folderTitleController.text.trim();
    final TaskFolder folder = TaskFolder(
      id: _editingFolderId != null ? _editingFolderId! : _newId('folder'),
      userId: MockData.users.first.id,
      title: rawTitle == '' ? 'Untitled' : rawTitle,
    );
    setState(() {
      if (_editingFolderId == null) {
        _folders.add(folder);
      } else {
        for (int i = 0; i < _folders.length; i++) {
          if (_folders[i].id == _editingFolderId) {
            _folders[i] = folder;
            break;
          }
        }
      }
      _activeEditor = '';
    });
  }

  void _deleteTemplate(String id) {
    setState(() {
      for (int i = _templates.length - 1; i >= 0; i--) {
        if (_templates[i].id == id) {
          _templates.removeAt(i);
        }
      }
    });
  }

  void _deleteHabit(String id) {
    setState(() {
      for (int i = _habits.length - 1; i >= 0; i--) {
        if (_habits[i].id == id) {
          _habits.removeAt(i);
        }
      }
    });
  }

  void _deleteFolder(String id) {
    setState(() {
      for (int i = _folders.length - 1; i >= 0; i--) {
        if (_folders[i].id == id) {
          _folders.removeAt(i);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bodyChildren = [];
    _addActiveEditor(bodyChildren);
    _addLibrarySection(
      bodyChildren,
      'Task Templates',
      _openNewTemplate,
      _buildTemplateCards(),
    );
    _addLibrarySection(
      bodyChildren,
      'Habits',
      _openNewHabit,
      _buildHabitCards(),
    );
    _addLibrarySection(
      bodyChildren,
      'Task Folders',
      _openNewFolder,
      _buildFolderCards(),
    );
    bodyChildren.add(_buildSystemNote());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: bodyChildren),
    );
  }
}
