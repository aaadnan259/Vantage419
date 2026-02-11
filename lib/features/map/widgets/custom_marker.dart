import 'package:flutter/material.dart';
import '../../../core/models/spot_category.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/extensions.dart';

/// Category-colored map marker with icon and elevation shadow.
/// S2.4: Uses AnimatedScale from center with elastic bounce curve.
/// S4.4: Sizes defined as static constants for DRY usage.
class CustomMarker extends StatelessWidget {
  const CustomMarker({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  final SpotCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  /// Canonical marker sizes — used by SpotMarkerLayer too (S4.4).
  static const selectedSize = AppConstants.markerSelectedSize;
  static const defaultSize = AppConstants.markerSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.83,
        duration: const Duration(milliseconds: 350),
        curve: isSelected ? Curves.elasticOut : Curves.easeOut,
        child: Container(
          width: selectedSize,
          height: selectedSize,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : context.colors.surface,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withValues(alpha: isSelected ? 0.5 : 0.3),
                blurRadius: isSelected ? 14 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            category.icon,
            size: isSelected ? 24 : 20,
            color: context.colors.primaryBackground,
          ),
        ),
      ),
    );
  }
}
