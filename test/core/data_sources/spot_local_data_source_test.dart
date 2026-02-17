import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantage419/core/data_sources/spot_local_data_source.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/services/performance_service.dart';

class FakePerformanceService extends PerformanceService {
  final Map<String, FakeTrace> traces = {};

  @override
  Trace startTrace(String name) {
    final trace = FakeTrace(name);
    traces[name] = trace;
    trace.start();
    return trace;
  }
}

class FakeTrace extends Trace {
  FakeTrace(super.name);

  bool started = false;
  bool stopped = false;
  final Map<String, int> metrics = {};

  @override
  void start() {
    started = true;
  }

  @override
  void stop() {
    stopped = true;
  }

  @override
  void setMetric(String metricName, int value) {
    metrics[metricName] = value;
  }
}

void main() {
  late SpotLocalDataSource dataSource;
  late SharedPreferences prefs;
  late FakePerformanceService performanceService;

  const validSpotsJson = '''
[
  {
    "id": "spot_1",
    "name": "Test Spot 1",
    "latitude": 41.6528,
    "longitude": -83.5379,
    "category": "dining",
    "vibeCheck": "Chill",
    "description": "A nice place",
    "imageUrl": "http://example.com/image.jpg",
    "address": "123 Main St",
    "tags": ["food", "drinks"]
  },
  {
    "id": "spot_2",
    "name": "Test Spot 2",
    "latitude": 41.6530,
    "longitude": -83.5380,
    "category": "recreation",
    "vibeCheck": "Fun",
    "description": "A fun place"
  }
]
''';

  void setMockAssets(String? jsonContent) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message != null && jsonContent != null) {
           final key = utf8.decode(message.buffer.asUint8List());
           if (key == 'assets/data/spots.json') {
              return ByteData.view(utf8.encode(jsonContent).buffer);
           }
        }
        return null;
      },
    );
  }

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    performanceService = FakePerformanceService();
    dataSource = SpotLocalDataSource(prefs, performanceService);

    // Default: Clear any mock handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);

    // Clear rootBundle cache to ensure fresh load
    rootBundle.evict('assets/data/spots.json');
  });

  group('fetchStaticSpots', () {
    test('returns parsed spots on success', () async {
      setMockAssets(validSpotsJson);

      final spots = await dataSource.fetchStaticSpots();

      expect(spots.length, 2);
      expect(spots[0].id, 'spot_1');
      expect(spots[0].name, 'Test Spot 1');
      expect(spots[0].category, SpotCategory.dining);
      expect(spots[1].id, 'spot_2');
      expect(spots[1].category, SpotCategory.recreation);

      // Verify trace
      expect(performanceService.traces.containsKey('fetch_static_spots'), isTrue);
      final trace = performanceService.traces['fetch_static_spots']!;
      expect(trace.stopped, isTrue);
      expect(trace.metrics['spot_count'], 2);
    });

    test('caches spots after first load', () async {
      setMockAssets(validSpotsJson);

      final spots1 = await dataSource.fetchStaticSpots();

      // Clear the mock handler to prove subsequent calls don't hit assets
      setMockAssets(null); // This sets handler to return null

      final spots2 = await dataSource.fetchStaticSpots();

      expect(spots2, same(spots1));
      expect(spots2.length, 2);
    });

    test('returns empty list on error', () async {
      setMockAssets('INVALID JSON');

      final spots = await dataSource.fetchStaticSpots();
      expect(spots, isEmpty);
    });
  });

  group('loadVisits', () {
    test('returns empty list when no visits saved', () async {
      final visits = await dataSource.loadVisits();
      expect(visits, isEmpty);
    });

    test('returns parsed visits when valid data saved', () async {
      final now = DateTime.now();
      final visit = UserVisit(
        spotId: 'spot_1',
        visitedAt: now,
        rating: 5,
      );
      // Manually save valid JSON to prefs
      final jsonList = [visit.toJson()];
      await prefs.setString('user_visits', jsonEncode(jsonList));

      final visits = await dataSource.loadVisits();
      expect(visits.length, 1);
      expect(visits.first.spotId, 'spot_1');
    });

    test('clears corrupt data and returns empty list', () async {
      await prefs.setString('user_visits', 'NOT VALID JSON');

      final visits = await dataSource.loadVisits();
      expect(visits, isEmpty);
      expect(prefs.containsKey('user_visits'), isFalse);
    });
  });

  group('saveVisits', () {
    test('saves visits correctly', () async {
      final now = DateTime.now();
      final visits = [
        UserVisit(spotId: '1', visitedAt: now, rating: 5),
      ];

      await dataSource.saveVisits(visits);

      final storedJson = prefs.getString('user_visits');
      expect(storedJson, isNotNull);
      final decoded = jsonDecode(storedJson!) as List;
      expect(decoded.length, 1);
      expect(decoded[0]['spotId'], '1');
    });

    test('prunes visits older than 60 days', () async {
      final now = DateTime.now();
      final recent = UserVisit(spotId: 'recent', visitedAt: now, rating: 5);
      final old = UserVisit(
        spotId: 'old',
        visitedAt: now.subtract(const Duration(days: 61)),
        rating: 3,
      );

      await dataSource.saveVisits([recent, old]);

      final storedJson = prefs.getString('user_visits');
      final decoded = jsonDecode(storedJson!) as List;

      expect(decoded.length, 1);
      expect(decoded[0]['spotId'], 'recent');
    });

    test('limits max visits to 500', () async {
      final now = DateTime.now();
      // Create 505 visits
      final visits = List.generate(505, (index) {
        return UserVisit(
          spotId: 'spot_$index',
          visitedAt: now.subtract(Duration(minutes: index)), // Newer first
          rating: 4,
        );
      });

      await dataSource.saveVisits(visits);

      final storedJson = prefs.getString('user_visits');
      final decoded = jsonDecode(storedJson!) as List;

      expect(decoded.length, 500);
      expect(decoded.first['spotId'], 'spot_0');
      expect(decoded.last['spotId'], 'spot_499');
    });
  });
}
