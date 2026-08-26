import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/progression_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final Player player;

  const HomeScreen({
    super.key,
    required this.player,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Player player;

  @override
  void initState() {
    super.initState();
    player = widget.player;
  }

  Future<void> addTestXp() async {
    setState(() {
      ProgressionService.addXpWithDebtHandling(player, 100);
    });

    await StorageService.savePlayer(player);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ProgressionService.getSnapshot(player);

    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(36, 28, 36, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SYSTEM
              const Text(
                'S Y S T E M',
                style: TextStyle(
                  color: Color(0xFF00BFFF),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5,
                ),
              ),

              const SizedBox(height: 24),

              // SOLO LEVELING
              const Text(
                'SOLO LEVELING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 58),

              // RANK CARD
              _rankCard(progress),

              const SizedBox(height: 36),

              // EXPERIENCE
              _experienceCard(progress),

              const SizedBox(height: 48),

              // ATTRIBUTES
              const Text(
                'ATTRIBUTES',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _attributeCard(
                      'STRENGTH',
                      player.strength,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _attributeCard(
                      'INTELLIGENCE',
                      player.intelligence,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _attributeCard(
                      'VITALITY',
                      player.vitality,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _attributeCard(
                      'DISCIPLINE',
                      player.discipline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: (MediaQuery.of(context).size.width - 90) / 2,
                child: _attributeCard(
                  'FOCUS',
                  player.focus,
                ),
              ),

              const SizedBox(height: 54),

              // TODAY'S QUESTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    "TODAY'S QUESTS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    '0 / 0',
                    style: TextStyle(
                      color: Color(0xFF00BFFF),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // EMPTY QUEST CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 46,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF080E1A),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF182C4D),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF00BFFF),
                      size: 48,
                    ),
                    SizedBox(height: 22),
                    Text(
                      'NO QUESTS YET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // TEMPORARY TEST CONTROL
              // We keep this hidden from the actual UI.
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rankCard(dynamic progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(46, 46, 46, 46),
      decoration: BoxDecoration(
        color: const Color(0xFF071326),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF1D4478),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'R A N K',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              letterSpacing: 6,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            progress.rank.name.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF66C7FF),
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _rankSubtitle(progress.rank.name),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 21,
            ),
          ),

          const SizedBox(height: 42),

          Text(
            'LEVEL ${progress.globalLevel}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _rankSubtitle(String rank) {
    switch (rank) {
      case 'unawakened':
        return 'Dormant';
      case 'f':
        return 'Awakened';
      case 'e':
        return 'Hunter';
      case 'd':
        return 'Warlord';
      case 'c':
        return 'Knight';
      case 'b':
        return 'Commander';
      case 'a':
        return 'Sovereign';
      case 's':
        return 'Supreme';
      case 'ss':
        return 'Overlord';
      case 'sss':
        return 'Emperor';
      default:
        return '';
    }
  }

  Widget _experienceCard(dynamic progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 28, 36, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF080E1A),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: const Color(0xFF182C4D),
          width: 1.3,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EXPERIENCE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${progress.currentXp} / ${progress.requiredXp} XP',
                style: const TextStyle(
                  color: Color(0xFF00BFFF),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.progress,
              minHeight: 17,
              backgroundColor: const Color(0xFF172238),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00BFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attributeCard(String name, int value) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF080E1A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF182C4D),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF00BFFF),
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}