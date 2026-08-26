import 'dart:math';

enum QuestType {
  daily,
  side,
  bonus,
  special,
  penalty,
}

class QuestAssignmentConfig {
  final int dailyCount;
  final int maxSidePerDay;
  final int maxBonusPerDay;
  final int maxSpecialPerDay;

  const QuestAssignmentConfig({
    this.dailyCount = 5,
    this.maxSidePerDay = 2,
    this.maxBonusPerDay = 1,
    this.maxSpecialPerDay = 1,
  });
}

class QuestAssignment {
  final String templateId;
  final QuestType type;

  const QuestAssignment({
    required this.templateId,
    required this.type,
  });
}

class QuestAssignmentService {
  static const QuestAssignmentConfig config =
  QuestAssignmentConfig();

  static final Random _random = Random();

  /// Determines how many optional quests may appear today.
  ///
  /// Daily quests are always handled separately.
  /// Side/Bonus/Special quests are optional.
  static List<QuestAssignment> assignOptionalQuests({
    required List<String> availableSideQuestIds,
    required List<String> availableBonusQuestIds,
    required List<String> availableSpecialQuestIds,
    Set<String> recentlyUsedQuestIds = const {},
  }) {
    final assignments = <QuestAssignment>[];

    // -------------------------
    // SIDE QUESTS
    // -------------------------

    final sideCandidates = availableSideQuestIds
        .where(
          (id) => !recentlyUsedQuestIds.contains(id),
    )
        .toList();

    sideCandidates.shuffle(_random);

    // 0–2 side quests.
    final sideCount = _random.nextInt(
      config.maxSidePerDay + 1,
    );

    for (final id in sideCandidates.take(sideCount)) {
      assignments.add(
        QuestAssignment(
          templateId: id,
          type: QuestType.side,
        ),
      );
    }

    // -------------------------
    // BONUS QUESTS
    // -------------------------

    final bonusCandidates = availableBonusQuestIds
        .where(
          (id) => !recentlyUsedQuestIds.contains(id),
    )
        .toList();

    bonusCandidates.shuffle(_random);

    // 0–1 bonus quest.
    final shouldAssignBonus =
        bonusCandidates.isNotEmpty &&
            _random.nextBool();

    if (shouldAssignBonus) {
      assignments.add(
        QuestAssignment(
          templateId: bonusCandidates.first,
          type: QuestType.bonus,
        ),
      );
    }

    // -------------------------
    // SPECIAL QUESTS
    // -------------------------

    final specialCandidates = availableSpecialQuestIds
        .where(
          (id) => !recentlyUsedQuestIds.contains(id),
    )
        .toList();

    specialCandidates.shuffle(_random);

    // Special quests are deliberately rare.
    final shouldAssignSpecial =
        specialCandidates.isNotEmpty &&
            _random.nextInt(7) == 0;

    if (shouldAssignSpecial) {
      assignments.add(
        QuestAssignment(
          templateId: specialCandidates.first,
          type: QuestType.special,
        ),
      );
    }

    return assignments;
  }
}