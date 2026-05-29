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
        existing?.taskFolderId ?? _defaultFolderId();
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

  Future<void> _saveTemplate() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    final int minutes = int.tryParse(_durationController.text.trim()) ?? 0;
    final List<String> rawParts = _subTasksController.text.split(',');
    List<SubTask> subTasks = [];
    for (int i = 0; i < rawParts.length; i++) {
      final String part = rawParts[i].trim();
      if (part != '') {
        subTasks.add(SubTask(id: _newId(), title: part, position: i));
      }
    }
    final String rawTitle = _titleController.text.trim();
    final TaskTemplate template = TaskTemplate(
      id: _editingTemplateId != null ? _editingTemplateId! : _newId(),
      userId: userId,
      title: rawTitle == '' ? 'Untitled' : rawTitle,
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
    final int mask = int.tryParse(_maskController.text.trim()) ?? 0;
    final String rawTitle = _habitTitleController.text.trim();
    final Habit habit = Habit(
      id: _editingHabitId != null ? _editingHabitId! : _newId(),
      userId: userId,
      title: rawTitle == '' ? 'Untitled' : rawTitle,
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
    final TaskFolder folder = TaskFolder(
      id: _editingFolderId != null ? _editingFolderId! : _newId(),
      userId: userId,
      title: rawTitle == '' ? 'Untitled' : rawTitle,
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
    return Provider.of<AppProvider>(context, listen: false).currentUser?.id;
  }

  String? _defaultFolderId() {
    final folders = Provider.of<BlueprintProvider>(context, listen: false).folders;
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
