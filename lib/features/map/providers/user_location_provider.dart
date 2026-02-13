import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/services/location_service.dart';

/// Streams the user's current location as LatLng.
/// Errors propagate to the UI via AsyncValue.error so MapScreen
/// can show contextual feedback (denied, disabled, etc.).
final userLocationProvider = StreamProvider<LatLng>((ref) async* {
  final service = ref.read(locationServiceProvider);

  // Emit current position first — throws typed exceptions on failure
  final pos = await service.getCurrentPosition();
  yield LatLng(pos.latitude, pos.longitude);

  // Then stream updates
  await for (final pos in service.positionStream()) {
    yield LatLng(pos.latitude, pos.longitude);
  }
});
