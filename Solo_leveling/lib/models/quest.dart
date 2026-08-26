class Quest {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final String date;
  bool completed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.date,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'date': date,
      'completed': completed,
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    return Quest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      xpReward: map['xpReward'] as int,
      date: map['date'] as String,
      completed: map['completed'] as bool? ?? false,
    );
  }
}