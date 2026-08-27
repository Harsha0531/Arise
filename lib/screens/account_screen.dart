import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class AccountScreen extends StatefulWidget {
  final AppUser user;

  const AccountScreen({
    super.key,
    required this.user,
  });

  @override
  State<AccountScreen> createState() =>
      _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _resetting = false;
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B101C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFF243A63),
            ),
          ),
          title: const Text(
            'LOG OUT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          content: const Text(
            'Your Arise progress will remain saved. '
                'You can log back in later and continue where you left off.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('LOG OUT'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _loggingOut = true;
    });

    try {
      await UserService.logout();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(AccountAction.logout);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logout failed: $e',
          ),
        ),
      );
    }
  }

  Future<void> _resetProgress() async {
    if (_resetting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B101C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Color(0xFF5A2630),
            ),
          ),
          title: const Text(
            'RESET PROGRESS',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          content: const Text(
            'This will permanently delete your current '
                'game progress from this account and its '
                'offline cache.\n\n'
                'Your Firebase account, email and password '
                'will NOT be deleted.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('RESET EVERYTHING'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _resetting = true;
    });

    try {
      await UserService.resetProgress();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(
        AccountAction.resetProgress,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _resetting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reset failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        UserService.getCurrentUserEmail() ?? 'Unknown';

    final uid =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF05070D),
        elevation: 0,
        title: const Text(
          'SYSTEM',
          style: TextStyle(
            color: Color(0xFF4FC3F7),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white70,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'PLAYER IDENTITY',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 28),
              _profileCard(
                email: email,
                uid: uid,
              ),
              const SizedBox(height: 24),
              _sectionTitle('ACCOUNT'),
              const SizedBox(height: 10),
              _actionCard(
                icon: Icons.logout,
                title: 'LOG OUT',
                description:
                'Sign out of this Firebase account. '
                    'Your progress remains saved.',
                onTap: _loggingOut ? null : _logout,
                loading: _loggingOut,
              ),
              const SizedBox(height: 24),
              _sectionTitle('PROGRESSION'),
              const SizedBox(height: 10),
              _actionCard(
                icon: Icons.restart_alt,
                title: 'RESET PROGRESS',
                description:
                'Delete this account\'s game progress '
                    'and start the journey again from zero.',
                destructive: true,
                onTap: _resetting ? null : _resetProgress,
                loading: _resetting,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B101C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF1D2A42),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.cloud_done_outlined,
                      color: Color(0xFF4FC3F7),
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your Firebase account is the identity '
                            'for your Arise data. Local offline '
                            'storage is isolated per account.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard({
    required String email,
    required String uid,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF243A63),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF101C35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4FC3F7),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PLAYER',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(
            label: 'USERNAME',
            value: widget.user.username,
          ),
          const SizedBox(height: 12),
          _infoRow(
            label: 'EMAIL',
            value: email,
          ),
          const SizedBox(height: 12),
          _infoRow(
            label: 'FIREBASE UID',
            value: uid,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF080D16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback? onTap,
    bool destructive = false,
    bool loading = false,
  }) {
    final iconColor = destructive
        ? Colors.redAccent
        : const Color(0xFF4FC3F7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0B101C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: destructive
                ? const Color(0xFF3A2027)
                : const Color(0xFF1D2A42),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: destructive
                    ? const Color(0xFF211117)
                    : const Color(0xFF101C35),
                borderRadius: BorderRadius.circular(13),
              ),
              child: loading
                  ? Padding(
                padding: const EdgeInsets.all(13),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: iconColor,
                ),
              )
                  : Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: destructive
                          ? Colors.redAccent
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right,
              color: onTap == null
                  ? Colors.white24
                  : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

enum AccountAction {
  logout,
  resetProgress,
}