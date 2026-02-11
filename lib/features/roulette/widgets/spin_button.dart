import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/extensions.dart';
import '../providers/roulette_state_provider.dart';

/// 80dp circular button with Toyota Blue gradient and rotation animation.
/// S2.5: Varied haptics — medium on tap, heavy on success, light on error.
class SpinButton extends ConsumerStatefulWidget {
  const SpinButton({
    super.key,
    required this.onSpin,
    this.isSpinning = false,
    this.hasResult = false,
    this.hasError = false,
  });

  final VoidCallback onSpin;
  final bool isSpinning;
  final bool hasResult;
  final bool hasError;

  @override
  ConsumerState<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends ConsumerState<SpinButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.spinDuration,
    );
    _rotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // S6.4: Check if user has spun before
    final prefs = ref.read(sharedPreferencesProvider);
    if (!(prefs.getBool('hasSpunOnce') ?? false)) {
      setState(() => _showTooltip = true);
    }
  }

  @override
  void didUpdateWidget(covariant SpinButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _controller.forward(from: 0);
      // S6.4: Dismiss tooltip after first spin
      if (_showTooltip) {
        setState(() => _showTooltip = false);
        ref.read(sharedPreferencesProvider).setBool('hasSpunOnce', true);
      }
    }
    // Haptic on spin completion (S2.5)
    if (!widget.isSpinning && oldWidget.isSpinning) {
      if (widget.hasResult) {
        HapticFeedback.heavyImpact();
      } else if (widget.hasError) {
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isSpinning) return;
    HapticFeedback.mediumImpact();
    widget.onSpin();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // S6.4: First-launch tooltip
        if (_showTooltip)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.colors.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Tap to discover!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        SizedBox(
          width: AppConstants.spinButtonSize,
          height: AppConstants.spinButtonSize,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (context, child) {
              return Transform.rotate(angle: _rotation.value, child: child);
            },
            // S5.4: RepaintBoundary — icon+gradient rasterize once, rotation composited
            child: RepaintBoundary(
              child: Material(
                shape: const CircleBorder(),
                elevation: 8,
                child: Ink(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colors.accentLight,
                        context.colors.accent,
                        context.colors.accentDark,
                      ],
                    ),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _handleTap,
                    child: const Center(
                      child: Icon(
                        Icons.explore_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
