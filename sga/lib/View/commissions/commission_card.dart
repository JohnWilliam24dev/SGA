import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

/// Pack só dos cards do quadro: padding enxuto para caber nome e um pedaço
/// da descrição na altura padrão, qualquer que seja o pack da tela.
final StylePack _cardPack = StylePack.define(
  name: 'sga_commission_card',
  card: const CardStyleSpec(
    radius: 12,
    elevation: ElevationLevel.subtle,
    paddingSteps: 1.5,
  ),
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
      pack: _cardPack,
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
