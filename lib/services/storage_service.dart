import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import '../models/rank.dart';
import '../models/quest.dart';

class StorageService {
  static const String _nameKey = 'player_name';
  static const String _levelKey = 'player_level';
  static const String _xpKey = 'player_xp';
  static const String _xpDebtKey = 'player_xp_debt';
  static const String _rewardPointsKey = 'player_reward_points';
  static const String _rankKey = 'player_rank';

  static const String _strengthKey = 'strength';
  static const String _intelligenceKey = 'intelligence';
  static const String _vitalityKey = 'vitality';
  static const String _disciplineKey = 'discipline';
  static const String _focusKey = 'focus';

  static const String _questsKey = 'daily_quests';

  static Future<void> savePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, player.name);
    await prefs.setInt(_levelKey, player.level);
    await prefs.setInt(_xpKey, player.xp);
    await prefs.setInt(_xpDebtKey, player.xpDebt);
    await prefs.setInt(
      _rewardPointsKey,
      player.rewardPoints,
    );
    await prefs.setInt(_rankKey, player.rank.index);

    await prefs.setInt(_strengthKey, player.strength);
    await prefs.setInt(
      _intelligenceKey,
      player.intelligence,
    );
    await prefs.setInt(_vitalityKey, player.vitality);
    await prefs.setInt(
      _disciplineKey,
      player.discipline,
    );
    await prefs.setInt(_focusKey, player.focus);
  }

  static Future<Player> loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();

    final rankIndex = prefs.getInt(_rankKey);

    return Player(
      name: prefs.getString(_nameKey) ?? 'Hunter',
      level: prefs.getInt(_levelKey) ?? 1,
      xp: prefs.getInt(_xpKey) ?? 0,
      xpDebt: prefs.getInt(_xpDebtKey) ?? 0,
      rewardPoints:
      prefs.getInt(_rewardPointsKey) ?? 0,
      rank: rankIndex != null &&
          rankIndex >= 0 &&
          rankIndex < Rank.values.length
          ? Rank.values[rankIndex]
          : Rank.unawakened,
      strength: prefs.getInt(_strengthKey) ?? 1,
      intelligence:
      prefs.getInt(_intelligenceKey) ?? 1,
      vitality: prefs.getInt(_vitalityKey) ?? 1,
      discipline:
      prefs.getInt(_disciplineKey) ?? 1,
      focus: prefs.getInt(_focusKey) ?? 1,
    );
  }

  static Future<void> clearPlayer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveQuests(
      List<Quest> quests,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = quests
        .map((quest) => quest.toMap())
        .toList();

    await prefs.setString(
      _questsKey,
      jsonEncode(data),
    );
  }

  static Future<List<Quest>> loadQuests() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_questsKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List;

      return decoded
          .map(
            (item) => Quest.fromMap(
          Map<String, dynamic>.from(
            item as Map,
          ),
        ),
      )
          .toList();
    } catch (_) {
      return [];
    }
  }
}