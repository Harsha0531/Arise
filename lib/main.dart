import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/streak_screen.dart';
import 'models/player.dart';
import 'models/rank.dart';
import 'models/quest.dart';
import 'services/progression_service.dart';
import 'services/quest_service.dart';
import 'services/storage_service.dart';
import 'widgets/daily_timer_ring.dart';

import 'models/user.dart';
import 'services/user_service.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final isRegistered = await UserService.isRegistered();

  if (!isRegistered) {
    runApp(const SoloLevelingApp.registration());
    return;
  }

  final user = await UserService.getCurrentUser();

  if (user == null) {
    await UserService.clearUser();
    runApp(const SoloLevelingApp.registration());
    return;
  }

  final player = await StorageService.loadPlayer();

  runApp(
    SoloLevelingApp(
      player: player,
      user: user,
    ),
  );
}

class SoloLevelingApp extends StatelessWidget {
  final Player? player;
  final AppUser? user;
  final bool registration;

  const SoloLevelingApp({
    super.key,
    required Player player,
    required AppUser user,
  })  : player = player,
        user = user,
        registration = false;

  const SoloLevelingApp.registration({
    super.key,
  })  : player = null,
        user = null,
        registration = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Solo Leveling',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF05070D),
        fontFamily: 'sans',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFF7C4DFF),
        ),
      ),
      home: registration
          ? RegistrationScreen(
        onRegistered: _onRegistered,
      )
          : HomeScreen(player: player!),
    );
  }

  Future<void> _onRegistered(AppUser user) async {
    final player = await StorageService.loadPlayer();

    player.name = user.displayName;

    await StorageService.savePlayer(player);

    final navigator = navigatorKey.currentState;
    if (navigator == null || !navigator.mounted) {
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(player: player),
      ),
    );
  }
}
