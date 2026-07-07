import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:youmi_dev/core/utils.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';
import 'package:youmi_dev/providers/app_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/style/common_widgets.dart';
import 'package:youmi_dev/style/label_style.dart';
import 'package:youmi_dev/style/paper_widgets.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _subTasksController.dispose();
    _habitTitleController.dispose();
    _maskController.dispose();
    _folderTitleController.dispose();
    super.dispose();
  }

  String _newId() {
    return _uuid.v4();
  }

  void _openTemplateEditor(TaskTemplate? existing) {
    if (existing != null) {
      _editingTemplateId = existing.id;
      _titleController.text = existing.title;
      _durationController.text = existing.expectedDuration.inMinutes.toString();
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
      _selectedFolderId = _validFolderId(existing.taskFolderId);
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
    final String rawTitle = _titleController.text.trim();
    if (rawTitle.isEmpty) {
      _showMessage('Give the template a title.');
      return;
    }
    int minutes = 0;
    final int? parsedMinutes = int.tryParse(_durationController.text.trim());
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
    String templateId = _newId();
    if (_editingTemplateId != null) {
      templateId = _editingTemplateId!;
    }
    final TaskTemplate template = TaskTemplate(
      id: templateId,
      userId: userId,
      title: rawTitle,
      label: _selectedLabel,
      expectedDuration: Duration(minutes: minutes),
      subTasks: subTasks,
      taskFolderId: _selectedFolderId,
    );
    try {
      await _blueprint(context).saveTemplate(template);
      if (!mounted) {
        return;
      }
      setState(() {
        _activeEditor = '';
      });
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _saveHabit() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    final String rawTitle = _habitTitleController.text.trim();
    if (rawTitle.isEmpty) {
      _showMessage('Give the habit a title.');
      return;
    }
    int mask = 0;
    final int? parsedMask = int.tryParse(_maskController.text.trim());
    if (parsedMask != null) {
      mask = parsedMask;
    }
    String habitId = _newId();
    if (_editingHabitId != null) {
      habitId = _editingHabitId!;
    }
    final Habit habit = Habit(
      id: habitId,
      userId: userId,
      title: rawTitle,
      label: _habitSelectedLabel,
      recurrenceMask: mask,
      currentStreak: 0,
    );
    try {
      await _blueprint(context).saveHabit(habit);
      if (!mounted) {
        return;
      }
      setState(() {
        _activeEditor = '';
      });
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _saveFolder() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    final String rawTitle = _folderTitleController.text.trim();
    if (rawTitle.isEmpty) {
      _showMessage('Give the folder a title.');
      return;
    }
    String folderId = _newId();
    if (_editingFolderId != null) {
      folderId = _editingFolderId!;
    }
    final TaskFolder folder = TaskFolder(
      id: folderId,
      userId: userId,
      title: rawTitle,
    );
    try {
      await _blueprint(context).saveFolder(folder);
      if (!mounted) {
        return;
      }
      setState(() {
        _activeEditor = '';
      });
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  Future<void> _deleteTemplate(TaskTemplate template) async {
    final bool confirmed = await confirmDelete(
      context,
      itemName: template.title,
      itemLabel: 'template',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _blueprint(context).deleteTemplate(template.id);
  }

  Future<void> _deleteHabit(Habit habit) async {
    final bool confirmed = await confirmDelete(
      context,
      itemName: habit.title,
      itemLabel: 'habit',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _blueprint(context).deleteHabit(habit.id);
  }

  Future<void> _deleteFolder(TaskFolder folder) async {
    final bool confirmed = await confirmDelete(
      context,
      itemName: folder.title,
      itemLabel: 'folder',
    );
    if (!confirmed || !mounted) {
      return;
    }
    await _blueprint(context).deleteFolder(folder.id);
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

  String? _validFolderId(String? folderId) {
    if (folderId == null) {
      return null;
    }
    final folders = Provider.of<BlueprintProvider>(
      context,
      listen: false,
    ).folders;
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].id == folderId) {
        return folderId;
      }
    }
    return null;
  }

  String? _defaultFolderId() {
    final folders = Provider.of<BlueprintProvider>(
      context,
      listen: false,
    ).folders;
    if (folders.isEmpty) {
      return null;
    }
    return folders.first.id;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    if (blueprint.lastError != null) {
      bodyChildren.add(
        ErrorBanner(
          message: blueprint.lastError!,
          onRetry: () {
            final user = Provider.of<AppProvider>(context, listen: false).currentUser;
            if (user != null) {
              _blueprint(context).loadForUser(user.id);
            }
          },
        ),
      );
    }
    _addActiveEditor(bodyChildren);
    _addLibrarySection(
      bodyChildren,
      'Task Templates',
      _openNewTemplate,
      _buildTemplateCards(templates, folders),
      emptyIcon: Icons.description_outlined,
      emptyMessage: 'No templates yet. Tap + to create one.',
    );
    _addLibrarySection(
      bodyChildren,
      'Habits',
      _openNewHabit,
      _buildHabitCards(habits),
      emptyIcon: Icons.self_improvement_rounded,
      emptyMessage: 'No habits yet. Tap + to create one.',
    );
    _addLibrarySection(
      bodyChildren,
      'Task Folders',
      _openNewFolder,
      _buildFolderCards(folders),
      emptyIcon: Icons.folder_outlined,
      emptyMessage: 'No folders yet. Tap + to create one.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        automaticallyImplyLeading: false,
      ),
      body: RuledPage(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: bodyChildren,
        ),
      ),
    );
  }
}