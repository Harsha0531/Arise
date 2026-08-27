import 'package:flutter/material.dart';
import 'screens/streak_screen.dart';
import 'models/player.dart';
import 'models/rank.dart';
import 'models/quest.dart';
import 'services/progression_service.dart';
import 'services/quest_service.dart';
import 'services/storage_service.dart';
import 'widgets/daily_timer_ring.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final player = await StorageService.loadPlayer();

  runApp(
    SoloLevelingApp(player: player),
  );
}

class SoloLevelingApp extends StatelessWidget {
  final Player player;

  const SoloLevelingApp({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: HomeScreen(player: player),
    );
  }
}

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

  List<Quest> quests = [];

  bool questsLoading = true;

  @override
  void initState() {
    super.initState();

    player = widget.player;

    _loadTodayQuests();
  }

  Future<void> _loadTodayQuests() async {
    final loadedQuests =
    await QuestService.getTodayQuests();

    if (!mounted) {
      return;
    }

    setState(() {
      quests = loadedQuests;
      questsLoading = false;
    });
  }

  Future<void> _completeQuest(Quest quest) async {
    if (quest.completed) {
      return;
    }

    int levelsGained = 0;

    setState(() {
      quest.completed = true;

      levelsGained = ProgressionService.addXp(
        player,
        quest.xpReward,
      );
    });

    await StorageService.savePlayer(player);
    await StorageService.saveQuests(quests);

    if (levelsGained > 0 && mounted) {
      await _showLevelUpDialog(levelsGained);
    }
  }

  Future<void> _showLevelUpDialog(
      int levelsGained,
      ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0B101C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color(0xFF243A63),
            ),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFF4FC3F7),
                size: 42,
              ),
              SizedBox(height: 12),
              Text(
                'LEVEL UP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEVEL ${player.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                levelsGained == 1
                    ? '+1 REWARD POINT'
                    : '+$levelsGained REWARD POINTS',
                style: const TextStyle(
                  color: Color(0xFF90CAF9),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CONTINUE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _spendRewardPoint(
      bool Function(Player) spendPoint,
      ) async {
    if (player.rewardPoints <= 0) {
      return;
    }

    final spent = spendPoint(player);

    if (!spent) {
      return;
    }

    setState(() {});

    await StorageService.savePlayer(player);
  }

  @override
  Widget build(BuildContext context) {
    final progression =
    ProgressionService.getSnapshot(player);

    final completedCount =
        quests.where((quest) => quest.completed).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'SYSTEM',
                style: TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'SOLO LEVELING',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'Streak',
                    icon: const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFF4FC3F7),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                          const StreakScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _rankCard(progression),

              const SizedBox(height: 20),

              _xpCard(progression),

              const SizedBox(height: 16),

              _rewardPointsCard(),

              const SizedBox(height: 24),

              const Text(
                'ATTRIBUTES',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 12),

              _attributes(),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Text(
                    "TODAY'S QUESTS",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(width: 10),

                  DailyTimerRing(
                    now: DateTime.now(),
                  ),

                  const Spacer(),

                  Text(
                    '$completedCount / ${quests.length}',
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _quests(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rankCard(
      ProgressionSnapshot progression,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF101C35),
            Color(0xFF080D19),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF243A63),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'RANK',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _rankName(progression.rank),
            style: const TextStyle(
              color: Color(0xFF90CAF9),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            _rankTitle(progression.rank),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'LEVEL ${progression.globalLevel}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _xpCard(
      ProgressionSnapshot progression,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1D2A42),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EXPERIENCE',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              Text(
                '${progression.currentXp} / ${progression.requiredXp} XP',
                style: const TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progression.progress,
              minHeight: 10,
              backgroundColor:
              const Color(0xFF1A2233),
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                Color(0xFF4FC3F7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardPointsCard() {
    final hasPoints = player.rewardPoints > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPoints
              ? const Color(0xFF315B45)
              : const Color(0xFF1D2A42),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.stars,
            color: Color(0xFF4FC3F7),
            size: 30,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'REWARD POINTS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${player.rewardPoints} unspent',
                  style: TextStyle(
                    color: hasPoints
                        ? const Color(0xFF4FC3F7)
                        : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          if (hasPoints)
            const Text(
              'ALLOCATE',
              style: TextStyle(
                color: Color(0xFF4FC3F7),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _attributes() {
    return GridView.count(
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: [
        _Attribute(
          name: 'STRENGTH',
          value: player.strength,
          canSpend: player.rewardPoints > 0,
          onSpend: () => _spendRewardPoint(
            ProgressionService.increaseStrength,
          ),
        ),
        _Attribute(
          name: 'INTELLIGENCE',
          value: player.intelligence,
          canSpend: player.rewardPoints > 0,
          onSpend: () => _spendRewardPoint(
            ProgressionService.increaseIntelligence,
          ),
        ),
        _Attribute(
          name: 'VITALITY',
          value: player.vitality,
          canSpend: player.rewardPoints > 0,
          onSpend: () => _spendRewardPoint(
            ProgressionService.increaseVitality,
          ),
        ),
        _Attribute(
          name: 'DISCIPLINE',
          value: player.discipline,
          canSpend: player.rewardPoints > 0,
          onSpend: () => _spendRewardPoint(
            ProgressionService.increaseDiscipline,
          ),
        ),
        _Attribute(
          name: 'FOCUS',
          value: player.focus,
          canSpend: player.rewardPoints > 0,
          onSpend: () => _spendRewardPoint(
            ProgressionService.increaseFocus,
          ),
        ),
      ],
    );
  }

  Widget _quests() {
    if (questsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            color: Color(0xFF4FC3F7),
          ),
        ),
      );
    }

    if (quests.isEmpty) {
      return _emptyQuestCard();
    }

    return Column(
      children: quests.map((quest) {
        return Padding(
          padding:
          const EdgeInsets.only(bottom: 10),
          child: _questCard(quest),
        );
      }).toList(),
    );
  }

  Widget _questCard(Quest quest) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: quest.completed
              ? const Color(0xFF315B45)
              : const Color(0xFF1D2A42),
        ),
      ),
      child: Row(
        children: [
          Icon(
            quest.completed
                ? Icons.check_circle
                : Icons.auto_awesome,
            color: quest.completed
                ? Colors.greenAccent
                : const Color(0xFF4FC3F7),
            size: 32,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  quest.description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '+${quest.xpReward} XP',
                  style: const TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          quest.completed
              ? const Text(
            'DONE',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          )
              : ElevatedButton(
            onPressed: () =>
                _completeQuest(quest),
            child: const Text('COMPLETE'),
          ),
        ],
      ),
    );
  }

  Widget _emptyQuestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1D2A42),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 34,
            color: Color(0xFF4FC3F7),
          ),
          SizedBox(height: 12),
          Text(
            'NO QUESTS YET',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your System is waiting for initialization.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _rankName(Rank rank) {
    switch (rank) {
      case Rank.unawakened:
        return 'UNAWAKENED';
      case Rank.f:
        return 'F';
      case Rank.e:
        return 'E';
      case Rank.d:
        return 'D';
      case Rank.c:
        return 'C';
      case Rank.b:
        return 'B';
      case Rank.a:
        return 'A';
      case Rank.s:
        return 'S';
      case Rank.ss:
        return 'SS';
      case Rank.sss:
        return 'SSS';
    }
  }

  String _rankTitle(Rank rank) {
    switch (rank) {
      case Rank.unawakened:
        return 'Dormant';
      case Rank.f:
        return 'Awakened';
      case Rank.e:
        return 'Hunter';
      case Rank.d:
        return 'Warlord';
      case Rank.c:
        return 'Knight';
      case Rank.b:
        return 'Commander';
      case Rank.a:
        return 'Sovereign';
      case Rank.s:
        return 'Supreme';
      case Rank.ss:
        return 'Overlord';
      case Rank.sss:
        return 'Emperor';
    }
  }
}

class _Attribute extends StatelessWidget {
  final String name;
  final int value;
  final bool canSpend;
  final VoidCallback onSpend;

  const _Attribute({
    required this.name,
    required this.value,
    required this.canSpend,
    required this.onSpend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1D2A42),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Text(
            '$value',
            style: const TextStyle(
              color: Color(0xFF4FC3F7),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(width: 5),

          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: canSpend ? onSpend : null,
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}