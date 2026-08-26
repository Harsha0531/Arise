import '../models/quest.dart';
import 'storage_service.dart';

class StreakService {
  /// A day counts toward the streak only when all
  /// 5 daily quests for that day are completed.
  static Future<int> getCurrentStreak() async {
    final quests = await StorageService.loadQuests();

    final byDate = <String, List<Quest>>{};

    for (final quest in quests) {
      final date = _dateKey(quest.date);

      byDate.putIfAbsent(
        date,
            () => [],
      );

      byDate[date]!.add(quest);
    }

    if (byDate.isEmpty) {
      return 0;
    }

    DateTime checkDate = _dateOnly(
      DateTime.now(),
    );

    // If today's five quests aren't completed yet,
    // start checking from yesterday.
    final todayKey = _formatDate(checkDate);
    final todayQuests = byDate[todayKey];

    if (todayQuests == null ||
        !_isCompletedDay(todayQuests)) {
      checkDate = checkDate.subtract(
        const Duration(days: 1),
      );
    }

    int streak = 0;

    while (true) {
      final key = _formatDate(checkDate);
      final dayQuests = byDate[key];

      if (dayQuests == null ||
          !_isCompletedDay(dayQuests)) {
        break;
      }

      streak++;

      checkDate = checkDate.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }

  static Future<List<StreakDay>> getHistory({
    int days = 30,
  }) async {
    final quests = await StorageService.loadQuests();

    final byDate = <String, List<Quest>>{};

    for (final quest in quests) {
      final date = _dateKey(quest.date);

      byDate.putIfAbsent(
        date,
            () => [],
      );

      byDate[date]!.add(quest);
    }

    final result = <StreakDay>[];

    final today = _dateOnly(
      DateTime.now(),
    );

    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(
        Duration(days: i),
      );

      final key = _formatDate(date);

      final dayQuests =
          byDate[key] ?? <Quest>[];

      final completedCount =
          dayQuests
              .where(
                (quest) => quest.completed,
          )
              .length;

      result.add(
        StreakDay(
          date: date,
          completed: _isCompletedDay(
            dayQuests,
          ),
          completedCount: completedCount,
          totalCount: dayQuests.length,
        ),
      );
    }

    return result;
  }

  static bool _isCompletedDay(
      List<Quest> quests,
      ) {
    // The daily system is fixed at 5 quests.
    if (quests.length != 5) {
      return false;
    }

    return quests.every(
          (quest) => quest.completed,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  static String _dateKey(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }

  static String _formatDate(DateTime date) {
    final year =
    date.year.toString().padLeft(4, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final day =
    date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}

class StreakDay {
  final DateTime date;
  final bool completed;
  final int completedCount;
  final int totalCount;

  const StreakDay({
    required this.date,
    required this.completed,
    required this.completedCount,
    required this.totalCount,
  });
}