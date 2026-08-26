import '../models/player.dart';
import '../models/rank.dart';

class ProgressionService {
  static const int totalLevels = 305;

  /// Returns the number of levels before the supplied rank.
  static int levelsBeforeRank(Rank rank) {
    int total = 0;

    for (final currentRank in Rank.values) {
      if (currentRank == rank) {
        break;
      }

      total += currentRank.levelCount;
    }

    return total;
  }

  /// Converts a global level (1-305) into its rank.
  static Rank rankForLevel(int level) {
    int remaining = level;

    for (final rank in Rank.values) {
      if (remaining <= rank.levelCount) {
        return rank;
      }

      remaining -= rank.levelCount;
    }

    return Rank.sss;
  }

  /// Returns the level inside the current rank.
  static int localLevel(int globalLevel) {
    int remaining = globalLevel;

    for (final rank in Rank.values) {
      if (remaining <= rank.levelCount) {
        return remaining;
      }

      remaining -= rank.levelCount;
    }

    return Rank.sss.levelCount;
  }

  /// Base XP required for a local level.
  ///
  /// Base formula:
  /// 100 × 1.08^(level - 1)
  static int baseXpForLevel(int localLevel) {
    return (100 * _pow(1.08, localLevel - 1)).round();
  }

  /// XP required to advance from the current level.
  static int xpRequiredForNextLevel(
      int globalLevel,
      Rank rank,
      ) {
    if (globalLevel >= totalLevels) {
      return 0;
    }

    final local = localLevel(globalLevel);
    final baseXp = baseXpForLevel(local);

    return (baseXp * rank.xpMultiplier).round();
  }

  /// Adds XP and returns the number of levels gained.
  static int addXp(Player player, int amount) {
    if (amount <= 0) {
      return 0;
    }

    final startingLevel = player.level;

    player.xp += amount;

    _processLevelUps(player);

    return player.level - startingLevel;
  }

  /// Deducts XP.
  ///
  /// If the player does not have enough XP,
  /// the remaining amount becomes XP debt.
  static void deductXp(Player player, int amount) {
    if (amount <= 0) {
      return;
    }

    player.xp -= amount;

    if (player.xp < 0) {
      player.xpDebt += player.xp.abs();
      player.xp = 0;
    }
  }

  /// Adds XP and automatically clears existing debt first.
  static void addXpWithDebtHandling(
      Player player,
      int amount,
      ) {
    if (amount <= 0) {
      return;
    }

    if (player.xpDebt > 0) {
      final debtCleared =
      amount.clamp(0, player.xpDebt);

      player.xpDebt -= debtCleared;
      amount -= debtCleared;
    }

    if (amount > 0) {
      player.xp += amount;
      _processLevelUps(player);
    }
  }

  static void _processLevelUps(Player player) {
    while (player.level < totalLevels) {
      final required = xpRequiredForNextLevel(
        player.level,
        rankForLevel(player.level),
      );

      if (player.xp < required) {
        break;
      }

      player.xp -= required;
      player.level++;

      final newRank = rankForLevel(player.level);

      if (newRank != player.rank) {
        player.rank = newRank;
      }

      // Every level grants one unspent reward point.
      player.rewardPoints++;
    }
  }

  /// Spends one reward point on Strength.
  static bool increaseStrength(Player player) {
    if (player.rewardPoints <= 0) {
      return false;
    }

    player.strength++;
    player.rewardPoints--;

    return true;
  }

  /// Spends one reward point on Intelligence.
  static bool increaseIntelligence(Player player) {
    if (player.rewardPoints <= 0) {
      return false;
    }

    player.intelligence++;
    player.rewardPoints--;

    return true;
  }

  /// Spends one reward point on Vitality.
  static bool increaseVitality(Player player) {
    if (player.rewardPoints <= 0) {
      return false;
    }

    player.vitality++;
    player.rewardPoints--;

    return true;
  }

  /// Spends one reward point on Discipline.
  static bool increaseDiscipline(Player player) {
    if (player.rewardPoints <= 0) {
      return false;
    }

    player.discipline++;
    player.rewardPoints--;

    return true;
  }

  /// Spends one reward point on Focus.
  static bool increaseFocus(Player player) {
    if (player.rewardPoints <= 0) {
      return false;
    }

    player.focus++;
    player.rewardPoints--;

    return true;
  }

  static double _pow(
      double base,
      int exponent,
      ) {
    double result = 1.0;

    for (int i = 0; i < exponent; i++) {
      result *= base;
    }

    return result;
  }

  /// Returns a useful progression snapshot for the UI.
  static ProgressionSnapshot getSnapshot(
      Player player,
      ) {
    final rank = rankForLevel(player.level);
    final local = localLevel(player.level);
    final required =
    xpRequiredForNextLevel(player.level, rank);

    return ProgressionSnapshot(
      globalLevel: player.level,
      localLevel: local,
      rank: rank,
      currentXp: player.xp,
      requiredXp: required,
      xpDebt: player.xpDebt,
      rewardPoints: player.rewardPoints,
      isMaxLevel: player.level >= totalLevels,
    );
  }
}

class ProgressionSnapshot {
  final int globalLevel;
  final int localLevel;
  final Rank rank;
  final int currentXp;
  final int requiredXp;
  final int xpDebt;
  final int rewardPoints;
  final bool isMaxLevel;

  const ProgressionSnapshot({
    required this.globalLevel,
    required this.localLevel,
    required this.rank,
    required this.currentXp,
    required this.requiredXp,
    required this.xpDebt,
    required this.rewardPoints,
    required this.isMaxLevel,
  });

  double get progress {
    if (requiredXp <= 0) {
      return 1.0;
    }

    final value = currentXp / requiredXp;

    if (value < 0) {
      return 0;
    }

    if (value > 1) {
      return 1;
    }

    return value;
  }
}