import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/core.dart';

void main() {
  group('DragHandle', () {
    testWidgets('renders non-pulsing handle by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: DragHandle())),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(find.byType(DragHandle), findsOneWidget);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(2));

      // opacity is 0.4 for non-pulsing
      final color = decoration.color!;
      expect(color.a, closeTo(0.4, 0.01));
    });

    testWidgets('renders pulsing handle with AnimatedBuilder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: DragHandle(isPulsing: true))),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });
  });
}
