import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vantage419/core/utils/constants.dart';

/// Helper class to handle map camera animations.
class MapCameraAnimator {
  final TickerProvider vsync;

  AnimationController? _animController;

  MapCameraAnimator({required this.vsync});

  /// Animates the map camera to the target location and zoom level.
  ///
  /// Cancels any existing animation before starting a new one.
  void animateTo(MapController mapController, LatLng target, double zoom) {
    // Cancel any in-flight camera animation to avoid leaks
    _animController?.dispose();

    final cam = mapController.camera;
    final startLat = cam.center.latitude;
    final startLng = cam.center.longitude;
    final startZoom = cam.zoom;

    final controller = AnimationController(
      vsync: vsync,
      duration: AppConstants.cameraDuration,
    );
    _animController = controller;

    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      final t = curve.value;
      mapController.move(
        LatLng(
          startLat + (target.latitude - startLat) * t,
          startLng + (target.longitude - startLng) * t,
        ),
        startZoom + (zoom - startZoom) * t,
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (_animController == controller) {
          _animController = null;
        }
      }
    });

    controller.forward();
  }

  /// Clean up resources.
  void dispose() {
    _animController?.dispose();
    _animController = null;
  }
}
