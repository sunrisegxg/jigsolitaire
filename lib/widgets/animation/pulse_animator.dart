import 'package:flutter/material.dart';

// --- WIDGET LÀM HIỆU ỨNG NHỊP TIM (CO GIÃN) ---
class PulseAnimator extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const PulseAnimator({super.key, required this.child, required this.trigger});

  @override
  State<PulseAnimator> createState() => _PulseAnimatorState();
}

class _PulseAnimatorState extends State<PulseAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.10),
        weight: 1,
      ), // Nở to 10%
      TweenSequenceItem(
        tween: Tween(begin: 1.10, end: 1.0),
        weight: 1,
      ), // Thu lại
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(PulseAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}
