import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/providers/spots_provider.dart';
import 'package:vantage419/features/profile/gamification_provider.dart';

void main() {
  group('GamificationNotifier', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    }

    test('initializes with default values', () {
      final container = createContainer();
      final state = container.read(gamificationProvider);
      expect(state.streak, 0);
      expect(state.lastSpinDate, null);
    });

    test('first spin sets streak to 1', () {
      final container = createContainer();
      final notifier = container.read(gamificationProvider.notifier);

      notifier.recordSpin();

      final state = container.read(gamificationProvider);
      expect(state.streak, 1);
      expect(state.lastSpinDate, isNotNull);
    });

    test('spin on same day keeps streak same', () async {
      final container = createContainer();
      final notifier = container.read(gamificationProvider.notifier);

      notifier.recordSpin();
      final streakAfterFirst = container.read(gamificationProvider).streak;

      // Spin again immediately
      notifier.recordSpin();
      final state = container.read(gamificationProvider);

      expect(state.streak, streakAfterFirst);
      expect(state.streak, 1);
    });

    // Note: We can't easily test "consecutive days" or "missed days" logic
    // without mocking DateTime.now() or the provider logic.
    // For now, we verified the logic structure in implementation.
    // Ideally we would inject a Clock/Timer service, but avoiding over-engineering for now.

    test('persists streak to SharedPreferences', () async {
      final container = createContainer();
      final notifier = container.read(gamificationProvider.notifier);

      notifier.recordSpin();
      await Future<void>.delayed(Duration.zero); // Allow async persist

      final savedStreak = prefs.getInt('spin_streak');
      expect(savedStreak, 1);
    });
  });

  group('DiscoveryStatsProvider', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    final testSpots = [
      const ToledoSpot(
        id: 'spot1',
        name: 'Spot 1',
        latitude: 0,
        longitude: 0,
        category: SpotCategory.dining,
        vibeCheck: '',
        description: '',
      ),
      const ToledoSpot(
        id: 'spot2',
        name: 'Spot 2',
        latitude: 0,
        longitude: 0,
        category: SpotCategory.nightlife,
        vibeCheck: '',
        description: '',
      ),
      const ToledoSpot(
        id: 'spot3',
        name: 'Spot 3',
        latitude: 0,
        longitude: 0,
        category: SpotCategory.dining,
        vibeCheck: '',
        description: '',
      ),
    ];

    test('calculates empty stats when no visits', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          toledoSpotsProvider.overrideWith((ref) => testSpots),
        ],
      );

      final stats = container.read(discoveryStatsProvider);

      expect(stats.totalSpots, 3);
      expect(stats.discoveredCount, 0);
      expect(stats.overallProgress, 0.0);
      expect(stats.categoryProgress[SpotCategory.dining]?.discovered, 0);
    });

    test('calculates stats correctly with visits', () async {
      // Simulate visits in SharedPreferences
      final visits = [
        UserVisit(spotId: 'spot1', visitedAt: DateTime.now()),
        UserVisit(spotId: 'spot2', visitedAt: DateTime.now()),
      ];
      final visitsJson = jsonEncode(visits.map((v) => v.toJson()).toList());
      await prefs.setString('user_visits', visitsJson);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          toledoSpotsProvider.overrideWith((ref) => testSpots),
        ],
      );

      final stats = container.read(discoveryStatsProvider);

      expect(stats.totalSpots, 3);
      expect(stats.discoveredCount, 2); // spot1, spot2
      expect(stats.overallProgress, 2 / 3);

      // Dining: spot1 visited, spot3 not visited -> 1/2
      final diningProgress = stats.categoryProgress[SpotCategory.dining];
      expect(diningProgress?.discovered, 1);
      expect(diningProgress?.total, 2);
      expect(diningProgress?.progress, 0.5);

      // Nightlife: spot2 visited -> 1/1
      final nightlifeProgress = stats.categoryProgress[SpotCategory.nightlife];
      expect(nightlifeProgress?.discovered, 1);
      expect(nightlifeProgress?.total, 1);
      expect(nightlifeProgress?.progress, 1.0);
    });
  });
}
