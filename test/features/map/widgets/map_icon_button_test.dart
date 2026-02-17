import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/features/map/widgets/map_icon_button.dart';
import 'package:vantage419/core/theme/palette.dart';

void main() {
  testWidgets('MapIconButton renders correctly and handles taps',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const [
            VantagePalette.light,
          ],
        ),
        home: Scaffold(
          body: MapIconButton(
            icon: Icons.add,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    // Verify icon is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the button
    await tester.tap(find.byType(MapIconButton));
    await tester.pump();

    // Verify callback was called
    expect(tapped, isTrue);
  });
}
