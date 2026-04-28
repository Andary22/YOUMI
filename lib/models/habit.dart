import 'package:youmi_dev/models/labels.dart';

class Habit {
  final String id;
  final String userId;
  final String title;
  final TaskLabel label;
  final int recurrenceMask;
  final int currentStreak;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.label,
    required this.recurrenceMask,
    required this.currentStreak,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      label: taskLabelFromDb(json['label'] as String),
      recurrenceMask: json['recurrence_mask'] as int,
      currentStreak: json['current_streak'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'label': taskLabelToDb(label),
      'recurrence_mask': recurrenceMask,
      'current_streak': currentStreak,
    };
  }
}
