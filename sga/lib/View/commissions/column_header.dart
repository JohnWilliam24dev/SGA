import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Cabeçalho de coluna do quadro: contagem num selo claro e os três pontinhos
/// à esquerda, título centralizado e a alça de arrastar a coluna à direita.
class ColumnHeader extends StatelessWidget {
  const ColumnHeader({
    super.key,
    required this.title,
    required this.count,
    required this.menu,
    this.handle,
  });

  final String title;
  final int count;
  final Widget menu;

  /// Alça de arrastar a coluna; `null` no celular, onde não há reordenação.
  final Widget? handle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 2),
      child: Row(
        children: [
          _CountChip(count),
          const SizedBox(width: 4),
          menu,
          Expanded(
            child: Label(
              type: LabelType.heading,
              text: title,
              textAlign: TextAlign.center,
            ),
          ),
          // Mantém o título centralizado quando não há alça.
          handle ?? const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final primary = AppThemeScope.tokensOf(context).primaryColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(const Color(0x99FFFFFF), primary),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        // O selo é claro nos dois temas, então o número leva um azul-marinho
        // fixo: a cor de apoio do tema (clara no escuro) sumiria nele.
        child: Text(
          '$count',
          style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF09243A),
          ),
        ),
      ),
    );
  }
}
