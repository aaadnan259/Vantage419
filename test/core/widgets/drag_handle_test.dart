import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/core.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';

void main() {
  group('DragHandle', () {
    testWidgets('renders static drag handle by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: VantageTheme.dark,
          home: const Scaffold(body: Center(child: DragHandle())),
        ),
      );

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(2));

      // We check the size of the container
      final size = tester.getSize(containerFinder);
      expect(size.width, 40);
      expect(size.height, 4);
    });

    testWidgets('renders pulsing drag handle when isPulsing is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: VantageTheme.dark,
          home: const Scaffold(
            body: Center(child: DragHandle(isPulsing: true)),
          ),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);

      // Capture initial color
      final containerFinder = find.byType(Container);
      BoxDecoration decoration =
          tester.widget<Container>(containerFinder).decoration as BoxDecoration;
      final initialColor = decoration.color;

      // Pump for half the duration (1200ms total, so 600ms should be at the other end)
      await tester.pump(const Duration(milliseconds: 600));

      decoration =
          tester.widget<Container>(containerFinder).decoration as BoxDecoration;
      final midColor = decoration.color;

      expect(initialColor, isNot(equals(midColor)));
    });
  });
}
