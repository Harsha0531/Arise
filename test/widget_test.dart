import 'package:flutter_test/flutter_test.dart';

import 'package:solo_leveling/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloLevelingApp());

    // Allow the Firebase authentication gate to initialize.
    await tester.pump();

    expect(find.byType(SoloLevelingApp), findsOneWidget);
  });
}