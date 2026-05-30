enum TaskLabel { work, health, mindfulness, freeTime }

TaskLabel taskLabelFromDb(String value) {
  for (int i = 0; i < TaskLabel.values.length; i++) {
    final label = TaskLabel.values[i];
    if (label.name == value) {
      return label;
    }
  }
  return TaskLabel.work;
}

String taskLabelToDb(TaskLabel label) {
  return label.name;
}
