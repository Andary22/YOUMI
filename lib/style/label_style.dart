// Centralized look-and-feel for TaskLabel across every screen: one place
// to change the icon/color/display name mapping instead of duplicating
// switch statements in dashboard, planner, library, and analytics.
import 'package:flutter/material.dart';
import 'package:youmi_dev/models/labels.dart';

class LabelStyle {
  final IconData icon;
  final Color color;
  final String displayName;

  const LabelStyle({
    required this.icon,
    required this.color,
    required this.displayName,
  });
}

LabelStyle labelStyleFor(TaskLabel label, ColorScheme scheme) {
  switch (label) {
    case TaskLabel.work:
      return LabelStyle(
        icon: Icons.work_outline_rounded,
        color: scheme.primary,
        displayName: 'Work',
      );
    case TaskLabel.health:
      return const LabelStyle(
        icon: Icons.favorite_outline_rounded,
        color: Color(0xFFE0665C),
        displayName: 'Health',
      );
    case TaskLabel.mindfulness:
      return const LabelStyle(
        icon: Icons.self_improvement_rounded,
        color: Color(0xFF9C7CD4),
        displayName: 'Mindfulness',
      );
    case TaskLabel.freeTime:
      return const LabelStyle(
        icon: Icons.wb_sunny_outlined,
        color: Color(0xFFD9A441),
        displayName: 'Free Time',
      );
  }
}

/// Small rounded pill showing a label's icon + name, used on task and habit
/// cards throughout the app.
class LabelChip extends StatelessWidget {
  final TaskLabel label;
  final bool dense;

  const LabelChip({super.key, required this.label, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = labelStyleFor(label, scheme);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: dense ? 12 : 13, color: style.color),
          const SizedBox(width: 4),
          Text(
            style.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: style.color,
                ),
          ),
        ],
      ),
    );
  }
}