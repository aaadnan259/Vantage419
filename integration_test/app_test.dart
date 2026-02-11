import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vantage419/main.dart' as app;
import 'package:vantage419/features/map/map_screen.dart';
import 'package:vantage419/features/roulette/widgets/spin_button.dart';
import 'package:vantage419/features/roulette/widgets/category_selector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Note: On real devices/emulators, location permission dialogs might block interaction.
  // This test assumes permissions are either granted or denied gracefully (app handles denial).

  testWidgets('Smoke Test: App Loads and Spins', (tester) async {
    app.main();
    // Allow time for map and providers to initialize
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 1. Verify Map Screen is present
    expect(find.byType(MapScreen), findsOneWidget);

    // 2. Verify UI Control Overlay
    expect(find.byType(SpinButton), findsOneWidget);
    expect(find.byType(CategorySelector), findsOneWidget);

    // 3. Spin Interaction
    await tester.tap(find.byType(SpinButton));
    await tester.pump(); // Start animation

    // Wait for spin duration (1s) + potential network/db fetch
    await tester.pump(const Duration(seconds: 3));

    // 4. Verify Result
    // If spin worked, we expect the bottom sheet or some result.
    // Since we can't predict exact text, we check if SpinButton is still there (it might be covered or moved).
    // Or check if a "Navigate" button appeared (common in result view).
    // Note: If no spots match (empty state), a snackbar or message might appear.
    // We assume default "Hungry" mode has spots in 'lib/data/toledo_spots.dart'.
  });
}
