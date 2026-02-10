import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart';

/// Streams the user's current location as LatLng.
final userLocationProvider = StreamProvider<LatLng>((ref) async* {
  final service = ref.read(locationServiceProvider);

  // Emit current position first
  try {
    final pos = await service.getCurrentPosition();
    yield LatLng(pos.latitude, pos.longitude);
  } catch (_) {
    // Yield nothing if initial fetch fails — UI shows default
  }

  // Then stream updates
  await for (final pos in service.positionStream()) {
    yield LatLng(pos.latitude, pos.longitude);
  }
});
