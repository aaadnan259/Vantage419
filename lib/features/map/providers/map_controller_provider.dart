import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';

/// Provides a shared MapController for camera animations.
/// AutoDispose ensures cleanup when MapScreen unmounts.
final mapControllerProvider = Provider.autoDispose<MapController>((ref) {
  final controller = MapController();
  ref.onDispose(controller.dispose);
  return controller;
});
