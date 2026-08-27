import 'dart:math';

import '../models/quest.dart';
import 'quest_templates.dart';
import 'storage_service.dart';

class QuestService {
  static const int physicalDailyCount = 3;
  static const int otherDailyCount = 2;
  static const int dailyQuestCount = 5;

  // ============================================================
  // DAILY QUEST TIMING
  // ============================================================

  static const int dailyStartHour = 6;
  static const int dailyDurationHours = 15;
  static const int dailyEndHour =
      dailyStartHour + dailyDurationHours; // 21:00

  static final Random _random = Random();

  // ============================================================
  // TODAY'S QUEST CYCLE
  //
  // 06:00 -> new daily quests begin
  // 21:00 -> daily quests expire
  //
  // Before 06:00, the active cycle is still yesterday's cycle.
  // This prevents a new set of quests being generated at 01:00,
  // 02:00, etc.
  // ============================================================

  static Future<List<Quest>> getTodayQuests() async {
    final storedQuests =
    await StorageService.loadQuests();

    final now = DateTime.now();

    final cycleDate = _questCycleDate(now);

    final cycleDateKey =
    _dateKeyFromDate(cycleDate);

    // ----------------------------------------------------------
    // FIRST:
    // Check whether the previous/current daily cycle has expired.
    //
    // This is deliberately performed whenever the app asks for
    // quests. Therefore the app does NOT need to be running at
    // exactly 21:00.
    // ----------------------------------------------------------

    final processedQuests =
    _processExpiredDailyQuests(
      storedQuests,
      now,
    );

    // ----------------------------------------------------------
    // Work from the processed list.
    // ----------------------------------------------------------

    final todayQuests = processedQuests
        .where(
          (quest) =>
      _dateKey(quest.date) ==
          cycleDateKey,
    )
        .toList();

    final todayDailyQuests = todayQuests
        .where(
          (quest) =>
      quest.type == QuestType.daily,
    )
        .toList();

    // ----------------------------------------------------------
    // BEFORE 06:00:
    //
    // Do not generate a new day's quests.
    //
    // If there is no previous cycle, simply return whatever
    // exists.
    // ----------------------------------------------------------

    if (!_isDailyWindowOpen(now)) {
      return todayQuests;
    }

    // ----------------------------------------------------------
    // Already generated today's complete set.
    // ----------------------------------------------------------

    if (todayDailyQuests.length >= dailyQuestCount) {
      return todayQuests;
    }

    final difficultyDay =
    _calculateDifficultyDay(
      processedQuests,
      cycleDateKey,
    );

    final newQuests = <Quest>[];

    // ==========================================================
    // PHYSICAL DAILY QUESTS
    // ==========================================================

    final existingPhysical =
        todayDailyQuests
            .where(
              (quest) =>
          quest.category ==
              QuestCategory.physical,
        )
            .length;

    final physicalNeeded =
        physicalDailyCount -
            existingPhysical;

    if (physicalNeeded > 0) {
      final templates =
      List<QuestTemplate>.from(
        QuestTemplates.physical,
      );

      final existingTitles =
      todayDailyQuests
          .map(
            (quest) => quest.title,
      )
          .toSet();

      templates.removeWhere(
            (template) =>
            existingTitles.contains(
              template.title,
            ),
      );

      templates.shuffle(_random);

      for (final template
      in templates.take(physicalNeeded)) {
        newQuests.add(
          _createDailyQuest(
            template,
            cycleDateKey,
            QuestCategory.physical,
            difficultyDay,
          ),
        );
      }
    }

    // ==========================================================
    // OTHER DAILY QUESTS
    // ==========================================================

    final existingOther =
        todayDailyQuests
            .where(
              (quest) =>
          quest.category ==
              QuestCategory.other,
        )
            .length;

    final otherNeeded =
        otherDailyCount -
            existingOther;

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
            existingTitles.contains(
              template.title,
            ),
      );

      templates.shuffle(_random);

      for (final template
      in templates.take(otherNeeded)) {
        newQuests.add(
          _createDailyQuest(
            template,
            cycleDateKey,
            QuestCategory.other,
            difficultyDay,
          ),
        );
      }
    }

    // ==========================================================
    // SAVE
    // ==========================================================

    final updatedCycleQuests = [
      ...todayQuests,
      ...newQuests,
    ];

    final previousQuests = processedQuests
        .where(
          (quest) =>
      _dateKey(quest.date) !=
          cycleDateKey,
    )
        .toList();

    final allQuests = [
      ...previousQuests,
      ...updatedCycleQuests,
    ];

    await StorageService.saveQuests(allQuests);

    return updatedCycleQuests;
  }

  // ============================================================
  // PROCESS EXPIRED DAILY QUESTS
  //
  // This is what makes the system work even when the app was
  // completely closed at 21:00.
  // ============================================================

  static List<Quest> _processExpiredDailyQuests(
      List<Quest> storedQuests,
      DateTime now,
      ) {
    final updated =
    List<Quest>.from(storedQuests);

    bool changed = false;

    // Group daily quests by their quest-cycle date.
    final dailyDates = updated
        .where(
          (quest) =>
      quest.type == QuestType.daily,
    )
        .map(
          (quest) => _dateKey(quest.date),
    )
        .toSet();

    for (final dateKey in dailyDates) {
      final date =
      DateTime.tryParse(dateKey);

      if (date == null) {
        continue;
      }

      // The daily quest deadline is 21:00
      // on its quest date.
      final deadline = DateTime(
        date.year,
        date.month,
        date.day,
        dailyEndHour,
      );

      // The quest cycle has not expired yet.
      if (now.isBefore(deadline)) {
        continue;
      }

      // --------------------------------------------------------
      // Find unfinished daily quests from this cycle.
      // --------------------------------------------------------

      final expiredDailyQuests =
      updated.where(
            (quest) =>
        quest.type == QuestType.daily &&
            _dateKey(quest.date) == dateKey &&
            !quest.completed &&
            !quest.missed,
      );

      for (final quest
      in expiredDailyQuests) {
        quest.missed = true;
        changed = true;

        // ------------------------------------------------------
        // Create exactly ONE penalty quest for this missed
        // daily quest.
        // ------------------------------------------------------

        final penaltyId =
            '${dateKey}_penalty_${quest.id}';

        final penaltyExists =
        updated.any(
              (existing) =>
          existing.id == penaltyId,
        );

        if (!penaltyExists) {
          updated.add(
            Quest(
              id: penaltyId,
              title:
              'Penalty Quest — ${quest.title}',
              description:
              'Penalty for failing the daily quest. '
                  'Complete 30 minutes of focused effort '
                  'to clear this penalty.',
              xpReward: 50,
              date: dateKey,
              type: QuestType.penalty,
            ),
          );

          changed = true;
        }
      }
    }

    // ----------------------------------------------------------
    // Persist immediately.
    //
    // This means the missed state survives closing/reopening
    // the application.
    // ----------------------------------------------------------

    if (changed) {
      StorageService.saveQuests(updated);
    }

    return updated;
  }

  // ============================================================
  // DAILY WINDOW
  // ============================================================

  static bool _isDailyWindowOpen(
      DateTime now,
      ) {
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      dailyStartHour,
    );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      dailyEndHour,
    );

    return !now.isBefore(start) &&
        now.isBefore(end);
  }

  // ============================================================
  // QUEST CYCLE DATE
  //
  // At 00:00-05:59 we remain on the previous day's cycle.
  // At 06:00 a new cycle begins.
  // ============================================================

  static DateTime _questCycleDate(
      DateTime now,
      ) {
    if (now.hour < dailyStartHour) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        const Duration(days: 1),
      );
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
    );
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
          quest.type ==
              QuestType.special,
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
        .map(
          (quest) => quest.title,
    )
        .toSet();

    final available =
    List<QuestTemplate>.from(templates);

    available.removeWhere(
          (template) =>
          existingTitles.contains(
            template.title,
          ),
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
    (template.xpReward * multiplier)
        .round();

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
    return _dateKeyFromDate(
      DateTime.now(),
    );
  }

  static String _dateKeyFromDate(
      DateTime date,
      ) {
    final year =
    date.year.toString().padLeft(4, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final day =
    date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String _dateKey(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }
}