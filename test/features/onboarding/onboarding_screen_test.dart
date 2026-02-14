import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';
import 'package:vantage419/features/onboarding/onboarding_screen.dart';

void main() {
  group('OnboardingScreen', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: VantageTheme.dark,
          home: const OnboardingScreen(),
        ),
      );
    }

    testWidgets('renders first onboarding page', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Spin to Discover'), findsOneWidget);
      expect(find.byIcon(Icons.casino_rounded), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Next button advances to second page', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Filter Your Mood'), findsOneWidget);
    });

    testWidgets('can advance through all pages', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Page 1 → 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Filter Your Mood'), findsOneWidget);

      // Page 2 → 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Navigate Instantly'), findsOneWidget);

      // Last page shows "Let's Go" instead of "Next"
      expect(find.text("Let's Go"), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('shows correct number of page indicators', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 3 animated containers for page dots
      final dots = find.byType(AnimatedContainer);
      expect(dots, findsNWidgets(3));
    });
  });
}
