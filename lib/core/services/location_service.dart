import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps Geolocator for location permissions and position stream.
class LocationService {
  /// Check and request permissions, then return current position.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedForeverException();
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Continuous position stream with 10m distance filter.
  Stream<Position> positionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}

// -- Typed exceptions so the UI can react differently to each case --

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

class LocationDisabledException extends LocationServiceException {
  LocationDisabledException()
    : super('Location services are disabled. Enable them in device settings.');
}

class LocationPermissionDeniedException extends LocationServiceException {
  LocationPermissionDeniedException()
    : super('Location permission denied. We need it to show your position.');
}

class LocationPermissionDeniedForeverException
    extends LocationServiceException {
  LocationPermissionDeniedForeverException()
    : super(
        'Location permission permanently denied. Please enable in Settings.',
      );
}

/// Global provider for LocationService.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
