import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vantage419/core/core.dart';
import 'package:vantage419/features/favorites/favorites_provider.dart';

/// Draggable bottom sheet showing selected spot details.
class SpotBottomSheet extends ConsumerWidget {
  const SpotBottomSheet({
    super.key,
    required this.spot,
    required this.onClose,
    this.userLocation,
  });

  final ToledoSpot spot;
  final VoidCallback onClose;
  final LatLng? userLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: AppConstants.sheetCollapsed,
      minChildSize: AppConstants.sheetMin,
      maxChildSize: AppConstants.sheetExpanded,
      snap: true,
      snapSizes: const [
        AppConstants.sheetCollapsed,
        AppConstants.sheetExpanded,
      ],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
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
              // Shared pulsing drag handle to hint that the sheet is draggable (S2.1)
              const Center(child: DragHandle(isPulsing: true)),

              // Header row
              _SpotHeader(spot: spot, userLocation: userLocation),

              const SizedBox(height: 16),

              // Vibe check
              _SpotVibeCheck(spot: spot),

              const SizedBox(height: 16),

              // Description — S2.6: capped at 5 lines
              _SpotDescription(spot: spot),

              if (spot.address != null) ...[
                const SizedBox(height: 12),
                _SpotAddress(address: spot.address!),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SpotHeader extends ConsumerWidget {
  const _SpotHeader({required this.spot, required this.userLocation});

  final ToledoSpot spot;
  final LatLng? userLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(spot.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // S2.6: Ellipsis at 2 lines for long spot names
                Text(
                  spot.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                _CategoryBadge(category: spot.category),
                if (userLocation != null) ...[
                  const SizedBox(height: 4),
                  _DistanceBadge(spot: spot, userLocation: userLocation!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Favorite toggle
          _CircleIconButton(
            icon: isFav
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isFav ? context.colors.accent : context.colors.textMuted,
            onTap: () => ref.read(favoritesProvider.notifier).toggle(spot.id),
          ),
          const SizedBox(width: 8),
          // S6.2: Share button
          _ShareButton(spot: spot),
          const SizedBox(width: 8),
          _NavigateButton(spot: spot),
        ],
      ),
    );
  }
}

class _SpotVibeCheck extends StatelessWidget {
  const _SpotVibeCheck({required this.spot});

  final ToledoSpot spot;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: spot.category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: spot.category.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: spot.category.color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              spot.vibeCheck,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleMedium?.copyWith(
                color: spot.category.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotDescription extends StatelessWidget {
  const _SpotDescription({required this.spot});

  final ToledoSpot spot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        spot.description,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyLarge?.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _SpotAddress extends StatelessWidget {
  const _SpotAddress({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: context.colors.textMuted,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final SpotCategory category;

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

class _DistanceBadge extends StatelessWidget {
  const _DistanceBadge({required this.spot, required this.userLocation});

  final ToledoSpot spot;
  final LatLng userLocation;

  @override
  Widget build(BuildContext context) {
    final spotLatLng = LatLng(spot.latitude, spot.longitude);
    final miles = distanceMiles(userLocation, spotLatLng);
    final display = formatDistance(miles);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.directions_walk_rounded,
          size: 14,
          color: context.colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          display,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

    final success = await NavigationService.instance.navigateTo(
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
            backgroundColor: context.colors.surface,
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
          backgroundColor: context.colors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: context.colors.accentDark,
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

/// S6.2: Share button — sends spot details via native share sheet.
class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.spot});

  final ToledoSpot spot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filled(
        onPressed: () {
          final mapsUrl =
              'https://www.google.com/maps/search/?api=1&query=${spot.latitude},${spot.longitude}';
          final text =
              '${spot.name}\n'
              '${spot.vibeCheck.isNotEmpty ? '"${spot.vibeCheck}"\n' : ''}'
              '$mapsUrl';
          Share.share(text);
        },
        style: IconButton.styleFrom(
          backgroundColor: context.colors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          Icons.share_rounded,
          size: 20,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

/// Circular icon button used for the favorite toggle.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filled(
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: context.colors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
