import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

/// Avatar, nome do cliente e "tipo · coluna", como no topo do detalhe.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.commission,
    required this.statusNome,
  });

  final CommissionResumoModel commission;
  final String statusNome;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Avatar(name: commission.nomeCliente, size: AvatarSize.md),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label(type: LabelType.title, text: commission.nomeCliente),
              Label(
                type: LabelType.caption,
                text: '${commission.tipoProdutoNome ?? 'Sem tipo'} · $statusNome',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
