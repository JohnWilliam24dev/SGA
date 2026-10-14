import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'kanban_style.dart';

/// Valor que o card destaca: o orçamento final, quando já foi fechado, ou o
/// valor simulado (marcado como tal).
String valorDoCard(CommissionResumoModel commission) {
  final fechado = commission.orcamentoFinal;
  if (fechado != null) return formatarMoeda(fechado);
  return '${formatarMoeda(commission.precoSimulado)} (simulado)';
}

/// Card de uma [CommissionResumoModel]: cliente em destaque, o tipo de
/// produto e o valor. O tamanho é dado por quem o coloca (o quadro usa uma
/// altura padrão); os detalhes completos abrem ao tocar no card.
class CommissionCard extends StatelessWidget {
  const CommissionCard({super.key, required this.commission});

  final CommissionResumoModel commission;

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
                Avatar(name: commission.nomeCliente, size: AvatarSize.sm),
                LayoutItem(
                  size: 1.fr,
                  child: Label(
                    type: LabelType.subtitle,
                    text: commission.nomeCliente,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Label(
              type: LabelType.caption,
              text: commission.tipoProdutoNome,
              maxLines: 1,
            ),
            Label(
              type: LabelType.caption,
              text: valorDoCard(commission),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
