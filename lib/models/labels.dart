enum TaskLabel { work, health, mindfulness, freeTime }

TaskLabel taskLabelFromDb(String value) {
  return TaskLabel.values.firstWhere((label) => label.name == value);
}

String taskLabelToDb(TaskLabel label) {
  return label.name;
}
