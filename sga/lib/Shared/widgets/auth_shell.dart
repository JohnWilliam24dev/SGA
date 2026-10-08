import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Moldura das telas de entrada: gradiente azul, bolhas suaves e um painel
/// translúcido central. O conteúdo continua responsivo e rolável em telas
/// baixas.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  static const double _maxWidth = 440;
  static const double _margin = 24;

  @override
  Widget build(BuildContext context) {
    return Tela(
      padding: 0.px,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF159AFF), Color(0xFF37B7FF), Color(0xFFB9E5FF)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _Backdrop()),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < _maxWidth
                    ? constraints.maxWidth
                    : _maxWidth;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: width,
                        child: Padding(
                          padding: const EdgeInsets.all(_margin),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BackdropPainter(
          primary: const Color(0xFFFFFFFF),
          secondary: const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.shortestSide;
    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.30),
      base * 0.28,
      Paint()..color = primary.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.68),
      base * 0.32,
      Paint()..color = secondary.withValues(alpha: 0.26),
    );
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 1.02),
      base * 0.42,
      Paint()..color = primary.withValues(alpha: 0.20),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.secondary != secondary;
  }
}
