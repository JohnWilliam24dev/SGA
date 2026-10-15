import 'package:flutter/material.dart' show Icon, IconButton, Icons;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';

/// Uma seção aberta a partir do menu: título com seta de voltar e o conteúdo.
class ProductsMobileSection extends StatelessWidget {
  const ProductsMobileSection({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Voltar para produtos',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: SgaColors.of(context).text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
