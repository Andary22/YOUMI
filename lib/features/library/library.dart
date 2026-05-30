import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';

part 'library_widgets.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() {
    return _LibraryViewState();
  }
}

class _LibraryViewState extends State<LibraryView> {
  String _activeEditor = '';
  bool _requestedLoad = false;

  final Uuid _uuid = const Uuid();

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

  String _newId() {
    return _uuid.v4();
  }

  void _openTemplateEditor(TaskTemplate? existing) {
    if (existing != null) {
      _editingTemplateId = existing.id;
      _titleController.text = existing.title;
      _durationController.text =
          existing.expectedDuration.inMinutes.toString();
    } else {
      _editingTemplateId = null;
      _titleController.text = '';
      _durationController.text = '';
    }
    String subStr = '';
    if (existing != null) {
      for (int i = 0; i < existing.subTasks.length; i++) {
        if (i > 0) subStr += ', ';
        subStr += existing.subTasks[i].title;
      }
    }
    _subTasksController.text = subStr;
    if (existing != null) {
      _selectedLabel = existing.label;
      _selectedFolderId = existing.taskFolderId;
    } else {
      _selectedLabel = TaskLabel.work;
      _selectedFolderId = _defaultFolderId();
    }
    setState(() {
      _activeEditor = 'template';
    });
  }

  void _openHabitEditor(Habit? existing) {
    if (existing != null) {
      _editingHabitId = existing.id;
      _habitTitleController.text = existing.title;
      _maskController.text = existing.recurrenceMask.toString();
      _habitSelectedLabel = existing.label;
    } else {
      _editingHabitId = null;
      _habitTitleController.text = '';
      _maskController.text = '';
      _habitSelectedLabel = TaskLabel.health;
    }
    setState(() {
      _activeEditor = 'habit';
    });
  }

  void _openFolderEditor(TaskFolder? existing) {
    if (existing != null) {
      _editingFolderId = existing.id;
      _folderTitleController.text = existing.title;
    } else {
      _editingFolderId = null;
      _folderTitleController.text = '';
    }
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

  Future<void> _saveTemplate() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    int minutes = 0;
    final int? parsedMinutes =
        int.tryParse(_durationController.text.trim());
    if (parsedMinutes != null) {
      minutes = parsedMinutes;
    }
    final List<String> rawParts = _subTasksController.text.split(',');
    List<SubTask> subTasks = [];
    for (int i = 0; i < rawParts.length; i++) {
      final String part = rawParts[i].trim();
      if (part != '') {
        subTasks.add(SubTask(id: _newId(), title: part, position: i));
      }
    }
    final String rawTitle = _titleController.text.trim();
    String templateId = _newId();
    if (_editingTemplateId != null) {
      templateId = _editingTemplateId!;
    }
    String title = rawTitle;
    if (title == '') {
      title = 'Untitled';
    }
    final TaskTemplate template = TaskTemplate(
      id: templateId,
      userId: userId,
      title: title,
      label: _selectedLabel,
      expectedDuration: Duration(minutes: minutes),
      subTasks: subTasks,
      taskFolderId: _selectedFolderId,
    );
    await _blueprint(context).saveTemplate(template);
    setState(() {
      _activeEditor = '';
    });
  }

  Future<void> _saveHabit() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    int mask = 0;
    final int? parsedMask = int.tryParse(_maskController.text.trim());
    if (parsedMask != null) {
      mask = parsedMask;
    }
    final String rawTitle = _habitTitleController.text.trim();
    String habitId = _newId();
    if (_editingHabitId != null) {
      habitId = _editingHabitId!;
    }
    String title = rawTitle;
    if (title == '') {
      title = 'Untitled';
    }
    final Habit habit = Habit(
      id: habitId,
      userId: userId,
      title: title,
      label: _habitSelectedLabel,
      recurrenceMask: mask,
      currentStreak: 0,
    );
    await _blueprint(context).saveHabit(habit);
    setState(() {
      _activeEditor = '';
    });
  }

  Future<void> _saveFolder() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    final String rawTitle = _folderTitleController.text.trim();
    String folderId = _newId();
    if (_editingFolderId != null) {
      folderId = _editingFolderId!;
    }
    String title = rawTitle;
    if (title == '') {
      title = 'Untitled';
    }
    final TaskFolder folder = TaskFolder(
      id: folderId,
      userId: userId,
      title: title,
    );
    await _blueprint(context).saveFolder(folder);
    setState(() {
      _activeEditor = '';
    });
  }

  Future<void> _deleteTemplate(String id) async {
    await _blueprint(context).deleteTemplate(id);
  }

  Future<void> _deleteHabit(String id) async {
    await _blueprint(context).deleteHabit(id);
  }

  Future<void> _deleteFolder(String id) async {
    await _blueprint(context).deleteFolder(id);
  }

  BlueprintProvider _blueprint(BuildContext context) {
    return Provider.of<BlueprintProvider>(context, listen: false);
  }

  String? _currentUserId() {
    final user = Provider.of<AppProvider>(context, listen: false).currentUser;
    if (user != null) {
      return user.id;
    }
    return null;
  }

  String? _defaultFolderId() {
    final folders =
        Provider.of<BlueprintProvider>(context, listen: false).folders;
    if (folders.isEmpty) {
      return null;
    }
    return folders.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppProvider>(context, listen: false);
    final blueprint = Provider.of<BlueprintProvider>(context);
    if (app.currentUser != null && !_requestedLoad) {
      _requestedLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _blueprint(context).loadForUser(app.currentUser!.id);
      });
    }
    final templates = blueprint.templates;
    final habits = blueprint.habits;
    final folders = blueprint.folders;
    List<Widget> bodyChildren = [];
    _addActiveEditor(bodyChildren);
    _addLibrarySection(
      bodyChildren,
      'Task Templates',
      _openNewTemplate,
      _buildTemplateCards(templates, folders),
    );
    _addLibrarySection(
      bodyChildren,
      'Habits',
      _openNewHabit,
      _buildHabitCards(habits),
    );
    _addLibrarySection(
      bodyChildren,
      'Task Folders',
      _openNewFolder,
      _buildFolderCards(folders),
    );
    bodyChildren.add(_buildSystemNote());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: bodyChildren),
    );
  }
}
