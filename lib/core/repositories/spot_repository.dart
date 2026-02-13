import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/models/user_visit.dart';

abstract class SpotRepository {
  /// Fetch all available spots (currently static, future: Supabase)
  Future<List<ToledoSpot>> getSpots();

  /// Load the full visit history for the user
  Future<List<UserVisit>> getVisits();

  /// Log a new visit and return the updated, pruned history
  Future<List<UserVisit>> logVisit(
    String spotId,
    List<UserVisit> currentHistory,
  );
}
