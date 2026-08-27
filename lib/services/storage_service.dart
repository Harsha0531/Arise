import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
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

  // ============================================================
  // CURRENT USER
  // ============================================================

  static String _currentUserId() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError(
        'No authenticated Firebase user is available.',
      );
    }

    return user.uid;
  }

  // ============================================================
  // USER-SCOPED KEY
  // ============================================================

  static String _key(String key) {
    return 'arise_${_currentUserId()}_$key';
  }

  // ============================================================
  // SAVE PLAYER
  // ============================================================

  static Future<void> savePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _key(_nameKey),
      player.name,
    );

    await prefs.setInt(
      _key(_levelKey),
      player.level,
    );

    await prefs.setInt(
      _key(_xpKey),
      player.xp,
    );

    await prefs.setInt(
      _key(_xpDebtKey),
      player.xpDebt,
    );

    await prefs.setInt(
      _key(_rewardPointsKey),
      player.rewardPoints,
    );

    await prefs.setInt(
      _key(_rankKey),
      player.rank.index,
    );

    await prefs.setInt(
      _key(_strengthKey),
      player.strength,
    );

    await prefs.setInt(
      _key(_intelligenceKey),
      player.intelligence,
    );

    await prefs.setInt(
      _key(_vitalityKey),
      player.vitality,
    );

    await prefs.setInt(
      _key(_disciplineKey),
      player.discipline,
    );

    await prefs.setInt(
      _key(_focusKey),
      player.focus,
    );
  }

  // ============================================================
  // LOAD PLAYER
  // ============================================================

  static Future<Player> loadPlayer() async {
    final prefs = await SharedPreferences.getInstance();

    final rankIndex = prefs.getInt(
      _key(_rankKey),
    );

    return Player(
      name: prefs.getString(
        _key(_nameKey),
      ) ??
          'Hunter',
      level: prefs.getInt(
        _key(_levelKey),
      ) ??
          1,
      xp: prefs.getInt(
        _key(_xpKey),
      ) ??
          0,
      xpDebt: prefs.getInt(
        _key(_xpDebtKey),
      ) ??
          0,
      rewardPoints: prefs.getInt(
        _key(_rewardPointsKey),
      ) ??
          0,
      rank: rankIndex != null &&
          rankIndex >= 0 &&
          rankIndex < Rank.values.length
          ? Rank.values[rankIndex]
          : Rank.unawakened,
      strength: prefs.getInt(
        _key(_strengthKey),
      ) ??
          1,
      intelligence: prefs.getInt(
        _key(_intelligenceKey),
      ) ??
          1,
      vitality: prefs.getInt(
        _key(_vitalityKey),
      ) ??
          1,
      discipline: prefs.getInt(
        _key(_disciplineKey),
      ) ??
          1,
      focus: prefs.getInt(
        _key(_focusKey),
      ) ??
          1,
    );
  }

  // ============================================================
  // SAVE QUESTS
  // ============================================================

  static Future<void> saveQuests(
      List<Quest> quests,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = quests
        .map(
          (quest) => quest.toMap(),
    )
        .toList();

    await prefs.setString(
      _key(_questsKey),
      jsonEncode(data),
    );
  }

  // ============================================================
  // LOAD QUESTS
  // ============================================================

  static Future<List<Quest>> loadQuests() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(
      _key(_questsKey),
    );

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

  // ============================================================
  // RESET CURRENT USER PROGRESS
  // ============================================================

  static Future<void> resetCurrentUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final keysToRemove = <String>[
      _nameKey,
      _levelKey,
      _xpKey,
      _xpDebtKey,
      _rewardPointsKey,
      _rankKey,
      _strengthKey,
      _intelligenceKey,
      _vitalityKey,
      _disciplineKey,
      _focusKey,
      _questsKey,
    ];

    for (final key in keysToRemove) {
      await prefs.remove(
        _key(key),
      );
    }
  }

  // ============================================================
  // CLEAR CURRENT USER DATA
  // ============================================================

  static Future<void> clearPlayer() async {
    await resetCurrentUserData();
  }
}