part of 'library.dart';

extension _LibraryWidgets on _LibraryViewState {
  void _addActiveEditor(List<Widget> bodyChildren) {
    if (_activeEditor == 'template') {
      bodyChildren.add(_buildTemplateForm());
      bodyChildren.add(const SizedBox(height: 20));
    }
    if (_activeEditor == 'habit') {
      bodyChildren.add(_buildHabitForm());
      bodyChildren.add(const SizedBox(height: 20));
    }
    if (_activeEditor == 'folder') {
      bodyChildren.add(_buildFolderForm());
      bodyChildren.add(const SizedBox(height: 20));
    }
  }

  void _addLibrarySection(
    List<Widget> bodyChildren,
    String title,
    void Function() onAdd,
    List<Widget> cards, {
    required IconData emptyIcon,
    required String emptyMessage,
  }) {
    bodyChildren.add(_buildSectionHeader(title, onAdd));
    bodyChildren.add(const SizedBox(height: 10));
    if (cards.isEmpty) {
      bodyChildren.add(
        EmptyState(icon: emptyIcon, title: '', message: emptyMessage),
      );
    } else {
      bodyChildren.addAll(cards);
    }
    bodyChildren.add(const SizedBox(height: 24));
  }

  Widget _buildLabelSelector(
    TaskLabel selected,
    void Function(TaskLabel) onSelected,
  ) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskLabel.values.map((label) {
        final style = labelStyleFor(label, theme.colorScheme);
        final bool isSelected = label == selected;
        return ChoiceChip(
          selected: isSelected,
          onSelected: (_) {
            onSelected(label);
          },
          avatar: Icon(
            style.icon,
            size: 16,
            color: isSelected ? theme.colorScheme.primary : style.color,
          ),
          label: Text(style.displayName),
        );
      }).toList(),
    );
  }

  Widget _buildTemplateForm() {
    String titleText = 'New Template';
    if (_editingTemplateId != null) {
      titleText = 'Edit Template';
    }
    return _EditorCard(
      title: titleText,
      onClose: _closeEditor,
      children: [
        TextField(
          controller: _titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.title_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Text('Label', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        _buildLabelSelector(_selectedLabel, _setSelectedLabel),
        const SizedBox(height: 16),
        TextField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Expected duration (minutes)',
            prefixIcon: Icon(Icons.timer_outlined),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          key: ValueKey(
            'template-folder-$_editingTemplateId-$_selectedFolderId',
          ),
          initialValue: _selectedFolderId,
          decoration: const InputDecoration(
            labelText: 'Folder',
            prefixIcon: Icon(Icons.folder_outlined),
          ),
          items: _folderItems(),
          onChanged: _setSelectedFolderId,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _subTasksController,
          decoration: const InputDecoration(
            labelText: 'Sub-tasks (comma separated)',
            prefixIcon: Icon(Icons.checklist_outlined),
          ),
        ),
        _formActions(_saveTemplate),
      ],
    );
  }

  Widget _buildHabitForm() {
    String titleText = 'New Habit';
    if (_editingHabitId != null) {
      titleText = 'Edit Habit';
    }
    final theme = Theme.of(context);
    final List<String> dayLabels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return _EditorCard(
      title: titleText,
      onClose: _closeEditor,
      children: [
        TextField(
          controller: _habitTitleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.title_outlined),
          ),
        ),
        const SizedBox(height: 16),
        Text('Label', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        _buildLabelSelector(_habitSelectedLabel, _setHabitSelectedLabel),
        const SizedBox(height: 16),
        Text('Repeat on', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setLocalState) {
            int mask = 0;
            final int? pm = int.tryParse(_maskController.text.trim());
            if (pm != null) {
              mask = pm;
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (i) {
                final int bit = 1 << i;
                final bool selected = (mask & bit) != 0;
                return FilterChip(
                  label: Text(dayLabels[i]),
                  selected: selected,
                  onSelected: (val) {
                    int newMask = mask;
                    if (val) {
                      newMask = newMask | bit;
                    } else {
                      newMask = newMask & ~bit;
                    }
                    _maskController.text = newMask.toString();
                    setLocalState(() {});
                  },
                );
              }),
            );
          },
        ),
        _formActions(_saveHabit),
      ],
    );
  }

  Widget _buildFolderForm() {
    String titleText = 'New Folder';
    if (_editingFolderId != null) {
      titleText = 'Edit Folder';
    }
    return _EditorCard(
      title: titleText,
      onClose: _closeEditor,
      children: [
        TextField(
          controller: _folderTitleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.folder_outlined),
          ),
        ),
        _formActions(_saveFolder),
      ],
    );
  }

  List<DropdownMenuItem<String?>> _folderItems() {
    List<DropdownMenuItem<String?>> items = [];
    final folders = Provider.of<BlueprintProvider>(
      context,
      listen: false,
    ).folders;
    items.add(const DropdownMenuItem(value: null, child: Text('No folder')));
    for (int i = 0; i < folders.length; i++) {
      final folder = folders[i];
      items.add(DropdownMenuItem(value: folder.id, child: Text(folder.title)));
    }
    return items;
  }

  Widget _formActions(void Function() onSave) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: _closeEditor, child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: onSave, child: const Text('Save')),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, void Function() onAdd) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        FilledButton.tonalIcon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New'),
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
          label: template.label,
          subtitle:
              '${template.expectedDuration.inMinutes} min · ${_folderTitleFor(template, folders)}',
          onEdit: () {
            _openTemplateEditor(template);
          },
          onDelete: () {
            _deleteTemplate(template);
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
          label: habit.label,
          subtitle:
              '${formatRecurrenceMask(habit.recurrenceMask)} · ${habit.currentStreak}d streak',
          onEdit: () {
            _openHabitEditor(habit);
          },
          onDelete: () {
            _deleteHabit(habit);
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
            _deleteFolder(folder);
          },
        ),
      );
    }
    return cards;
  }
}

class _EditorCard extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final List<Widget> children;

  const _EditorCard({
    required this.title,
    required this.onClose,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final TaskLabel? label;
  final String? subtitle;
  final void Function() onEdit;
  final void Function() onDelete;

  const _LibraryCard({
    required this.title,
    this.label,
    this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget? subtitleWidget;
    if (subtitle != null) {
      subtitleWidget = Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    Widget leading;
    if (label != null) {
      final style = labelStyleFor(label!, theme.colorScheme);
      leading = CircleAvatar(
        backgroundColor: style.color.withValues(alpha: 0.14),
        foregroundColor: style.color,
        child: Icon(style.icon, size: 18),
      );
    } else {
      leading = CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        child: const Icon(Icons.folder_outlined, size: 18),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: leading,
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: subtitleWidget,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: theme.colorScheme.error,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
