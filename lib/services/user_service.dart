import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class UserService {
  static const String _userKey = 'solo_leveling_user';

  // ============================================================
  // CHECK REGISTRATION
  // ============================================================

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(_userKey);
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_userKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final map =
      jsonDecode(jsonString) as Map<String, dynamic>;

      return AppUser.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  static Future<AppUser> register({
    required String username,
    required String displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = await getCurrentUser();

    if (existing != null) {
      return existing;
    }

    final now = DateTime.now();

    final user = AppUser(
      id: _generateUserId(now),
      username: username.trim(),
      displayName: displayName.trim(),
      createdAt: now,
    );

    await prefs.setString(
      _userKey,
      jsonEncode(user.toMap()),
    );

    return user;
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  static Future<void> updateUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _userKey,
      jsonEncode(user.toMap()),
    );
  }

  // ============================================================
  // CLEAR USER
  // ============================================================

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userKey);
  }

  // ============================================================
  // USER ID
  // ============================================================

  static Future<String?> getCurrentUserId() async {
    final user = await getCurrentUser();

    return user?.id;
  }

  // ============================================================
  // ID GENERATION
  // ============================================================

  static String _generateUserId(DateTime now) {
    final random = Random();

    return 'player_${now.microsecondsSinceEpoch}_${random.nextInt(999999)}';
  }
}