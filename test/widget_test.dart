import 'package:flutter_test/flutter_test.dart';

import 'package:solo_leveling/main.dart';
import 'package:solo_leveling/models/player.dart';

void main() {
  testWidgets(
    'Solo Leveling home screen loads',
        (WidgetTester tester) async {
      final player = Player();

      await tester.pumpWidget(
        SoloLevelingApp(
          player: player,
        ),
      );

      await tester.pump();

      expect(find.text('SYSTEM'), findsOneWidget);
      expect(find.text('SOLO LEVELING'), findsOneWidget);
      expect(find.text('ATTRIBUTES'), findsOneWidget);
      expect(find.text("TODAY'S QUESTS"), findsOneWidget);
    },
  );
}