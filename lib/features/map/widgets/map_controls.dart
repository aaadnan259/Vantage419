import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/colors.dart';

/// Banner shown when location permissions are denied or services disabled (S1.2).
class LocationErrorBanner extends StatelessWidget {
  const LocationErrorBanner({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    String message;
    String actionLabel;
    VoidCallback? onAction;

    if (error is LocationPermissionDeniedForeverException) {
      message = 'Location access permanently denied';
      actionLabel = 'Open Settings';
      onAction = () => Geolocator.openAppSettings();
    } else if (error is LocationDisabledException) {
      message = 'Location services are off';
      actionLabel = 'Enable';
      onAction = () => Geolocator.openLocationSettings();
    } else if (error is LocationPermissionDeniedException) {
      message = 'Location permission needed for your position';
      actionLabel = 'Settings';
      onAction = () => Geolocator.openAppSettings();
    } else {
      message = 'Location unavailable';
      actionLabel = '';
      onAction = null;
    }

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: VantageColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: VantageColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_off_rounded,
                color: VantageColors.warning,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: VantageColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              if (onAction != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: VantageColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(44, 44),
                  ),
                  child: Text(actionLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner shown when map tiles fail to load (S1.6).
class TileErrorBanner extends StatelessWidget {
  const TileErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: VantageColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: VantageColors.textMuted.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: VantageColors.textMuted,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Map tiles unavailable — check your connection',
                  style: TextStyle(
                    color: VantageColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
