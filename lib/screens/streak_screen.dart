import 'package:flutter/material.dart';

import '../services/streak_service.dart';

class StreakScreen extends StatefulWidget {
  const StreakScreen({
    super.key,
  });

  @override
  State<StreakScreen> createState() =>
      _StreakScreenState();
}

class _StreakScreenState
    extends State<StreakScreen> {
  int currentStreak = 0;

  List<StreakDay> history = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak =
    await StreakService.getCurrentStreak();

    final historyData =
    await StreakService.getHistory(
      days: 30,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      currentStreak = streak;
      history = historyData;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF05070D),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFF05070D),
        elevation: 0,
        title: const Text(
          'STREAK',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4FC3F7),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadStreak,
        child: ListView(
          padding:
          const EdgeInsets.all(20),
          children: [
            _streakCard(),

            const SizedBox(height: 28),

            const Text(
              'LAST 30 DAYS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 14),

            _calendar(),
          ],
        ),
      ),
    );
  }

  Widget _streakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
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
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFF4FC3F7),
            size: 50,
          ),

          const SizedBox(height: 12),

          const Text(
            'CURRENT STREAK',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$currentStreak',
            style: const TextStyle(
              color: Color(0xFF90CAF9),
              fontSize: 50,
              fontWeight: FontWeight.w900,
            ),
          ),

          Text(
            currentStreak == 1
                ? 'DAY'
                : 'DAYS',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101C),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1D2A42),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
        const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (
            context,
            index,
            ) {
          final day = history[index];

          return Tooltip(
            message:
            '${_dateText(day.date)}\n'
                '${day.completedCount}/${day.totalCount} quests',
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(6),
                color: day.completed
                    ? const Color(0xFF315B45)
                    : const Color(0xFF151C2A),
                border: Border.all(
                  color: day.completed
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF26334A),
                ),
              ),
              child: Center(
                child: Text(
                  '${day.date.day}',
                  style: TextStyle(
                    color: day.completed
                        ? Colors.greenAccent
                        : Colors.white38,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _dateText(DateTime date) {
    final month =
    date.month.toString().padLeft(2, '0');

    final day =
    date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}