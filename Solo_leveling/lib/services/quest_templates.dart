class QuestTemplate {
  final String title;
  final String description;
  final int xpReward;

  const QuestTemplate({
    required this.title,
    required this.description,
    required this.xpReward,
  });
}

class QuestTemplates {
  static const List<QuestTemplate> daily = [
    QuestTemplate(
      title: 'MORNING ACTIVATION',
      description: 'Complete your morning routine.',
      xpReward: 50,
    ),
    QuestTemplate(
      title: 'STRENGTH TRAINING',
      description: 'Complete a physical training session.',
      xpReward: 80,
    ),
    QuestTemplate(
      title: 'FOCUS SESSION',
      description: 'Complete 30 minutes of uninterrupted focused work.',
      xpReward: 80,
    ),
    QuestTemplate(
      title: 'DISCIPLINE TRIAL',
      description: 'Complete one task you have been postponing.',
      xpReward: 70,
    ),
    QuestTemplate(
      title: 'KNOWLEDGE TRAINING',
      description: 'Spend 30 minutes learning something useful.',
      xpReward: 70,
    ),
    QuestTemplate(
      title: 'VITALITY TRAINING',
      description: 'Complete a physical activity session.',
      xpReward: 60,
    ),
    QuestTemplate(
      title: 'DEEP WORK',
      description: 'Complete 45 minutes of uninterrupted work.',
      xpReward: 100,
    ),
    QuestTemplate(
      title: 'SYSTEM ORDER',
      description: 'Clean and organize your immediate environment.',
      xpReward: 50,
    ),
    QuestTemplate(
      title: 'FOCUS TRIAL',
      description: 'Complete one important task without distractions.',
      xpReward: 90,
    ),
    QuestTemplate(
      title: 'ENDURANCE TRIAL',
      description: 'Complete an additional physical activity session.',
      xpReward: 90,
    ),
  ];
}