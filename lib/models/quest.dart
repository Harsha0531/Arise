enum QuestType {
  daily,
  side,
  special,
  bonus,
  penalty,
  recovery,
}

enum QuestCategory {
  physical,
  other,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final String date;

  final QuestType type;
  final QuestCategory? category;
  final int difficultyDay;

  bool completed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.date,
    this.type = QuestType.daily,
    this.category,
    this.difficultyDay = 1,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'date': date,
      'type': type.name,
      'category': category?.name,
      'difficultyDay': difficultyDay,
      'completed': completed,
    };
  }

  factory Quest.fromMap(Map<String, dynamic> map) {
    final typeName = map['type'] as String?;
    final categoryName = map['category'] as String?;

    return Quest(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      xpReward: map['xpReward'] as int,
      date: map['date'] as String,
      type: typeName == null
          ? QuestType.daily
          : QuestType.values.firstWhere(
            (value) => value.name == typeName,
        orElse: () => QuestType.daily,
      ),
      category: categoryName == null
          ? null
          : QuestCategory.values.firstWhere(
            (value) => value.name == categoryName,
        orElse: () => QuestCategory.other,
      ),
      difficultyDay:
      map['difficultyDay'] as int? ?? 1,
      completed:
      map['completed'] as bool? ?? false,
    );
  }
}