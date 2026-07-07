import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youmi_dev/models/labels.dart';
import 'package:youmi_dev/providers/analytics_provider.dart';
import 'package:youmi_dev/providers/blueprint_provider.dart';
import 'package:youmi_dev/style/common_widgets.dart';
import 'package:youmi_dev/style/label_style.dart';
import 'package:youmi_dev/style/paper_widgets.dart';

part 'analytics_widgets.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  Future<void> _pickRange(BuildContext context) async {
    final analytics = Provider.of<AnalyticsProvider>(context, listen: false);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: analytics.range,
    );
    if (picked != null) {
      analytics.setDateRange(picked);
    }
  }

  String _formatRange(DateTimeRange range) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String fmt(DateTime d) {
      return '${months[d.month - 1]} ${d.day}';
    }
    return '${fmt(range.start)} – ${fmt(range.end)}';
  }

  String _labelText(TaskLabel label) {
    final raw = label.name.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) {
      return '${m.group(1)} ${m.group(2)}';
    });
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) {
      return '${d.inMinutes}m';
    }
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${mins}m';
  }

  String _formatItemDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            onPressed: () {
              _pickRange(context);
            },
          ),
        ],
      ),
      body: RuledPage(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRangeAndFilterRow(context, analytics),
            const SizedBox(height: 20),
            _buildSummaryCard(context, analytics),
            const SizedBox(height: 20),
            _buildCompletionCard(context, analytics),
            const SizedBox(height: 20),
            _buildDurationCard(context, analytics),
            const SizedBox(height: 20),
            _buildExecutionLog(context, analytics),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}