import 'package:flutter_test/flutter_test.dart';

import 'package:solo_leveling/main.dart';

void main() {
  testWidgets('Solo Leveling app loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const SoloLevelingApp(),
    );

    await tester.pump();

    expect(
      find.byType(SoloLevelingApp),
      findsOneWidget,
    );
  });
}