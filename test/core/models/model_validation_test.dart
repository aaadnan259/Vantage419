import 'package:flutter_test/flutter_test.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/user_visit.dart';

void main() {
  group('ToledoSpot.fromJson (S3.4)', () {
    test('clamps out-of-range latitude', () {
      final spot = ToledoSpot.fromJson({
        'id': 'test',
        'name': 'Test',
        'latitude': 999,
        'longitude': -83.5,
        'category': 'dining',
        'vibeCheck': 'test',
        'description': 'desc',
      });
      expect(spot.latitude, 90.0);
    });

    test('clamps out-of-range longitude', () {
      final spot = ToledoSpot.fromJson({
        'id': 'test',
        'name': 'Test',
        'latitude': 41.6,
        'longitude': -999,
        'category': 'dining',
        'vibeCheck': 'test',
        'description': 'desc',
      });
      expect(spot.longitude, -180.0);
    });

    test('falls back to entertainment for unknown category', () {
      final spot = ToledoSpot.fromJson({
        'id': 'test',
        'name': 'Test',
        'latitude': 41.6,
        'longitude': -83.5,
        'category': 'unknown_category',
        'vibeCheck': 'test',
        'description': 'desc',
      });
      expect(spot.category, SpotCategory.entertainment);
    });

    test('parses valid JSON correctly', () {
      final json = {
        'id': 'rt_001',
        'name': 'Round Trip',
        'latitude': 41.65,
        'longitude': -83.54,
        'category': 'cafe',
        'vibeCheck': 'cozy',
        'description': 'A cozy cafe',
        'address': '123 Main St',
      };
      final restored = ToledoSpot.fromJson(json);
      expect(restored.id, 'rt_001');
      expect(restored.name, 'Round Trip');
      expect(restored.latitude, 41.65);
      expect(restored.longitude, -83.54);
      expect(restored.category, SpotCategory.cafe);
      expect(restored.address, '123 Main St');
    });
  });

  group('UserVisit.fromJson (S3.4)', () {
    test('handles invalid date string gracefully', () {
      final visit = UserVisit.fromJson({
        'spotId': 'test',
        'visitedAt': 'not-a-date',
      });
      expect(visit.spotId, 'test');
      expect(visit.visitedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('handles missing fields gracefully', () {
      final visit = UserVisit.fromJson({});
      expect(visit.spotId, '');
      expect(visit.visitedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('round-trips correctly via toJson', () {
      final now = DateTime(2026, 1, 15, 12, 0);
      final original = UserVisit(spotId: 'rt_001', visitedAt: now, rating: 4);
      final json = original.toJson();
      final restored = UserVisit.fromJson(json);
      expect(restored.spotId, original.spotId);
      expect(restored.visitedAt, original.visitedAt);
      expect(restored.rating, original.rating);
    });
  });
}
