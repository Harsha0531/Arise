import 'dart:math';

import '../models/quest.dart';

class QuestAssignmentConfig {
  final int dailyCount;
  final int physicalDailyCount;
  final int otherDailyCount;
  final int maxSidePerDay;
  final int maxBonusPerDay;
  final int maxSpecialPerDay;

  const QuestAssignmentConfig({
    this.dailyCount = 5,
    this.physicalDailyCount = 3,
    this.otherDailyCount = 2,
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

  static List<QuestAssignment> assignOptionalQuests({
    required List<String> availableSideQuestIds,
    required List<String> availableBonusQuestIds,
    required List<String> availableSpecialQuestIds,
    Set<String> recentlyUsedQuestIds = const {},
  }) {
    final assignments = <QuestAssignment>[];

    final sideCandidates = availableSideQuestIds
        .where(
          (id) =>
      !recentlyUsedQuestIds.contains(id),
    )
        .toList();

    sideCandidates.shuffle(_random);

    final sideCount = _random.nextInt(
      config.maxSidePerDay + 1,
    );

    for (final id
    in sideCandidates.take(sideCount)) {
      assignments.add(
        QuestAssignment(
          templateId: id,
          type: QuestType.side,
        ),
      );
    }

    final bonusCandidates = availableBonusQuestIds
        .where(
          (id) =>
      !recentlyUsedQuestIds.contains(id),
    )
        .toList();

    bonusCandidates.shuffle(_random);

    if (bonusCandidates.isNotEmpty &&
        _random.nextBool()) {
      assignments.add(
        QuestAssignment(
          templateId: bonusCandidates.first,
          type: QuestType.bonus,
        ),
      );
    }

    final specialCandidates =
    availableSpecialQuestIds
        .where(
          (id) =>
      !recentlyUsedQuestIds.contains(id),
    )
        .toList();

    specialCandidates.shuffle(_random);

    // Special quests remain deliberately rare.
    if (specialCandidates.isNotEmpty &&
        _random.nextInt(7) == 0) {
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