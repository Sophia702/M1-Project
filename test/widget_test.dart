// Smoke test: with onboarding already completed, the app boots to Home.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aria/app.dart';

void main() {
  testWidgets('Boots to Home when onboarded', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarded': true});

    await tester.pumpWidget(const ProviderScope(child: AriaApp()));
    // Let the onboarded-flag FutureBuilder resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Welcome,'), findsOneWidget);
    expect(find.text('Start walk'), findsWidgets);
  });
}
