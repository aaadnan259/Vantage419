import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';
import 'package:vantage419/core/data_sources/spot_local_data_source.dart';
import 'package:vantage419/core/repositories/spot_repository.dart';
import 'package:vantage419/core/errors/app_exception.dart';

class SpotRepositoryImpl implements SpotRepository {
  final SpotLocalDataSource _dataSource;

  SpotRepositoryImpl(this._dataSource);

  @override
  Future<List<ToledoSpot>> getSpots() async {
    try {
      return await _dataSource.fetchStaticSpots();
    } catch (e) {
      throw RepositoryException('Failed to fetch spots', e);
    }
  }

  @override
  Future<List<UserVisit>> getVisits() async {
    try {
      return await _dataSource.loadVisits();
    } catch (e) {
      // Non-fatal, return empty
      return [];
    }
  }

  @override
  Future<List<UserVisit>> logVisit(
    String spotId,
    List<UserVisit> currentHistory,
  ) async {
    try {
      final updated = [
        ...currentHistory,
        UserVisit(spotId: spotId, visitedAt: DateTime.now()),
      ];
      await _dataSource.saveVisits(updated);
      return await _dataSource.loadVisits(); // Return fresh source of truth
    } catch (e) {
      throw RepositoryException('Failed to log visit', e);
    }
  }
}
