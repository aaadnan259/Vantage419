import 'package:flutter/material.dart';
import '../../../core/models/spot_category.dart';
import '../../../core/theme/colors.dart';

/// Category-colored map marker with icon and elevation shadow.
/// S2.4: Uses AnimatedScale from center with elastic bounce curve.
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.83,
        duration: const Duration(milliseconds: 350),
        curve: isSelected ? Curves.elasticOut : Curves.easeOut,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : VantageColors.surface,
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
            color: VantageColors.primaryBackground,
          ),
        ),
      ),
    );
  }
}
