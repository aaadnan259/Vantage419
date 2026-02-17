import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';

void main() {
  group('ToledoSpot', () {
    test('parses valid JSON correctly', () {
      final json = {
        'id': 'test_001',
        'name': 'Test Spot',
        'latitude': 41.65,
        'longitude': -83.54,
        'category': 'dining',
        'vibeCheck': 'Great vibes',
        'description': 'A test spot',
      };

      final restored = ToledoSpot.fromJson(json);

      expect(restored.id, 'test_001');
      expect(restored.name, 'Test Spot');
      expect(restored.latitude, 41.65);
      expect(restored.longitude, -83.54);
      expect(restored.category, SpotCategory.dining);
      expect(restored.vibeCheck, 'Great vibes');
    });
  });

  group('SpotCategory', () {
    test('all categories have display metadata', () {
      for (final cat in SpotCategory.values) {
        expect(cat.displayName.isNotEmpty, true);
        expect(cat.icon, isNotNull);
        expect(cat.color, isNotNull);
      }
    });
  });

  group('UserVisit', () {
    test('toJson and fromJson round-trip', () {
      final visit = UserVisit(
        spotId: 'din_001',
        visitedAt: DateTime(2024, 1, 15),
        rating: 4,
      );

      final json = visit.toJson();
      final restored = UserVisit.fromJson(json);

      expect(restored.spotId, visit.spotId);
      expect(restored.visitedAt, visit.visitedAt);
      expect(restored.rating, visit.rating);
    });
  });
}
