import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' hide Icon;

/// Marca do SGA: paleta de artista num quadrado azul, com a cruz de "cuidado"
/// no canto (arte + saúde do negócio).
class SgaLogo extends StatelessWidget {
  const SgaLogo({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final lighter = Color.alphaBlend(const Color(0x40FFFFFF), tokens.primaryColor);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.3),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lighter, tokens.primaryColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.primaryColor.withValues(alpha: 0.35),
                  blurRadius: size * 0.4,
                  offset: Offset(0, size * 0.15),
                ),
              ],
            ),
            child: SizedBox.expand(
              child: Center(
                child: Icon(
                  Icons.palette_rounded,
                  size: size * 0.5,
                  color: (t) => t.onPrimaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            right: -size * 0.08,
            bottom: -size * 0.08,
            child: SizedBox(
              width: size * 0.38,
              height: size * 0.38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.secondaryColor,
                  border: Border.all(color: tokens.backgroundColor, width: 3),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: size * 0.26,
                    color: (t) => t.onPrimaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
