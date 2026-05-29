part of 'library.dart';

extension _LibraryWidgets on _LibraryViewState {
  void _addActiveEditor(List<Widget> bodyChildren) {
    if (_activeEditor == 'template') {
      bodyChildren.add(_buildTemplateForm());
      bodyChildren.add(const SizedBox(height: 16));
    }
    if (_activeEditor == 'habit') {
      bodyChildren.add(_buildHabitForm());
      bodyChildren.add(const SizedBox(height: 16));
    }
    if (_activeEditor == 'folder') {
      bodyChildren.add(_buildFolderForm());
      bodyChildren.add(const SizedBox(height: 16));
    }
  }

  void _addLibrarySection(
    List<Widget> bodyChildren,
    String title,
    void Function() onAdd,
    List<Widget> cards,
  ) {
    bodyChildren.add(_buildSectionHeader(title, onAdd));
    bodyChildren.add(const SizedBox(height: 8));
    bodyChildren.addAll(cards);
    bodyChildren.add(const SizedBox(height: 20));
  }

  Widget _buildTemplateForm() {
    return _EditorCard(
      title: _editingTemplateId == null ? 'New Template' : 'Edit Template',
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<TaskLabel>(
          key: ValueKey('template-label-$_editingTemplateId-$_selectedLabel'),
          initialValue: _selectedLabel,
          decoration: const InputDecoration(labelText: 'Label'),
          items: _labelItems(),
          onChanged: (value) {
            if (value != null) {
              _setSelectedLabel(value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Expected duration (minutes)',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(
            'template-folder-$_editingTemplateId-$_selectedFolderId',
          ),
          initialValue: _selectedFolderId,
          decoration: const InputDecoration(labelText: 'Folder'),
          items: _folderItems(),
          onChanged: _setSelectedFolderId,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _subTasksController,
          decoration: const InputDecoration(
            labelText: 'Sub-tasks (comma separated)',
          ),
        ),
        _formActions(_saveTemplate),
      ],
    );
  }

  Widget _buildHabitForm() {
    return _EditorCard(
      title: _editingHabitId == null ? 'New Habit' : 'Edit Habit',
      children: [
        TextField(
          controller: _habitTitleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<TaskLabel>(
          key: ValueKey('habit-label-$_editingHabitId-$_habitSelectedLabel'),
          initialValue: _habitSelectedLabel,
          decoration: const InputDecoration(labelText: 'Label'),
          items: _labelItems(),
          onChanged: (value) {
            if (value != null) {
              _setHabitSelectedLabel(value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _maskController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Recurrence mask (bitmask)',
          ),
        ),
        _formActions(_saveHabit),
      ],
    );
  }

  Widget _buildFolderForm() {
    return _EditorCard(
      title: _editingFolderId == null ? 'New Folder' : 'Edit Folder',
      children: [
        TextField(
          controller: _folderTitleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        _formActions(_saveFolder),
      ],
    );
  }

  List<DropdownMenuItem<TaskLabel>> _labelItems() {
    List<DropdownMenuItem<TaskLabel>> items = [];
    for (int i = 0; i < TaskLabel.values.length; i++) {
      final label = TaskLabel.values[i];
      items.add(DropdownMenuItem(value: label, child: Text(label.name)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> _folderItems() {
    List<DropdownMenuItem<String>> items = [];
    final folders = Provider.of<BlueprintProvider>(context, listen: false).folders;
    for (int i = 0; i < folders.length; i++) {
      final folder = folders[i];
      items.add(DropdownMenuItem(value: folder.id, child: Text(folder.title)));
    }
    return items;
  }

  Widget _formActions(void Function() onSave) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: _closeEditor, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: onSave, child: const Text('Save')),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, void Function() onAdd) {
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

  List<Widget> _buildTemplateCards(
    List<TaskTemplate> templates,
    List<TaskFolder> folders,
  ) {
    List<Widget> cards = [];
    for (int i = 0; i < templates.length; i++) {
      final template = templates[i];
      cards.add(
        _LibraryCard(
          title: template.title,
          subtitle:
              '${template.label.name} · ${template.expectedDuration.inMinutes} min · ${_folderTitleFor(template, folders)}',
          onEdit: () {
            _openTemplateEditor(template);
          },
          onDelete: () {
            _deleteTemplate(template.id);
          },
        ),
      );
    }
    return cards;
  }

  String _folderTitleFor(TaskTemplate template, List<TaskFolder> folders) {
    String folderTitle = 'No Folder';
    for (int j = 0; j < folders.length; j++) {
      if (folders[j].id == template.taskFolderId) {
        folderTitle = folders[j].title;
        break;
      }
    }
    return folderTitle;
  }

  List<Widget> _buildHabitCards(List<Habit> habits) {
    List<Widget> cards = [];
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      cards.add(
        _LibraryCard(
          title: habit.title,
          subtitle: '${habit.label.name} · mask ${habit.recurrenceMask}',
          onEdit: () {
            _openHabitEditor(habit);
          },
          onDelete: () {
            _deleteHabit(habit.id);
          },
        ),
      );
    }
    return cards;
  }

  List<Widget> _buildFolderCards(List<TaskFolder> folders) {
    List<Widget> cards = [];
    for (int i = 0; i < folders.length; i++) {
      final folder = folders[i];
      cards.add(
        _LibraryCard(
          title: folder.title,
          onEdit: () {
            _openFolderEditor(folder);
          },
          onDelete: () {
            _deleteFolder(folder.id);
          },
        ),
      );
    }
    return cards;
  }

  Widget _buildSystemNote() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('System Note'),
            SizedBox(height: 6),
            Text(
              'Future activity instances are generated automatically '
              'when habit recurrence masks change.',
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _EditorCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    List<Widget> cardChildren = [];
    cardChildren.add(Text(title));
    cardChildren.add(const SizedBox(height: 12));
    cardChildren.addAll(children);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cardChildren,
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final void Function() onEdit;
  final void Function() onDelete;

  const _LibraryCard({
    required this.title,
    this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
