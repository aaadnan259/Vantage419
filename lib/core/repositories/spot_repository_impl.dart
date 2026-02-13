import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/data_sources/spot_local_data_source.dart';
import 'package:vantage419/core/repositories/spot_repository.dart';

class SpotRepositoryImpl implements SpotRepository {
  final SpotLocalDataSource _dataSource;

  SpotRepositoryImpl(this._dataSource);

  @override
  Future<List<ToledoSpot>> getSpots() => _dataSource.fetchStaticSpots();

  @override
  Future<List<UserVisit>> getVisits() => _dataSource.loadVisits();

  @override
  Future<List<UserVisit>> logVisit(
    String spotId,
    List<UserVisit> currentHistory,
  ) async {
    final updated = [
      ...currentHistory,
      UserVisit(spotId: spotId, visitedAt: DateTime.now()),
    ];
    await _dataSource.saveVisits(updated);
    return _dataSource.loadVisits(); // Return fresh source of truth
  }
}
