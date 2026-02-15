import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/providers/repository_providers.dart';
import 'package:vantage419/core/providers/spots_provider.dart';
import 'package:vantage419/core/providers/visits_provider.dart';
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

    test('calculates empty stats when no visits', () async {
      final container = ProviderContainer(
        overrides: [
          toledoSpotsProvider.overrideWith((ref) => testSpots),
          visitsProvider.overrideWith(() => FakeVisitsNotifier([])),
        ],
      );

      final stats = await container.read(discoveryStatsProvider.future);

      expect(stats.totalSpots, 3);
      expect(stats.discoveredCount, 0);
      expect(stats.overallProgress, 0.0);
      expect(stats.categoryProgress[SpotCategory.dining]?.discovered, 0);
    });

    test('calculates stats correctly with visits', () async {
      final visits = [
        UserVisit(spotId: 'spot1', visitedAt: DateTime.now()),
        UserVisit(spotId: 'spot2', visitedAt: DateTime.now()),
      ];

      final container = ProviderContainer(
        overrides: [
          toledoSpotsProvider.overrideWith((ref) => testSpots),
          visitsProvider.overrideWith(() => FakeVisitsNotifier(visits)),
        ],
      );

      final stats = await container.read(discoveryStatsProvider.future);

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

class FakeVisitsNotifier extends VisitsNotifier {
  final List<UserVisit> _visits;
  FakeVisitsNotifier(this._visits);

  @override
  Future<List<UserVisit>> build() async => _visits;
}
