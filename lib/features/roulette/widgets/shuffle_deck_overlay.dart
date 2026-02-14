import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vantage419/core/models/toledo_spot.dart';
import 'package:vantage419/core/utils/extensions.dart';

/// Tinder-style shuffle overlay with swipe-out physics,
/// stacking depth, and a pulsing winner glow on reveal.
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
  final VoidCallback onComplete;
  final VoidCallback onRespin;
  final VoidCallback onLetsGo;

  @override
  State<ShuffleDeckOverlay> createState() => _ShuffleDeckOverlayState();
}

class _ShuffleDeckOverlayState extends State<ShuffleDeckOverlay>
    with TickerProviderStateMixin {
  late List<ToledoSpot> _displayStack;
  int _currentIndex = 0;
  bool _showWinner = false;

  // Per-card swipe animation
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;

  // Winner entrance
  late AnimationController _winnerController;
  late Animation<double> _winnerScale;
  late Animation<double> _winnerOpacity;

  // Winner glow pulse
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    final limitedCandidates = widget.candidates.take(5).toList();
    _displayStack = [...limitedCandidates, widget.winner];

    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _winnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _winnerScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _winnerController, curve: Curves.elasticOut),
    );
    _winnerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _winnerController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _setupSwipeDirection();
    _startShuffle();
  }

  /// Randomize swipe direction (left or right) for each card
  void _setupSwipeDirection() {
    final goLeft = math.Random().nextBool();
    final dx = goLeft ? -1.5 : 1.5;
    final rotation = goLeft ? -0.15 : 0.15;

    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(dx, -0.2))
        .animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.easeInBack),
        );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: rotation,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeIn));
  }

  Future<void> _startShuffle() async {
    // Brief pause before starting
    await Future.delayed(const Duration(milliseconds: 300));

    for (var i = 0; i < _displayStack.length - 1; i++) {
      if (!mounted) return;

      // Randomize swipe direction each card
      _setupSwipeDirection();

      unawaited(HapticFeedback.selectionClick());

      // Animate the current card swiping away
      _swipeController.reset();
      await _swipeController.forward();

      if (!mounted) return;
      setState(() {
        _currentIndex = i + 1;
      });

      // Short pause between cards
      await Future.delayed(const Duration(milliseconds: 80));
    }

    // Reveal winner with scale-up + glow
    if (mounted) {
      unawaited(HapticFeedback.heavyImpact());
      setState(() => _showWinner = true);
      unawaited(_winnerController.forward());
      unawaited(_glowController.repeat(reverse: true));
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _winnerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: _showWinner
            ? _buildWinnerReveal(widget.winner)
            : _buildShuffleStack(),
      ),
    );
  }

  Widget _buildShuffleStack() {
    if (_currentIndex >= _displayStack.length) return const SizedBox.shrink();

    return SizedBox(
      width: 300,
      height: 420,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background cards (stacking depth effect)
          for (
            var i = math.min(_currentIndex + 2, _displayStack.length - 1);
            i > _currentIndex;
            i--
          )
            _buildStackedCard(i),

          // Top card – animated swipe
          AnimatedBuilder(
            animation: _swipeController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _swipeAnimation.value.dx * 300,
                  _swipeAnimation.value.dy * 100,
                ),
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Opacity(
                    opacity: (1.0 - _swipeController.value).clamp(0.3, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: _Card(spot: _displayStack[_currentIndex], isWinner: false),
          ),
        ],
      ),
    );
  }

  /// Cards sitting behind the top card with scale + offset
  Widget _buildStackedCard(int index) {
    final depth = index - _currentIndex;
    final scale = 1.0 - (depth * 0.05);
    final yOffset = depth * 8.0;

    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: (1.0 - depth * 0.2).clamp(0.4, 1.0),
          child: _Card(spot: _displayStack[index], isWinner: false),
        ),
      ),
    );
  }

  Widget _buildWinnerReveal(ToledoSpot spot) {
    return AnimatedBuilder(
      animation: Listenable.merge([_winnerController, _glowController]),
      builder: (context, child) {
        return Opacity(
          opacity: _winnerOpacity.value,
          child: Transform.scale(
            scale: _winnerScale.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Winner card with glow
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.accent.withValues(
                          alpha: 0.3 + (_glowController.value * 0.3),
                        ),
                        blurRadius: 20 + (_glowController.value * 20),
                        spreadRadius: _glowController.value * 8,
                      ),
                    ],
                  ),
                  child: _Card(spot: spot, isWinner: true),
                ),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: context.textTheme.labelLarge,
          ),
          child: const Text("LET'S GO"),
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
                ? CachedNetworkImage(
                    imageUrl: spot.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        ColoredBox(color: context.colors.surfaceLight),
                    errorWidget: (context, url, error) => ColoredBox(
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
