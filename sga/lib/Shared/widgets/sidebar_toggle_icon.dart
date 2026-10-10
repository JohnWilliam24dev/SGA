import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Ícone de "painel lateral": um quadrado de cantos suaves com a barra à
/// esquerda e algumas linhas dentro dela. Com [showArrow], ganha uma seta para
/// a direita (o gesto de "mostrar a barra").
class SidebarToggleIcon extends StatelessWidget {
  const SidebarToggleIcon({
    super.key,
    this.size = 22,
    this.color,
    this.showArrow = false,
  });

  final double size;

  /// Se omitida, usa a cor de texto secundária do tema.
  final Color? color;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return CustomPaint(
      size: Size.square(size),
      painter: _PanelPainter(
        color: color ?? tokens.mutedTextColor,
        showArrow: showArrow,
      ),
    );
  }
}

class _PanelPainter extends CustomPainter {
  _PanelPainter({required this.color, required this.showArrow});

  final Color color;
  final bool showArrow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = stroke / 2 + s * 0.04;
    canvas.drawRRect(
      RRect.fromLTRBR(inset, inset, s - inset, s - inset, Radius.circular(s * 0.24)),
      paint,
    );

    // A barra lateral e as linhas dentro dela.
    canvas.drawLine(Offset(s * 0.40, inset), Offset(s * 0.40, s - inset), paint);
    for (final y in const [0.34, 0.50, 0.66]) {
      canvas.drawLine(Offset(s * 0.17, s * y), Offset(s * 0.29, s * y), paint);
    }

    if (showArrow) {
      final y = s * 0.5;
      final start = s * 0.54;
      final tip = s * 0.80;
      canvas.drawLine(Offset(start, y), Offset(tip, y), paint);
      canvas.drawLine(Offset(tip - s * 0.10, y - s * 0.11), Offset(tip, y), paint);
      canvas.drawLine(Offset(tip - s * 0.10, y + s * 0.11), Offset(tip, y), paint);
    }
  }

  @override
  bool shouldRepaint(_PanelPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.showArrow != showArrow;
  }
}
