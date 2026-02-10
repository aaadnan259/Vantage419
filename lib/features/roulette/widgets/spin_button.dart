import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/constants.dart';

/// 80dp circular button with Toyota Blue gradient and rotation animation.
class SpinButton extends StatefulWidget {
  const SpinButton({super.key, required this.onSpin, this.isSpinning = false});

  final VoidCallback onSpin;
  final bool isSpinning;

  @override
  State<SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<SpinButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

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
  }

  @override
  void didUpdateWidget(covariant SpinButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      _controller.forward(from: 0);
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
    return SizedBox(
      width: AppConstants.spinButtonSize,
      height: AppConstants.spinButtonSize,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) {
          return Transform.rotate(angle: _rotation.value, child: child);
        },
        child: Material(
          shape: const CircleBorder(),
          elevation: 8,
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  VantageColors.accentLight,
                  VantageColors.accent,
                  VantageColors.accentDark,
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
    );
  }
}
