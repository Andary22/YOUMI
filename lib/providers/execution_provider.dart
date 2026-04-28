// ExecutionProvider: activity instance queries and execution state updates.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/models/activity_instance.dart';
import 'package:youmi_dev/models/mock_data.dart';

class ExecutionProvider extends ChangeNotifier {
  final List<ActivityInstance> _items = List<ActivityInstance>.unmodifiable(
    MockData.activityInstances,
  );

  List<ActivityInstance> get items => _items;

  List<ActivityInstance> itemsForDate(DateTime date) {
    return _items
        .where((item) => _isSameDay(item.scheduledDate, date))
        .toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
