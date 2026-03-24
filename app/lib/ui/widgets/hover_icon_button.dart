import 'package:flutter/material.dart';

/// 支持Hover效果的IconButton
class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final double hoverScale;
  final Color? hoverColor;

  const HoverIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = Colors.white,
    this.size = 24,
    this.hoverScale = 1.1,
    this.hoverColor,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverScaleController;
  late Animation<double> _hoverScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _hoverScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _hoverScaleAnimation = Tween<double>(begin: 1.0, end: widget.hoverScale).animate(
      CurvedAnimation(
        parent: _hoverScaleController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverScaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverScaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverScaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.hoverColor ?? widget.color.withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(widget.icon),
            color: widget.color,
            iconSize: widget.size,
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }
}
