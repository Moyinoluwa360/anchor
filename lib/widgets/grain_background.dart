import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Faint dot grid behind every screen. Painted once and cached.
class GrainBackground extends StatelessWidget {
  const GrainBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return RepaintBoundary(
      child: CustomPaint(painter: _DotGridPainter(c.grain, c.bg), size: Size.infinite),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  _DotGridPainter(this.dot, this.bg);
  final Color dot;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final p = Paint()..color = dot;
    const step = 22.0;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.9, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.dot != dot || old.bg != bg;
}
