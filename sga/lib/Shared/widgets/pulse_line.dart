import 'dart:ui' show PathMetric;

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Linha de batimento (ECG) que se desenha sozinha e termina numa onda suave:
/// o "pulso" do sistema que vira traço de artista.
///
/// Anima uma única vez, ao entrar na tela.
class PulseLine extends StatelessWidget {
  const PulseLine({
    super.key,
    this.width = 220,
    this.height = 40,
    this.duration = const Duration(milliseconds: 1800),
  });

  final double width;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final color = AppThemeScope.tokensOf(context).primaryColor;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, progress, _) {
        return CustomPaint(
          size: Size(width, height),
          painter: _PulsePainter(progress: progress, color: color),
        );
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  Path _path(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, h * 0.5)
      ..lineTo(w * 0.22, h * 0.5)
      ..lineTo(w * 0.27, h * 0.36)
      ..lineTo(w * 0.32, h * 0.5)
      ..lineTo(w * 0.37, h * 0.5)
      ..lineTo(w * 0.41, h * 0.64)
      ..lineTo(w * 0.46, h * 0.04)
      ..lineTo(w * 0.51, h * 0.96)
      ..lineTo(w * 0.55, h * 0.5)
      ..lineTo(w * 0.60, h * 0.5)
      ..cubicTo(w * 0.67, h * 0.5, w * 0.69, h * 0.18, w * 0.77, h * 0.18)
      ..cubicTo(w * 0.86, h * 0.18, w * 0.87, h * 0.82, w * 0.95, h * 0.82)
      ..lineTo(w, h * 0.82);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final metrics = _path(size).computeMetrics().toList();
    final total = metrics.fold<double>(
      0,
      (sum, PathMetric m) => sum + m.length,
    );
    var remaining = total * progress;

    Offset? tip;
    for (final metric in metrics) {
      final take = remaining < metric.length ? remaining : metric.length;
      canvas.drawPath(metric.extractPath(0, take), stroke);
      tip = metric.getTangentForOffset(take)?.position;
      remaining -= take;
      if (remaining <= 0) break;
    }

    // Ponto brilhante na ponta enquanto a linha ainda está se desenhando.
    if (tip != null && progress < 1) {
      canvas.drawCircle(tip, 7, Paint()..color = color.withValues(alpha: 0.25));
      canvas.drawCircle(tip, 3.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
