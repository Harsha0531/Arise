import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/player.dart';
import 'models/user.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SoloLevelingApp());
}

class SoloLevelingApp extends StatelessWidget {
  const SoloLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solo Leveling',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF05070D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4FC3F7),
          secondary: Color(0xFF7C4DFF),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return FutureBuilder<AppUser?>(
          future: UserService.getCurrentUser(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final appUser = userSnapshot.data;

            if (appUser == null) {
              return RegistrationScreen(
                onRegistered: (AppUser registeredUser) async {
                  // Firebase authentication state is already
                  // handled by AuthGate. RegistrationScreen only
                  // needs to complete its callback here.
                  await Future<void>.value();
                },
              );
            }

            return FutureBuilder<Player>(
              future: StorageService.loadPlayer(),
              builder: (context, playerSnapshot) {
                if (playerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const _LoadingScreen();
                }

                final player = playerSnapshot.data ??
                    Player(name: appUser.displayName);

                return HomeScreen(
                  player: player,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF05070D),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4FC3F7),
        ),
      ),
    );
  }
}