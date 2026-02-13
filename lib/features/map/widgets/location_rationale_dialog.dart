import 'package:flutter/material.dart';
import 'package:vantage419/core/utils/extensions.dart';

/// Shows a friendly explanation before requesting location permission.
/// Android best practice: explain rationale before the system dialog.
class LocationRationaleDialog extends StatelessWidget {
  const LocationRationaleDialog({super.key});

  /// Returns true if user accepted, false if declined.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LocationRationaleDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.location_on_rounded, color: context.colors.accent),
          const SizedBox(width: 10),
          Text(
            'Location Access',
            style: TextStyle(color: context.colors.textPrimary),
          ),
        ],
      ),
      content: Text(
        'Vantage uses your location to show nearby spots on the map '
        'and help you discover places around Toledo.\n\n'
        'Your location data stays on your device — we never share it.',
        style: TextStyle(color: context.colors.textSecondary, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Not Now',
            style: TextStyle(color: context.colors.textMuted),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: context.colors.accent),
          child: const Text('Enable Location'),
        ),
      ],
    );
  }
}
