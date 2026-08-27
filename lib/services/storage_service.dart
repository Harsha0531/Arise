import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player.dart';
import '../models/rank.dart';
import '../models/quest.dart';
import 'cloud_storage_service.dart';

class StorageService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // LOCAL STORAGE KEY NAMES
  // ============================================================

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
  // USER-SCOPED KEY
  //
  // Every authenticated Firebase user gets a completely
  // separate local storage namespace.
  //
  // Example:
  // solo_leveling_user_UID123_player_level
  // solo_leveling_user_UID456_player_level
  //
  // Therefore logging out and signing into another account
  // cannot expose the previous account's local progress.
  // ============================================================

  static String _scopedKey(String key) {
    final uid = _auth.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      throw StateError(
        'Cannot access user-scoped storage without an authenticated user.',
      );
    }

    return 'solo_leveling_user_${uid}_$key';
  }

  // ============================================================
  // AUTHENTICATION CHECK
  // ============================================================

  static bool get hasAuthenticatedUser {
    final uid = _auth.currentUser?.uid;

    return uid != null && uid.isNotEmpty;
  }

  // ============================================================
  // SAVE PLAYER
  // ============================================================

  static Future<void> savePlayer(Player player) async {
    if (!hasAuthenticatedUser) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _scopedKey(_nameKey),
      player.name,
    );

    await prefs.setInt(
      _scopedKey(_levelKey),
      player.level,
    );

    await prefs.setInt(
      _scopedKey(_xpKey),
      player.xp,
    );

    await prefs.setInt(
      _scopedKey(_xpDebtKey),
      player.xpDebt,
    );

    await prefs.setInt(
      _scopedKey(_rewardPointsKey),
      player.rewardPoints,
    );

    await prefs.setInt(
      _scopedKey(_rankKey),
      player.rank.index,
    );

    await prefs.setInt(
      _scopedKey(_strengthKey),
      player.strength,
    );

    await prefs.setInt(
      _scopedKey(_intelligenceKey),
      player.intelligence,
    );

    await prefs.setInt(
      _scopedKey(_vitalityKey),
      player.vitality,
    );

    await prefs.setInt(
      _scopedKey(_disciplineKey),
      player.discipline,
    );

    await prefs.setInt(
      _scopedKey(_focusKey),
      player.focus,
    );

    // ----------------------------------------------------------
    // Cloud persistence
    //
    // CloudStorageService already uses Firebase Auth UID to
    // determine the user's Firestore path.
    // ----------------------------------------------------------

    try {
      await CloudStorageService.savePlayer(player);
    } catch (_) {
      // Offline mode remains functional.
    }
  }

  // ============================================================
  // LOAD PLAYER
  // ============================================================

  static Future<Player> loadPlayer() async {
    if (!hasAuthenticatedUser) {
      return Player();
    }

    // ----------------------------------------------------------
    // CLOUD FIRST
    // ----------------------------------------------------------

    try {
      final cloudPlayer =
      await CloudStorageService.loadPlayer();

      if (cloudPlayer != null) {
        await _savePlayerLocally(cloudPlayer);

        return cloudPlayer;
      }
    } catch (_) {
      // Continue to local storage fallback.
    }

    // ----------------------------------------------------------
    // LOCAL USER-SCOPED STORAGE
    // ----------------------------------------------------------

    final prefs = await SharedPreferences.getInstance();

    final player = Player(
      name: prefs.getString(
        _scopedKey(_nameKey),
      ) ??
          'Hunter',

      level: prefs.getInt(
        _scopedKey(_levelKey),
      ) ??
          1,

      xp: prefs.getInt(
        _scopedKey(_xpKey),
      ) ??
          0,

      xpDebt: prefs.getInt(
        _scopedKey(_xpDebtKey),
      ) ??
          0,

      rewardPoints: prefs.getInt(
        _scopedKey(_rewardPointsKey),
      ) ??
          0,

      rank: _rankFromIndex(
        prefs.getInt(
          _scopedKey(_rankKey),
        ),
      ),

      strength: prefs.getInt(
        _scopedKey(_strengthKey),
      ) ??
          1,

      intelligence: prefs.getInt(
        _scopedKey(_intelligenceKey),
      ) ??
          1,

      vitality: prefs.getInt(
        _scopedKey(_vitalityKey),
      ) ??
          1,

      discipline: prefs.getInt(
        _scopedKey(_disciplineKey),
      ) ??
          1,

      focus: prefs.getInt(
        _scopedKey(_focusKey),
      ) ??
          1,
    );

    // ----------------------------------------------------------
    // If this account doesn't have a cloud player yet,
    // bootstrap the cloud copy from this account's local data.
    // ----------------------------------------------------------

    try {
      final hasCloudPlayer =
      await CloudStorageService.hasPlayer();

      if (!hasCloudPlayer) {
        await CloudStorageService.savePlayer(player);
      }
    } catch (_) {
      // Local data remains usable offline.
    }

    return player;
  }

  // ============================================================
  // CLEAR CURRENT USER'S PLAYER DATA
  //
  // IMPORTANT:
  // This does NOT call prefs.clear().
  //
  // It removes ONLY the currently authenticated user's
  // progression keys.
  // ============================================================

  static Future<void> clearPlayer() async {
    if (!hasAuthenticatedUser) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(
      _scopedKey(_nameKey),
    );

    await prefs.remove(
      _scopedKey(_levelKey),
    );

    await prefs.remove(
      _scopedKey(_xpKey),
    );

    await prefs.remove(
      _scopedKey(_xpDebtKey),
    );

    await prefs.remove(
      _scopedKey(_rewardPointsKey),
    );

    await prefs.remove(
      _scopedKey(_rankKey),
    );

    await prefs.remove(
      _scopedKey(_strengthKey),
    );

    await prefs.remove(
      _scopedKey(_intelligenceKey),
    );

    await prefs.remove(
      _scopedKey(_vitalityKey),
    );

    await prefs.remove(
      _scopedKey(_disciplineKey),
    );

    await prefs.remove(
      _scopedKey(_focusKey),
    );

    await prefs.remove(
      _scopedKey(_questsKey),
    );
  }

  // ============================================================
  // RESET CURRENT USER'S PROGRESS
  //
  // The account itself remains intact.
  //
  // User identity:
  //   KEPT
  //
  // Firebase authentication:
  //   KEPT
  //
  // Game progress:
  //   RESET
  //
  // Quests:
  //   RESET
  // ============================================================

  static Future<void> resetProgress() async {
    if (!hasAuthenticatedUser) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // ----------------------------------------------------------
    // Preserve the player's current display name.
    // ----------------------------------------------------------

    final existingName =
        prefs.getString(
          _scopedKey(_nameKey),
        ) ??
            'Hunter';

    // ----------------------------------------------------------
    // Reset local player state.
    // ----------------------------------------------------------

    final resetPlayer = Player(
      name: existingName,
      level: 1,
      xp: 0,
      xpDebt: 0,
      rewardPoints: 0,
      rank: Rank.unawakened,
      strength: 1,
      intelligence: 1,
      vitality: 1,
      discipline: 1,
      focus: 1,
    );

    await _savePlayerLocally(
      resetPlayer,
    );

    // ----------------------------------------------------------
    // Remove local quests.
    // ----------------------------------------------------------

    await prefs.remove(
      _scopedKey(_questsKey),
    );

    // ----------------------------------------------------------
    // Reset cloud progression.
    //
    // CloudStorageService is already UID-scoped through
    // FirebaseAuth.currentUser.uid.
    // ----------------------------------------------------------

    try {
      await CloudStorageService.savePlayer(
        resetPlayer,
      );

      await CloudStorageService.saveQuests(
        [],
      );
    } catch (_) {
      // If offline, local reset has already succeeded.
      // Cloud will be synchronized when future progress is saved.
    }
  }

  // ============================================================
  // SAVE QUESTS
  // ============================================================

  static Future<void> saveQuests(
      List<Quest> quests,
      ) async {
    if (!hasAuthenticatedUser) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final data = quests
        .map(
          (quest) => quest.toMap(),
    )
        .toList();

    await prefs.setString(
      _scopedKey(_questsKey),
      jsonEncode(data),
    );

    try {
      await CloudStorageService.saveQuests(
        quests,
      );
    } catch (_) {
      // Offline mode remains functional.
    }
  }

  // ============================================================
  // LOAD QUESTS
  // ============================================================

  static Future<List<Quest>> loadQuests() async {
    if (!hasAuthenticatedUser) {
      return [];
    }

    // ----------------------------------------------------------
    // CLOUD FIRST
    // ----------------------------------------------------------

    try {
      final cloudQuests =
      await CloudStorageService.loadQuests();

      if (cloudQuests != null) {
        await _saveQuestsLocally(
          cloudQuests,
        );

        return cloudQuests;
      }
    } catch (_) {
      // Continue to local storage fallback.
    }

    // ----------------------------------------------------------
    // USER-SCOPED LOCAL QUESTS
    // ----------------------------------------------------------

    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(
      _scopedKey(_questsKey),
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
  // RANK CONVERSION
  // ============================================================

  static Rank _rankFromIndex(
      int? rankIndex,
      ) {
    if (rankIndex != null &&
        rankIndex >= 0 &&
        rankIndex < Rank.values.length) {
      return Rank.values[rankIndex];
    }

    return Rank.unawakened;
  }

  // ============================================================
  // SAVE PLAYER LOCALLY
  // ============================================================

  static Future<void> _savePlayerLocally(
      Player player,
      ) async {
    if (!hasAuthenticatedUser) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _scopedKey(_nameKey),
      player.name,
    );

    await prefs.setInt(
      _scopedKey(_levelKey),
      player.level,
    );

    await prefs.setInt(
      _scopedKey(_xpKey),
      player.xp,
    );

    await prefs.setInt(
      _scopedKey(_xpDebtKey),
      player.xpDebt,
    );

    await prefs.setInt(
      _scopedKey(_rewardPointsKey),
      player.rewardPoints,
    );

    await prefs.setInt(
      _scopedKey(_rankKey),
      player.rank.index,
    );

    await prefs.setInt(
      _scopedKey(_strengthKey),
      player.strength,
    );

    await prefs.setInt(
      _scopedKey(_intelligenceKey),
      player.intelligence,
    );

    await prefs.setInt(
      _scopedKey(_vitalityKey),
      player.vitality,
    );

    await prefs.setInt(
      _scopedKey(_disciplineKey),
      player.discipline,
    );

    await prefs.setInt(
      _scopedKey(_focusKey),
      player.focus,
    );
  }

  // ============================================================
  // SAVE QUESTS LOCALLY
  // ============================================================

  static Future<void> _saveQuestsLocally(
      List<Quest> quests,
      ) async {
    if (!hasAuthenticatedUser) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final data = quests
        .map(
          (quest) => quest.toMap(),
    )
        .toList();

    await prefs.setString(
      _scopedKey(_questsKey),
      jsonEncode(data),
    );
  }
}