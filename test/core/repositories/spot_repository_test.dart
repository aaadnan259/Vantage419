import 'package:flutter_test/flutter_test.dart'; // Trigger PR sync after conflict resolution
import 'package:vantage419/core/data_sources/spot_local_data_source.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/spot_category.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/repositories/spot_repository_impl.dart';
import 'package:vantage419/core/errors/app_exception.dart';

// Manual Fake implementation to avoid Mockito codegen/runtime issues
class FakeSpotLocalDataSource implements SpotLocalDataSource {
  List<ToledoSpot> _spots = [];
  List<UserVisit> _visits = [];

  // Setters to seed data
  void setSpots(List<ToledoSpot> spots) => _spots = spots;
  void setVisits(List<UserVisit> visits) => _visits = visits;

  // Verification helpers
  int saveCallCount = 0;
  List<UserVisit>? lastSavedVisits;

  // Error simulation
  Exception? fetchError;
  Exception? loadError;
  Exception? saveError;

  @override
  Future<List<ToledoSpot>> fetchStaticSpots() async {
    if (fetchError != null) throw fetchError!;
    return _spots;
  }

  @override
  Future<List<UserVisit>> loadVisits() async {
    if (loadError != null) throw loadError!;
    return _visits;
  }

  @override
  Future<void> saveVisits(List<UserVisit> visits) async {
    if (saveError != null) throw saveError!;
    saveCallCount++;
    lastSavedVisits = visits;
    _visits = visits; // Simulate persistence
  }
}

void main() {
  late SpotRepositoryImpl repository;
  late FakeSpotLocalDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeSpotLocalDataSource();
    repository = SpotRepositoryImpl(fakeDataSource);
  });

  group('SpotRepositoryImpl', () {
    test('getSpots returns data from source', () async {
      final spots = [
        const ToledoSpot(
          id: '1',
          name: 'Test',
          latitude: 0,
          longitude: 0,
          category: SpotCategory.dining,
          vibeCheck: '',
          description: '',
        ),
      ];
      fakeDataSource.setSpots(spots);

      final result = await repository.getSpots();
      expect(result, spots);
    });

    test('getVisits returns data from source', () async {
      final visits = [UserVisit(spotId: '1', visitedAt: DateTime.now())];
      fakeDataSource.setVisits(visits);

      final result = await repository.getVisits();
      expect(result, visits);
    });

    test('logVisit saves and reloads', () async {
      final initialVisit = UserVisit(spotId: '1', visitedAt: DateTime.now());
      final history = [initialVisit];
      fakeDataSource.setVisits(history);

      final result = await repository.logVisit('2', history);

      // Verify save was called
      expect(fakeDataSource.saveCallCount, 1);

      // Verify list grew
      expect(fakeDataSource.lastSavedVisits!.length, 2);
      expect(fakeDataSource.lastSavedVisits!.last.spotId, '2');

      // Verify it returns the fresh list from loadVisits (which our fake updates in saveVisits)
      expect(result.length, 2);
    });

    test('logVisit with empty initial history', () async {
      fakeDataSource.setVisits([]);

      final result = await repository.logVisit('1', []);

      expect(fakeDataSource.saveCallCount, 1);
      expect(fakeDataSource.lastSavedVisits!.length, 1);
      expect(fakeDataSource.lastSavedVisits!.first.spotId, '1');
      expect(result.length, 1);
    });

    test(
      'getSpots throws RepositoryException on data source failure',
      () async {
        final error = Exception('Source failed');
        fakeDataSource.fetchError = error;

        expect(
          () => repository.getSpots(),
          throwsA(
            isA<RepositoryException>()
                .having((e) => e.message, 'message', 'Failed to fetch spots')
                .having((e) => e.originalError, 'originalError', error),
          ),
        );
      },
    );

    test('getVisits returns empty list on data source failure', () async {
      fakeDataSource.loadError = Exception('Source failed');

      final result = await repository.getVisits();
      expect(result, isEmpty);
    });

    test('logVisit throws RepositoryException on save failure', () async {
      final error = Exception('Save failed');
      fakeDataSource.saveError = error;

      expect(
        () => repository.logVisit('1', []),
        throwsA(
          isA<RepositoryException>()
              .having((e) => e.message, 'message', 'Failed to log visit')
              .having((e) => e.originalError, 'originalError', error),
        ),
      );
    });

    test('logVisit throws RepositoryException on reload failure', () async {
      final error = Exception('Reload failed');
      fakeDataSource.loadError = error;

      expect(
        () => repository.logVisit('1', []),
        throwsA(
          isA<RepositoryException>()
              .having((e) => e.message, 'message', 'Failed to log visit')
              .having((e) => e.originalError, 'originalError', error),
        ),
      );
    });
  });
}
