import 'package:flutter/material.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/utils/extensions.dart';

/// S4.5.4: Overlay that displays a "Tinder-style" shuffle animation.
/// Shows a stack of [candidates] flying off-screen, revealing the [winner].
class ShuffleDeckOverlay extends StatefulWidget {
  const ShuffleDeckOverlay({
    super.key,
    required this.candidates,
    required this.winner,
    required this.onComplete,
    required this.onRespin,
    required this.onLetsGo,
  });

  final List<ToledoSpot> candidates;
  final ToledoSpot winner;
  final VoidCallback onComplete; // Called when animation finishes
  final VoidCallback onRespin;
  final VoidCallback onLetsGo;

  @override
  State<ShuffleDeckOverlay> createState() => _ShuffleDeckOverlayState();
}

class _ShuffleDeckOverlayState extends State<ShuffleDeckOverlay>
    with SingleTickerProviderStateMixin {
  late List<ToledoSpot> _displayStack;
  int _currentIndex = 0;
  bool _showWinner = false;

  @override
  void initState() {
    super.initState();
    // Create a display stack: Candidates + Winner at the end
    // Limit candidates to 5 max for brevity
    final limitedCandidates = widget.candidates.take(5).toList();
    // Ensure winner is not in limitedCandidates to avoid duplicates if possible, or just append
    _displayStack = [...limitedCandidates, widget.winner];

    _startShuffle();
  }

  Future<void> _startShuffle() async {
    // Animate through the stack
    for (var i = 0; i < _displayStack.length - 1; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _currentIndex = i + 1;
      });
    }

    // Reveal winner
    if (mounted) {
      setState(() {
        _showWinner = true;
      });
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5), // Dim background
      child: Center(
        child: _showWinner
            ? _buildWinnerCard(widget.winner)
            : _buildShuffleStack(),
      ),
    );
  }

  Widget _buildShuffleStack() {
    if (_currentIndex >= _displayStack.length) return const SizedBox.shrink();

    // Show top card
    final spot = _displayStack[_currentIndex];
    return _Card(spot: spot, isWinner: false);
  }

  Widget _buildWinnerCard(ToledoSpot spot) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(scale: 1.1, child: _Card(spot: spot, isWinner: true)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: widget.onRespin,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: context.textTheme.labelLarge,
              ),
              child: const Text('RESPIN'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: widget.onLetsGo,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.accentDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: context.textTheme.labelLarge,
              ),
              child: const Text("LET'S GO"),
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.spot, required this.isWinner});

  final ToledoSpot spot;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: spot.imageUrl != null
                ? Image.network(
                    spot.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: context.colors.surfaceLight,
                      child: Icon(
                        Icons.image_not_supported,
                        color: context.colors.textMuted,
                      ),
                    ),
                  )
                : ColoredBox(
                    color: context.colors.surfaceLight,
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: context.colors.textMuted,
                    ),
                  ),
          ),

          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: spot.tags
                        .take(3)
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.colors.textMuted.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              tag.toUpperCase(),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Spacer(),
                  if (isWinner)
                    Text(
                      spot.vibeCheck,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
