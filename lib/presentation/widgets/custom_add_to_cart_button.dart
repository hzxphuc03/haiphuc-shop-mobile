import 'package:flutter/material.dart';

class CustomAddToCartButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isPrimary;

  const CustomAddToCartButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isPrimary = true,
  });

  @override
  State<CustomAddToCartButton> createState() => _CustomAddToCartButtonState();
}

class _CustomAddToCartButtonState extends State<CustomAddToCartButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.onPressed == null) return;
    
    // Play micro-interaction
    await _controller.forward();
    await _controller.reverse();
    
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.onPressed == null 
        ? Colors.grey[800]! 
        : (widget.isPrimary ? const Color(0xFFD2FF1F) : Colors.white10);
    
    final Color foregroundColor = widget.isPrimary ? Colors.black : Colors.white;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: RotationTransition(
          turns: _rotationAnimation,
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: widget.onPressed == null ? null : _handleTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 20, color: foregroundColor),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
