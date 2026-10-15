import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Uma fatia da rosca: quanto vale (0 a 1) e a cor.
class DonutSlice {
  const DonutSlice(this.fraction, this.color);

  final double fraction;
  final Color color;
}

/// Gráfico de rosca desenhado com arcos grossos, sem dependência externa.
class DonutPainter extends CustomPainter {
  const DonutPainter(this.slices);

  final List<DonutSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 55);
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = slice.fraction * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 23,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter old) => old.slices != slices;
}
