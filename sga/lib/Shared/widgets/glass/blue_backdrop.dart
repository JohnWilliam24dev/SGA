import 'package:flutter/material.dart';

class BlueBackdrop extends StatelessWidget {
  const BlueBackdrop({super.key});
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BlueBackdropPainter(
      dark: Theme.of(context).brightness == Brightness.dark,
    ),
  );
}

class _BlueBackdropPainter extends CustomPainter {
  const _BlueBackdropPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (dark ? const Color(0xFF168DEE) : Colors.white).withValues(
        alpha: .20,
      );
    canvas.drawCircle(Offset(-20, size.height * .96), size.width * .23, paint);
    canvas.drawCircle(
      Offset(size.width * .89, size.height * .44),
      size.width * .18,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * .56, -40),
      size.width * .17,
      Paint()..color = Colors.white.withValues(alpha: .08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
