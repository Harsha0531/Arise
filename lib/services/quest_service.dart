import 'dart:math';

import '../models/quest.dart';
import 'quest_templates.dart';
import 'storage_service.dart';

class QuestService {
  static const int physicalDailyCount = 3;
  static const int otherDailyCount = 2;
  static const int dailyQuestCount = 5;

  static final Random _random = Random();

  // ============================================================
  // TODAY'S 5 DAILY QUESTS
  //
  // EXACTLY:
  //   3 Physical
  //   2 Other
  //
  // Existing quests for today are never regenerated.
  // ============================================================

  static Future<List<Quest>> getTodayQuests() async {
    final storedQuests =
    await StorageService.loadQuests();

    final today = _todayKey();

    final todayQuests = storedQuests
        .where(
          (quest) => _dateKey(quest.date) == today,
    )
        .toList();

    final todayDailyQuests = todayQuests
        .where(
          (quest) => quest.type == QuestType.daily,
    )
        .toList();

    // Already generated today's complete set.
    if (todayDailyQuests.length >= dailyQuestCount) {
      return todayQuests;
    }

    final difficultyDay =
    _calculateDifficultyDay(
      storedQuests,
      today,
    );

    final newQuests = <Quest>[];

    // ----------------------------------------------------------
    // PHYSICAL
    // ----------------------------------------------------------

    final existingPhysical =
        todayDailyQuests
            .where(
              (quest) =>
          quest.category ==
              QuestCategory.physical,
        )
            .length;

    final physicalNeeded =
        physicalDailyCount - existingPhysical;

    if (physicalNeeded > 0) {
      final templates =
      List<QuestTemplate>.from(
        QuestTemplates.physical,
      );

      final existingTitles = todayDailyQuests
          .map((quest) => quest.title)
          .toSet();

      templates.removeWhere(
            (template) =>
            existingTitles.contains(template.title),
      );

      templates.shuffle(_random);

      for (final template
      in templates.take(physicalNeeded)) {
        newQuests.add(
          _createDailyQuest(
            template,
            today,
            QuestCategory.physical,
            difficultyDay,
          ),
        );
      }
    }

    // ----------------------------------------------------------
    // OTHER
    // ----------------------------------------------------------

    final existingOther =
        todayDailyQuests
            .where(
              (quest) =>
          quest.category ==
              QuestCategory.other,
        )
            .length;

    final otherNeeded =
        otherDailyCount - existingOther;

    if (otherNeeded > 0) {
      final templates =
      List<QuestTemplate>.from(
        QuestTemplates.other,
      );

      final existingTitles = {
        ...todayDailyQuests.map(
              (quest) => quest.title,
        ),
        ...newQuests.map(
              (quest) => quest.title,
        ),
      };

      templates.removeWhere(
            (template) =>
            existingTitles.contains(template.title),
      );

      templates.shuffle(_random);

      for (final template
      in templates.take(otherNeeded)) {
        newQuests.add(
          _createDailyQuest(
            template,
            today,
            QuestCategory.other,
            difficultyDay,
          ),
        );
      }
    }

    final updatedTodayQuests = [
      ...todayQuests,
      ...newQuests,
    ];

    final previousQuests = storedQuests
        .where(
          (quest) =>
      _dateKey(quest.date) != today,
    )
        .toList();

    final allQuests = [
      ...previousQuests,
      ...updatedTodayQuests,
    ];

    await StorageService.saveQuests(allQuests);

    return updatedTodayQuests;
  }

  // ============================================================
  // SIDE QUESTS
  // ============================================================

  static Future<List<Quest>> getSideQuests() async {
    return _createOptionalQuests(
      QuestTemplates.side,
      QuestType.side,
    );
  }

  // ============================================================
  // BONUS QUESTS
  // ============================================================

  static Future<List<Quest>> getBonusQuests() async {
    return _createOptionalQuests(
      QuestTemplates.bonus,
      QuestType.bonus,
    );
  }

  // ============================================================
  // SPECIAL QUEST
  // ============================================================

  static Future<Quest?> createSpecialQuest() async {
    final storedQuests =
    await StorageService.loadQuests();

    final today = _todayKey();

    final existing = storedQuests
        .where(
          (quest) =>
      _dateKey(quest.date) == today &&
          quest.type == QuestType.special,
    )
        .toList();

    if (existing.isNotEmpty) {
      return existing.first;
    }

    final templates =
    List<QuestTemplate>.from(
      QuestTemplates.special,
    );

    templates.shuffle(_random);

    if (templates.isEmpty) {
      return null;
    }

    final template = templates.first;

    final quest = Quest(
      id:
      '${today}_special_${template.title.hashCode}',
      title: template.title,
      description: template.description,
      xpReward: template.xpReward,
      date: today,
      type: QuestType.special,
    );

    await StorageService.saveQuests([
      ...storedQuests,
      quest,
    ]);

    return quest;
  }

  // ============================================================
  // OPTIONAL QUEST CREATION
  // ============================================================

  static Future<List<Quest>> _createOptionalQuests(
      List<QuestTemplate> templates,
      QuestType type,
      ) async {
    final storedQuests =
    await StorageService.loadQuests();

    final today = _todayKey();

    final existingTitles = storedQuests
        .where(
          (quest) =>
      _dateKey(quest.date) == today,
    )
        .map((quest) => quest.title)
        .toSet();

    final available =
    List<QuestTemplate>.from(templates);

    available.removeWhere(
          (template) =>
          existingTitles.contains(template.title),
    );

    available.shuffle(_random);

    if (available.isEmpty) {
      return [];
    }

    final template = available.first;

    final quest = Quest(
      id:
      '${today}_${type.name}_${template.title.hashCode}',
      title: template.title,
      description: template.description,
      xpReward: template.xpReward,
      date: today,
      type: type,
    );

    await StorageService.saveQuests([
      ...storedQuests,
      quest,
    ]);

    return [quest];
  }

  // ============================================================
  // DAILY QUEST CREATION
  // ============================================================

  static Quest _createDailyQuest(
      QuestTemplate template,
      String date,
      QuestCategory category,
      int difficultyDay,
      ) {
    final safeDay =
    max(1, difficultyDay);

    // 8% increase per day.
    final multiplier =
    pow(1.08, safeDay - 1).toDouble();

    final xp =
    (template.xpReward * multiplier).round();

    return Quest(
      id:
      '${date}_daily_${category.name}_${template.title.hashCode}',
      title: template.title,
      description:
      '${template.description} '
          'Difficulty Day $safeDay.',
      xpReward: xp,
      date: date,
      type: QuestType.daily,
      category: category,
      difficultyDay: safeDay,
    );
  }

  // ============================================================
  // DIFFICULTY DAY
  //
  // First day with quests = Day 1.
  // Each calendar day increases difficulty by one.
  // ============================================================

  static int _calculateDifficultyDay(
      List<Quest> storedQuests,
      String today,
      ) {
    final dailyQuests = storedQuests
        .where(
          (quest) =>
      quest.type == QuestType.daily,
    )
        .toList();

    if (dailyQuests.isEmpty) {
      return 1;
    }

    DateTime? firstDate;

    for (final quest in dailyQuests) {
      final parsed =
      DateTime.tryParse(
        _dateKey(quest.date),
      );

      if (parsed == null) {
        continue;
      }

      if (firstDate == null ||
          parsed.isBefore(firstDate)) {
        firstDate = parsed;
      }
    }

    if (firstDate == null) {
      return 1;
    }

    final todayDate =
    DateTime.tryParse(today);

    if (todayDate == null) {
      return 1;
    }

    final days =
        todayDate.difference(firstDate).inDays;

    return max(1, days + 1);
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  static String _todayKey() {
    final now = DateTime.now();

    final year =
    now.year.toString().padLeft(4, '0');

    final month =
    now.month.toString().padLeft(2, '0');

    final day =
    now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String _dateKey(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }
}