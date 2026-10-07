import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

/// Pack do quadro de commissions: card com padding enxuto e uma tipografia
/// um pouco menor que a do resto do app (nome e título de coluna em ~15px,
/// descrição em ~13px), para caber nome e um pedaço da descrição na altura
/// padrão do card.
///
/// O card o aplica a si mesmo (assim o card "na mão" durante o arrasto, que
/// é desenhado fora da página, fica igual) e a página o aplica ao quadro
/// (para os títulos das colunas).
final StylePack sgaKanbanPack = StylePack.define(
  name: 'sga_kanban',
  card: const CardStyleSpec(
    radius: 12,
    elevation: ElevationLevel.subtle,
    paddingSteps: 1.5,
  ),
  label: const LabelStyleSpec(subtitleScale: 1.05, captionScale: 0.93),
);

/// Card de uma [Commission]: cliente em destaque e o começo da descrição
/// (o resto fica cortado com reticências). O tamanho é dado por quem o
/// coloca (o quadro usa uma altura padrão).
class CommissionCard extends StatelessWidget {
  const CommissionCard({super.key, required this.commission});

  final Commission commission;

  @override
  Widget build(BuildContext context) {
    return StylePackScope(
      pack: sgaKanbanPack,
      child: Card(
        child: Div(
          width: 100.pct,
          gap: 4.px,
          children: [
            Div(
              direction: LayoutDirection.horizontal,
              align: Alignment.centerLeft,
              gap: 8.px,
              children: [
                Avatar(name: commission.cliente, size: AvatarSize.sm),
                LayoutItem(
                  size: 1.fr,
                  child: Label(
                    type: LabelType.subtitle,
                    text: commission.cliente,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            LayoutItem(
              size: 1.fr,
              child: Label(
                type: LabelType.caption,
                text: commission.descricao,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
