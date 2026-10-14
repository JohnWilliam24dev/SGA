import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../Core/theme/sga_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.panel.withValues(alpha: .90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.panelBorder.withValues(alpha: .70),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x240058A8),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
