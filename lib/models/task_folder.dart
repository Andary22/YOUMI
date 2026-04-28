class TaskFolder {
  final String id;
  final String userId;
  final String title;

  const TaskFolder({
    required this.id,
    required this.userId,
    required this.title,
  });

  factory TaskFolder.fromJson(Map<String, dynamic> json) {
    return TaskFolder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_id': userId, 'title': title};
  }
}
