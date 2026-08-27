import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/player.dart';
import '../models/quest.dart';
import '../models/rank.dart';

class CloudStorageService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  static const String _usersCollection = 'users';
  static const String _playerCollection = 'player';
  static const String _questsCollection = 'quests';

  static DocumentReference<Map<String, dynamic>>?
  get _userReference {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return null;
    }

    return _firestore
        .collection(_usersCollection)
        .doc(uid);
  }

  static DocumentReference<Map<String, dynamic>>?
  get _playerReference {
    final userReference = _userReference;

    if (userReference == null) {
      return null;
    }

    return userReference
        .collection(_playerCollection)
        .doc('state');
  }

  static CollectionReference<Map<String, dynamic>>?
  get _questsReference {
    final userReference = _userReference;

    if (userReference == null) {
      return null;
    }

    return userReference.collection(_questsCollection);
  }

  // ============================================================
  // PLAYER
  // ============================================================

  static Future<void> savePlayer(Player player) async {
    final reference = _playerReference;

    if (reference == null) {
      return;
    }

    await reference.set(
      {
        'name': player.name,
        'level': player.level,
        'xp': player.xp,
        'xpDebt': player.xpDebt,
        'rewardPoints': player.rewardPoints,
        'rank': player.rank.name,
        'strength': player.strength,
        'intelligence': player.intelligence,
        'vitality': player.vitality,
        'discipline': player.discipline,
        'focus': player.focus,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<Player?> loadPlayer() async {
    final reference = _playerReference;

    if (reference == null) {
      return null;
    }

    final document = await reference.get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null) {
      return null;
    }

    final rankName = data['rank'] as String?;

    final rank = rankName == null
        ? Rank.unawakened
        : Rank.values.firstWhere(
          (value) => value.name == rankName,
      orElse: () => Rank.unawakened,
    );

    return Player(
      name: data['name'] as String? ?? 'Hunter',
      level: _intValue(data['level'], 1),
      xp: _intValue(data['xp'], 0),
      xpDebt: _intValue(data['xpDebt'], 0),
      rewardPoints: _intValue(
        data['rewardPoints'],
        0,
      ),
      rank: rank,
      strength: _intValue(
        data['strength'],
        1,
      ),
      intelligence: _intValue(
        data['intelligence'],
        1,
      ),
      vitality: _intValue(
        data['vitality'],
        1,
      ),
      discipline: _intValue(
        data['discipline'],
        1,
      ),
      focus: _intValue(
        data['focus'],
        1,
      ),
    );
  }

  static Future<bool> hasPlayer() async {
    final reference = _playerReference;

    if (reference == null) {
      return false;
    }

    final document = await reference.get();

    return document.exists;
  }

  // ============================================================
  // QUESTS
  // ============================================================

  static Future<void> saveQuests(
      List<Quest> quests,
      ) async {
    final reference = _questsReference;

    if (reference == null) {
      return;
    }

    final batch = _firestore.batch();

    for (final quest in quests) {
      final questReference =
      reference.doc(quest.id);

      batch.set(
        questReference,
        {
          ...quest.toMap(),
          'updatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  static Future<List<Quest>?> loadQuests() async {
    final reference = _questsReference;

    if (reference == null) {
      return null;
    }

    final snapshot = await reference.get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final quests = <Quest>[];

    for (final document in snapshot.docs) {
      try {
        final data = document.data();

        quests.add(
          Quest.fromMap(
            {
              ...data,
              'id': data['id'] ?? document.id,
            },
          ),
        );
      } catch (_) {
        // Ignore malformed cloud quest records.
      }
    }

    return quests;
  }

  // ============================================================
  // RESET GAME PROGRESS
  // ============================================================

  static Future<void> deleteProgress() async {
    final userReference = _userReference;

    if (userReference == null) {
      return;
    }

    final playerReference =
    userReference
        .collection(_playerCollection)
        .doc('state');

    final questsReference =
    userReference.collection(_questsCollection);

    final questsSnapshot =
    await questsReference.get();

    final batch = _firestore.batch();

    batch.delete(playerReference);

    for (final document in questsSnapshot.docs) {
      batch.delete(document.reference);
    }

    await batch.commit();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int _intValue(
      dynamic value,
      int fallback,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return fallback;
  }
}