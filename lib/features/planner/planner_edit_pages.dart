part of 'planner.dart';

class _QuickAddResult {
  final String type;
  final dynamic template;
  final dynamic habit;

  _QuickAddResult({required this.type, this.template, this.habit});
}

class _QuickAddPage extends StatelessWidget {
  final List<dynamic> templates;
  final List<dynamic> habits;
  final String Function(TaskLabel) labelText;

  const _QuickAddPage({
    required this.templates,
    required this.habits,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> children = [];
    children.add(Text('Templates', style: theme.textTheme.titleMedium));
    children.add(const SizedBox(height: 8));
    if (templates.isEmpty) {
      children.add(
        const EmptyState(
          icon: Icons.description_outlined,
          title: 'No templates yet',
          message: 'Create task templates from the Library tab.',
        ),
      );
    }
    for (int i = 0; i < templates.length; i++) {
      final template = templates[i];
      final style = labelStyleFor(template.label as TaskLabel, theme.colorScheme);
      children.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: style.color.withValues(alpha: 0.14),
              foregroundColor: style.color,
              child: Icon(style.icon, size: 18),
            ),
            title: Text(template.title as String),
            subtitle: Text(labelText(template.label as TaskLabel)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(
                context,
                _QuickAddResult(type: 'template', template: template),
              );
            },
          ),
        ),
      );
    }
    children.add(const SizedBox(height: 16));
    children.add(Text('Habits', style: theme.textTheme.titleMedium));
    children.add(const SizedBox(height: 8));
    if (habits.isEmpty) {
      children.add(
        const EmptyState(
          icon: Icons.self_improvement_rounded,
          title: 'No habits yet',
          message: 'Create habits from the Library tab.',
        ),
      );
    }
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final style = labelStyleFor(habit.label as TaskLabel, theme.colorScheme);
      children.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: style.color.withValues(alpha: 0.14),
              foregroundColor: style.color,
              child: Icon(style.icon, size: 18),
            ),
            title: Text(habit.title as String),
            subtitle: Text(labelText(habit.label as TaskLabel)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.pop(
                context,
                _QuickAddResult(type: 'habit', habit: habit),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Add')),
      body: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}

class _NoteEditorPage extends StatefulWidget {
  final String initialNote;

  const _NoteEditorPage({required this.initialNote});

  @override
  State<_NoteEditorPage> createState() {
    return _NoteEditorPageState();
  }
}

class _NoteEditorPageState extends State<_NoteEditorPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Add a note'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final trimmed = _controller.text.trim();
                if (trimmed.isEmpty) {
                  Navigator.pop(context, null);
                } else {
                  Navigator.pop(context, trimmed);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelPickerPage extends StatelessWidget {
  final String Function(TaskLabel) labelText;

  const _LabelPickerPage({required this.labelText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> children = [];
    children.add(Text('Select Label', style: theme.textTheme.titleMedium));
    children.add(const SizedBox(height: 8));
    for (int i = 0; i < TaskLabel.values.length; i++) {
      final label = TaskLabel.values[i];
      final style = labelStyleFor(label, theme.colorScheme);
      children.add(
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: style.color.withValues(alpha: 0.14),
              foregroundColor: style.color,
              child: Icon(style.icon, size: 18),
            ),
            title: Text(labelText(label)),
            onTap: () {
              Navigator.pop(context, label);
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Label')),
      body: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}