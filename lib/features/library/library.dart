import 'package:flutter/material.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/task_folder.dart';
import 'package:youmi_dev/models/task_template.dart';
import 'package:youmi_dev/models/habit.dart';

class LibraryView extends StatefulWidget {
  const LibraryView({super.key});

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  late List<TaskTemplate> _templates;
  late List<Habit> _habits;
  late List<TaskFolder> _folders;

  @override
  void initState() {
    super.initState();
    _templates = List<TaskTemplate>.from(MockData.taskTemplates);
    _habits = List<Habit>.from(MockData.habits);
    _folders = List<TaskFolder>.from(MockData.taskFolders);
  }

  String _newId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> _showTaskTemplateEditor({TaskTemplate? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final durationController = TextEditingController(
      text: existing == null
          ? ''
          : (existing.expectedDuration.inMinutes).toString(),
    );
    final subTasksController = TextEditingController(
      text: existing == null
          ? ''
          : existing.subTasks.map((s) => s.title).join(', '),
    );
    TaskLabel label = existing?.label ?? TaskLabel.work;
    String? folderId =
        existing?.taskFolderId ??
        (_folders.isNotEmpty ? _folders.first.id : null);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'New Template' : 'Edit Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskLabel>(
                  value: label,
                  decoration: const InputDecoration(labelText: 'Label'),
                  items: TaskLabel.values
                      .map(
                        (l) => DropdownMenuItem(value: l, child: Text(l.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) label = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Expected duration (minutes)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: folderId,
                  decoration: const InputDecoration(labelText: 'Folder'),
                  items: _folders
                      .map(
                        (f) =>
                            DropdownMenuItem(value: f.id, child: Text(f.title)),
                      )
                      .toList(),
                  onChanged: (value) => folderId = value,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subTasksController,
                  decoration: const InputDecoration(
                    labelText: 'Sub-tasks (comma separated)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    final minutes = int.tryParse(durationController.text.trim()) ?? 0;
    final rawSubTasks = subTasksController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final subTasks = rawSubTasks
        .asMap()
        .entries
        .map(
          (entry) => SubTask(
            id: _newId('subtask'),
            title: entry.value,
            position: entry.key,
          ),
        )
        .toList();

    setState(() {
      final template = TaskTemplate(
        id: existing?.id ?? _newId('template'),
        userId: existing?.userId ?? MockData.users.first.id,
        title: titleController.text.trim().isEmpty
            ? 'Untitled'
            : titleController.text.trim(),
        label: label,
        expectedDuration: Duration(minutes: minutes),
        subTasks: subTasks,
        taskFolderId: folderId,
      );

      if (existing == null) {
        _templates.add(template);
      } else {
        final index = _templates.indexWhere((t) => t.id == existing.id);
        if (index >= 0) _templates[index] = template;
      }
    });
  }

  Future<void> _showHabitEditor({Habit? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final maskController = TextEditingController(
      text: existing == null ? '' : existing.recurrenceMask.toString(),
    );
    TaskLabel label = existing?.label ?? TaskLabel.health;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'New Habit' : 'Edit Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskLabel>(
                  value: label,
                  decoration: const InputDecoration(labelText: 'Label'),
                  items: TaskLabel.values
                      .map(
                        (l) => DropdownMenuItem(value: l, child: Text(l.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) label = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: maskController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence mask (bitmask)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    final mask = int.tryParse(maskController.text.trim()) ?? 0;

    setState(() {
      final habit = Habit(
        id: existing?.id ?? _newId('habit'),
        userId: existing?.userId ?? MockData.users.first.id,
        title: titleController.text.trim().isEmpty
            ? 'Untitled'
            : titleController.text.trim(),
        label: label,
        recurrenceMask: mask,
        currentStreak: existing?.currentStreak ?? 0,
      );

      if (existing == null) {
        _habits.add(habit);
      } else {
        final index = _habits.indexWhere((h) => h.id == existing.id);
        if (index >= 0) _habits[index] = habit;
      }
    });
  }

  Future<void> _showFolderEditor({TaskFolder? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'New Folder' : 'Edit Folder'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    setState(() {
      final folder = TaskFolder(
        id: existing?.id ?? _newId('folder'),
        userId: existing?.userId ?? MockData.users.first.id,
        title: titleController.text.trim().isEmpty
            ? 'Untitled'
            : titleController.text.trim(),
      );

      if (existing == null) {
        _folders.add(folder);
      } else {
        final index = _folders.indexWhere((f) => f.id == existing.id);
        if (index >= 0) _folders[index] = folder;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(
            title: 'Task Templates',
            onAdd: () => _showTaskTemplateEditor(),
          ),
          const SizedBox(height: 8),
          ..._templates.map((template) {
            final folderTitle = _folders
                .firstWhere(
                  (f) => f.id == template.taskFolderId,
                  orElse: () => _folders.isNotEmpty
                      ? _folders.first
                      : TaskFolder(
                          id: 'none',
                          userId: 'none',
                          title: 'No Folder',
                        ),
                )
                .title;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(template.title),
                subtitle: Text(
                  '${template.label.name} · ${template.expectedDuration.inMinutes} min · $folderTitle',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showTaskTemplateEditor(existing: template),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _templates.removeWhere((t) => t.id == template.id);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          _SectionHeader(title: 'Habits', onAdd: () => _showHabitEditor()),
          const SizedBox(height: 8),
          ..._habits.map((habit) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(habit.title),
                subtitle: Text(
                  '${habit.label.name} · mask ${habit.recurrenceMask}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showHabitEditor(existing: habit),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _habits.removeWhere((h) => h.id == habit.id);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          _SectionHeader(
            title: 'Task Folders',
            onAdd: () => _showFolderEditor(),
          ),
          const SizedBox(height: 8),
          ..._folders.map((folder) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(folder.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showFolderEditor(existing: folder),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _folders.removeWhere((f) => f.id == folder.id);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('System Note'),
                  SizedBox(height: 6),
                  Text(
                    'Future activity instances are generated automatically when habit recurrence masks change.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        IconButton(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
