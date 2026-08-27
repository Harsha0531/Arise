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
  // ------------------------------------------------------------
  // 3 PHYSICAL DAILY QUESTS
  // ------------------------------------------------------------

  static const List<QuestTemplate> physical = [
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
      title: 'VITALITY TRAINING',
      description: 'Complete a physical activity session.',
      xpReward: 60,
    ),
    QuestTemplate(
      title: 'ENDURANCE TRIAL',
      description: 'Complete an additional physical activity session.',
      xpReward: 90,
    ),
  ];

  // ------------------------------------------------------------
  // 2 OTHER DAILY QUESTS
  // ------------------------------------------------------------

  static const List<QuestTemplate> other = [
    QuestTemplate(
      title: 'FOCUS SESSION',
      description:
      'Complete 30 minutes of uninterrupted focused work.',
      xpReward: 80,
    ),
    QuestTemplate(
      title: 'DISCIPLINE TRIAL',
      description:
      'Complete one task you have been postponing.',
      xpReward: 70,
    ),
    QuestTemplate(
      title: 'KNOWLEDGE TRAINING',
      description:
      'Spend 30 minutes learning something useful.',
      xpReward: 70,
    ),
    QuestTemplate(
      title: 'DEEP WORK',
      description:
      'Complete 45 minutes of uninterrupted work.',
      xpReward: 100,
    ),
    QuestTemplate(
      title: 'SYSTEM ORDER',
      description:
      'Clean and organize your immediate environment.',
      xpReward: 50,
    ),
    QuestTemplate(
      title: 'FOCUS TRIAL',
      description:
      'Complete one important task without distractions.',
      xpReward: 90,
    ),
  ];

  // ------------------------------------------------------------
  // SIDE QUESTS
  // ------------------------------------------------------------

  static const List<QuestTemplate> side = [
    QuestTemplate(
      title: 'SIDE QUEST: EXTRA TRAINING',
      description:
      'Complete an optional additional training session.',
      xpReward: 50,
    ),
    QuestTemplate(
      title: 'SIDE QUEST: EXTRA LEARNING',
      description:
      'Complete an optional additional learning session.',
      xpReward: 50,
    ),
    QuestTemplate(
      title: 'SIDE QUEST: ORGANIZATION',
      description:
      'Improve one part of your environment.',
      xpReward: 40,
    ),
  ];

  // ------------------------------------------------------------
  // SPECIAL QUESTS
  // ------------------------------------------------------------

  static const List<QuestTemplate> special = [
    QuestTemplate(
      title: 'SPECIAL QUEST: AWAKENING',
      description:
      'Complete a special challenge issued by the System.',
      xpReward: 150,
    ),
    QuestTemplate(
      title: 'SPECIAL QUEST: BREAK LIMIT',
      description:
      'Complete a challenge beyond your normal routine.',
      xpReward: 200,
    ),
  ];

  // ------------------------------------------------------------
  // BONUS QUESTS
  // ------------------------------------------------------------

  static const List<QuestTemplate> bonus = [
    QuestTemplate(
      title: 'BONUS: PUSH BEYOND',
      description:
      'Complete an optional challenge beyond today’s requirements.',
      xpReward: 75,
    ),
    QuestTemplate(
      title: 'BONUS: EXTRA DISCIPLINE',
      description:
      'Complete one additional meaningful task.',
      xpReward: 60,
    ),
  ];
}