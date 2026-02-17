import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/theme/palette.dart';
import 'package:vantage419/features/roulette/widgets/spin_button.dart';

void main() {
  testWidgets('SpinButton shows tooltip on first launch and dismisses on spin', (
    tester,
  ) async {
    // 1. Setup Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // 2. Build the widget with ProviderScope override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: ThemeData(extensions: const [VantagePalette.light]),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                // Determine if we are spinning based on some external state if needed,
                // but simpler to just wrap SpinButton in a widget that manages state.
                return _TestWrapper();
              },
            ),
          ),
        ),
      ),
    );

    // 3. Verify tooltip is visible
    expect(find.text('Tap to discover!'), findsOneWidget);

    // 4. Tap to spin
    await tester.tap(find.byType(SpinButton));
    await tester.pump(); // Start animation
    await tester.pump(
      const Duration(milliseconds: 50),
    ); // Advance animation slightly

    // 5. Verify tooltip is gone
    expect(find.text('Tap to discover!'), findsNothing);

    // 6. Verify SharedPreferences updated
    expect(prefs.getBool('hasSpunOnce'), isTrue);
  });

  testWidgets('SpinButton does not show tooltip if already spun', (
    tester,
  ) async {
    // 1. Setup Mock SharedPreferences with hasSpunOnce = true
    SharedPreferences.setMockInitialValues({'hasSpunOnce': true});
    final prefs = await SharedPreferences.getInstance();

    // 2. Build the widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: ThemeData(extensions: const [VantagePalette.light]),
          home: Scaffold(body: SpinButton(onSpin: () {}, isSpinning: false)),
        ),
      ),
    );

    // 3. Verify tooltip is NOT visible
    expect(find.text('Tap to discover!'), findsNothing);
  });
}

class _TestWrapper extends StatefulWidget {
  @override
  State<_TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<_TestWrapper> {
  bool isSpinning = false;

  @override
  Widget build(BuildContext context) {
    return SpinButton(
      onSpin: () {
        setState(() {
          isSpinning = true;
        });
      },
      isSpinning: isSpinning,
    );
  }
}
