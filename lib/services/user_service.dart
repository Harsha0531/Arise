import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import 'storage_service.dart';

class UserService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  // ============================================================
  // CHECK REGISTRATION / LOGIN STATE
  // ============================================================

  static Future<bool> isRegistered() async {
    return _auth.currentUser != null;
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  static Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    try {
      final document = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!document.exists) {
        return null;
      }

      final data = document.data();

      if (data == null) {
        return null;
      }

      return AppUser.fromMap({
        'id': firebaseUser.uid,
        'username': data['username'] ?? '',
        'displayName':
        data['displayName'] ??
            firebaseUser.displayName ??
            '',
        'createdAt': data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp)
            .toDate()
            .toIso8601String()
            : data['createdAt'],
      });
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  static Future<AppUser> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Firebase did not return a user.',
      );
    }

    await firebaseUser.updateDisplayName(
      displayName.trim(),
    );

    final now = DateTime.now();

    await _firestore
        .collection(_usersCollection)
        .doc(firebaseUser.uid)
        .set({
      'username': username.trim(),
      'displayName': displayName.trim(),
      'email': email.trim(),
      'createdAt': Timestamp.fromDate(now),
    });

    return AppUser(
      id: firebaseUser.uid,
      username: username.trim(),
      displayName: displayName.trim(),
      createdAt: now,
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return getCurrentUser();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ============================================================
  // RESET PROGRESS
  // ============================================================

  static Future<void> resetProgress() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated Firebase user.',
      );
    }

    // Reset only this authenticated user's local data.
    await StorageService.resetProgress();

    // Reset the cloud progression document if one exists.
    //
    // User account/profile information is intentionally preserved.
    await _firestore
        .collection(_usersCollection)
        .doc(firebaseUser.uid)
        .set(
      {
        'progress': {
          'level': 1,
          'xp': 0,
          'xpDebt': 0,
          'rewardPoints': 0,
          'rank': 0,
          'strength': 1,
          'intelligence': 1,
          'vitality': 1,
          'discipline': 1,
          'focus': 1,
        },
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  static Future<void> updateUser(
      AppUser user,
      ) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No authenticated Firebase user.',
      );
    }

    await _firestore
        .collection(_usersCollection)
        .doc(firebaseUser.uid)
        .set(
      {
        'username': user.username,
        'displayName': user.displayName,
        'createdAt':
        Timestamp.fromDate(user.createdAt),
      },
      SetOptions(merge: true),
    );

    if (firebaseUser.displayName != user.displayName) {
      await firebaseUser.updateDisplayName(
        user.displayName,
      );
    }
  }

  // ============================================================
  // CLEAR USER / LOGOUT
  // ============================================================

  static Future<void> clearUser() async {
    await _auth.signOut();
  }

  // ============================================================
  // CURRENT USER ID
  // ============================================================

  static Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // CURRENT EMAIL
  // ============================================================

  static String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}