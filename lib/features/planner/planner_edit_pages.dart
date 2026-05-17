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
    for (int i = 0; i < templates.length; i++) {
      final template = templates[i];
      children.add(
        ListTile(
          title: Text(template.title),
          subtitle: Text(labelText(template.label)),
          onTap: () {
            Navigator.pop(
              context,
              _QuickAddResult(type: 'template', template: template),
            );
          },
        ),
      );
    }
    children.add(const SizedBox(height: 16));
    children.add(Text('Habits', style: theme.textTheme.titleMedium));
    children.add(const SizedBox(height: 8));
    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      children.add(
        ListTile(
          title: Text(habit.title),
          subtitle: Text(labelText(habit.label)),
          onTap: () {
            Navigator.pop(
              context,
              _QuickAddResult(type: 'habit', habit: habit),
            );
          },
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Add a note'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final trimmed = _controller.text.trim();
                Navigator.pop(context, trimmed.isEmpty ? null : trimmed);
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
      children.add(
        ListTile(
          title: Text(labelText(label)),
          onTap: () {
            Navigator.pop(context, label);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Label')),
      body: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}
