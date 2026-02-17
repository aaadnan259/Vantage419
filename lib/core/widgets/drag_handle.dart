import 'package:flutter/material.dart';
import 'package:vantage419/core/utils/extensions.dart';

/// A standard drag handle for bottom sheets.
///
/// Can be [isPulsing] to hint at draggability (S2.1).
class DragHandle extends StatefulWidget {
  const DragHandle({super.key, this.isPulsing = false});

  final bool isPulsing;

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle>
    with SingleTickerProviderStateMixin {
  late final AnimationController? _controller;
  late final Animation<double>? _opacity;

  @override
  void initState() {
    super.initState();
    if (widget.isPulsing) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..repeat(reverse: true);
      _opacity = Tween<double>(
        begin: 0.3,
        end: 0.7,
      ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));
    } else {
      _controller = null;
      _opacity = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _opacity;
    if (widget.isPulsing && opacity != null) {
      return AnimatedBuilder(
        animation: opacity,
        builder: (context, _) => _buildHandle(context, opacity.value),
      );
    }

    return _buildHandle(context, 0.4);
  }

  Widget _buildHandle(BuildContext context, double alpha) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colors.textMuted.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
