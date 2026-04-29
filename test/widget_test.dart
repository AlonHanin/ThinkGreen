import 'package:flutter_test/flutter_test.dart';
import 'package:think_green/main.dart';

void main() {
  testWidgets('shows the splash screen title', (tester) async {
    await tester.pumpWidget(buildThinkGreenApp());

    expect(find.text('Think Green!'), findsOneWidget);
  });
}
