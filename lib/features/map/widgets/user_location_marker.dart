import 'package:flutter/material.dart';
import 'package:vantage419/core/utils/extensions.dart';

/// Blue pulsing dot for the user's location on the map.
/// Extracted to avoid rebuilding static decoration on every map frame (S5.1).
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  static const _size = 24.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: context.colors.accent,
        shape: BoxShape.circle,
        border: const Border.fromBorderSide(
          BorderSide(color: Colors.white, width: 3),
        ),
      ),
      // Shadow needs runtime color ops
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colors.accent.withValues(alpha: 0.4),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
