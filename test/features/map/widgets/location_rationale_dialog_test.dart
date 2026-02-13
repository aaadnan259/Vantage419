import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/theme/vantage_theme.dart';
import 'package:vantage419/features/map/widgets/location_rationale_dialog.dart';

void main() {
  group('LocationRationaleDialog', () {
    Widget buildTestWidget() {
      return MaterialApp(
        theme: VantageTheme.dark,
        home: const Scaffold(body: SizedBox.shrink()),
      );
    }

    testWidgets('shows dialog with expected content', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Show dialog
      final context = tester.element(find.byType(Scaffold));
      // ignore: unawaited_futures — we intentionally fire-and-forget to pump the dialog
      unawaited(LocationRationaleDialog.show(context));
      await tester.pumpAndSettle();

      expect(find.text('Location Access'), findsOneWidget);
      expect(find.text('Enable Location'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
      expect(find.textContaining('Vantage uses your location'), findsOneWidget);
    });

    testWidgets('returns true when Enable Location is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final context = tester.element(find.byType(Scaffold));
      final future = LocationRationaleDialog.show(context);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enable Location'));
      await tester.pumpAndSettle();

      expect(await future, isTrue);
    });

    testWidgets('returns false when Not Now is tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final context = tester.element(find.byType(Scaffold));
      final future = LocationRationaleDialog.show(context);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(await future, isFalse);
    });
  });

  group('ToledoSpot.fromJson edge cases', () {
    test('handles spots.json format with all fields', () {
      final spot = ToledoSpot.fromJson({
        'id': 'test_001',
        'name': 'Test Spot',
        'latitude': 41.6528,
        'longitude': -83.5379,
        'category': 'dining',
        'vibeCheck': 'Great vibe',
        'description': 'A test spot',
        'imageUrl': 'https://example.com/img.jpg',
        'tags': ['Cozy', 'Casual'],
      });

      expect(spot.id, 'test_001');
      expect(spot.name, 'Test Spot');
      expect(spot.category, SpotCategory.dining);
      expect(spot.tags, ['Cozy', 'Casual']);
      expect(spot.imageUrl, 'https://example.com/img.jpg');
    });

    test('handles missing optional fields', () {
      final spot = ToledoSpot.fromJson({
        'id': 'min_001',
        'name': 'Minimal',
        'latitude': 0,
        'longitude': 0,
        'category': 'cafe',
        'vibeCheck': 'ok',
        'description': 'minimal',
      });

      expect(spot.imageUrl, isNull);
      expect(spot.address, isNull);
      expect(spot.tags, isEmpty);
    });
  });
}
