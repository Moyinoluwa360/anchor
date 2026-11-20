import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Frosted "liquid glass" surface: real backdrop blur, a translucent tint, a
/// hairline border with a faint top highlight, and a soft shadow.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 32,
    this.blur = 18,
    this.padding = EdgeInsets.zero,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final double blur;
  final EdgeInsets padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: c.isDark ? 0.40 : 0.07),
                  blurRadius: 22,
                  spreadRadius: -4,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              color: c.glassTint,
              border: Border.all(color: c.glassBorder, width: 0.8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: c.isDark ? 0.10 : 0.35),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.45],
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
