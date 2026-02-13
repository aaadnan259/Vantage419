import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/providers/repository_providers.dart';

/// S3.3: Provides the list of spots from the repository.
/// Replaces the static `toledoSpots` global list.
final toledoSpotsProvider = FutureProvider<List<ToledoSpot>>((ref) async {
  final repository = ref.watch(spotRepositoryProvider);
  return repository.getSpots();
});
