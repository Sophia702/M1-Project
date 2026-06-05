// Smoke test: the app boots to the Home screen with a Start walk action.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aria/app.dart';

void main() {
  testWidgets('Home screen shows greeting and start action', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AriaApp()));
    await tester.pump();

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Start walk'), findsWidgets);
  });
}
