import 'package:flutter/material.dart';
import '../../../core/models/spot_category.dart';
import '../../../core/theme/colors.dart';

/// Category-colored map marker with icon and elevation shadow.
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

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 48.0 : 40.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: category.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : VantageColors.surface,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: 0.4),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          category.icon,
          size: isSelected ? 26 : 22,
          color: VantageColors.primaryBackground,
        ),
      ),
    );
  }
}
