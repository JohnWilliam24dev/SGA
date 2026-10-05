import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Moldura das telas de entrada (boas-vindas, login e cadastro): fundo claro
/// com círculos suaves nas cores da marca, conteúdo centralizado numa coluna
/// de largura máxima confortável e rolagem quando a tela é baixa.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});

  final Widget child;

  static const double _maxWidth = 440;
  static const double _margin = 24;

  @override
  Widget build(BuildContext context) {
    return Tela(
      padding: 0.px,
      child: Stack(
        children: [
          const Positioned.fill(child: _Backdrop()),
          LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.maxWidth < _maxWidth ? constraints.maxWidth : _maxWidth;
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return IgnorePointer(
      child: CustomPaint(
        painter: _BackdropPainter(
          primary: tokens.primaryColor,
          secondary: tokens.secondaryColor,
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
      Offset(size.width * 0.95, size.height * 0.02),
      base * 0.55,
      Paint()..color = primary.withValues(alpha: 0.07),
    );
    canvas.drawCircle(
      Offset(size.width * 0.02, size.height * 0.98),
      base * 0.6,
      Paint()..color = secondary.withValues(alpha: 0.06),
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.9),
      base * 0.18,
      Paint()..color = primary.withValues(alpha: 0.05),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) {
    return oldDelegate.primary != primary || oldDelegate.secondary != secondary;
  }
}
