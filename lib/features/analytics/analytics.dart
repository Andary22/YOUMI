import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/habit.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/providers/analytics_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';

part 'analytics_widgets.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analytics = context.watch<AnalyticsProvider>();
    final blueprint = context.watch<BlueprintProvider>();
    List<Widget> sections = [];

    sections.add(
      _section(context, 'Filters', _buildFilters(context, analytics)),
    );
    sections.add(
      _section(
        context,
        'Completion by label',
        _buildCompletionChart(theme, analytics.completionCountsByLabel),
      ),
    );
    sections.add(
      _section(
        context,
        'Duration accuracy',
        _buildDurationChart(theme, analytics.durationStatsByLabel),
      ),
    );
    sections.add(
      _section(
        context,
        'Habit streaks',
        _buildHabitsStreak(theme, blueprint.habits),
      ),
    );
    sections.add(
      _section(
        context,
        'Execution log',
        _buildExecutionLog(context, theme, blueprint, analytics.completedItems),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: sections,
      ),
    );
  }
}
