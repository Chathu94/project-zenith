import 'package:flutter/material.dart';

class PressableButton extends StatefulWidget {
  const PressableButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = PressableButtonVariant.filled,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final PressableButtonVariant variant;

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool _pressed = false;

  void _updatePressed(bool value) {
    if (widget.onPressed == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.variant == PressableButtonVariant.outlined
        ? OutlinedButton(onPressed: widget.onPressed, child: widget.child)
        : FilledButton(onPressed: widget.onPressed, child: widget.child);

    return GestureDetector(
      onTapDown: (_) => _updatePressed(true),
      onTapUp: (_) => _updatePressed(false),
      onTapCancel: () => _updatePressed(false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        scale: _pressed ? 0.97 : 1,
        child: button,
      ),
    );
  }
}

enum PressableButtonVariant { filled, outlined }
