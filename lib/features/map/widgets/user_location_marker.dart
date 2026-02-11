import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Blue pulsing dot for the user's location on the map.
/// Extracted to avoid rebuilding static decoration on every map frame (S5.1).
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  static const _size = 24.0;

  static const _decoration = BoxDecoration(
    color: VantageColors.accent,
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: _decoration,
      // Shadow needs runtime color ops, kept outside const decoration
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: VantageColors.accent.withValues(alpha: 0.4),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
