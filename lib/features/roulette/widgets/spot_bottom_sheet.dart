import 'package:flutter/material.dart';
import '../../../core/models/toledo_spot.dart';
import '../../../core/services/navigation_service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/extensions.dart';

/// Draggable bottom sheet showing selected spot details.
class SpotBottomSheet extends StatelessWidget {
  const SpotBottomSheet({super.key, required this.spot, required this.onClose});

  final ToledoSpot spot;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.15,
      maxChildSize: 0.80,
      snap: true,
      snapSizes: const [0.40, 0.80],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: VantageColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VantageColors.textMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot.name,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: VantageColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _CategoryBadge(category: spot.category),
                        ],
                      ),
                    ),
                    _NavigateButton(spot: spot),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Vibe check — prominent display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: spot.category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: spot.category.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: spot.category.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        spot.vibeCheck,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: spot.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  spot.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: VantageColors.textSecondary,
                  ),
                ),
              ),

              if (spot.address != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: VantageColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          spot.address!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: VantageColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final dynamic category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 14, color: category.color),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(
              color: category.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigateButton extends StatefulWidget {
  const _NavigateButton({required this.spot});

  final ToledoSpot spot;

  @override
  State<_NavigateButton> createState() => _NavigateButtonState();
}

class _NavigateButtonState extends State<_NavigateButton> {
  bool _isLaunching = false;

  Future<void> _onNavigate() async {
    if (_isLaunching) return;
    setState(() => _isLaunching = true);

    final success = await NavigationService().navigateTo(
      latitude: widget.spot.latitude,
      longitude: widget.spot.longitude,
      label: widget.spot.name,
    );

    if (mounted) {
      setState(() => _isLaunching = false);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Couldn't open navigation. Check your installed map apps.",
            ),
            backgroundColor: VantageColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLaunching ? null : _onNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: VantageColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: VantageColors.accentDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        icon: _isLaunching
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.navigation_rounded, size: 20),
        label: Text(_isLaunching ? 'Opening...' : 'Go'),
      ),
    );
  }
}
