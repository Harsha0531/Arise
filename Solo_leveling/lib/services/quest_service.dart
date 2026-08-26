import 'dart:math';

import '../models/quest.dart';
import 'quest_templates.dart';
import 'storage_service.dart';

class QuestService {
  static const int dailyQuestCount = 5;

  static final Random _random = Random();

  static Future<List<Quest>> getTodayQuests() async {
    final storedQuests = await StorageService.loadQuests();

    final today = _todayKey();

    final todayQuests = storedQuests
        .where((quest) => _dateKey(quest.date) == today)
        .toList();

    // If we already have 5 quests for today,
    // keep them exactly as they are.
    if (todayQuests.length >= dailyQuestCount) {
      return todayQuests;
    }

    // Generate only the quests that are missing.
    final missingCount =
        dailyQuestCount - todayQuests.length;

    final existingTitles = todayQuests
        .map((quest) => quest.title)
        .toSet();

    final availableTemplates = QuestTemplates.daily
        .where(
          (template) =>
      !existingTitles.contains(template.title),
    )
        .toList();

    availableTemplates.shuffle(_random);

    final selectedTemplates =
    availableTemplates.take(missingCount).toList();

    final newQuests = <Quest>[];

    for (var index = 0;
    index < selectedTemplates.length;
    index++) {
      final template = selectedTemplates[index];

      newQuests.add(
        Quest(
          id: '${today}_daily_${index}_${template.title.hashCode}',
          title: template.title,
          description: template.description,
          xpReward: template.xpReward,
          date: today,
        ),
      );
    }

    final updatedTodayQuests = [
      ...todayQuests,
      ...newQuests,
    ];

    final previousQuests = storedQuests
        .where(
          (quest) => _dateKey(quest.date) != today,
    )
        .toList();

    final allQuests = [
      ...previousQuests,
      ...updatedTodayQuests,
    ];

    await StorageService.saveQuests(allQuests);

    return updatedTodayQuests;
  }

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