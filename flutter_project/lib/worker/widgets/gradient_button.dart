import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final List<Color> gradientColors;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.gradientColors,
    this.borderRadius,
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }
}
