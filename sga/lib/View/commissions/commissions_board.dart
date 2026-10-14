import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart' hide NavDestination;
import 'commission_card.dart';
import 'kanban_style.dart';

/// Quadro de commissions: botão "Nova coluna" e o kanban dentro do painel
/// glass. Só desenha; quem decide o que fazer com cada gesto é a tela.
class CommissionsBoard extends StatelessWidget {
  const CommissionsBoard({
    super.key,
    required this.colunas,
    required this.onNovaColuna,
    required this.onMove,
    required this.onItemTap,
    required this.onColumnMove,
    required this.menuDaColuna,
  });

  final List<CommissionColumn> colunas;
  final VoidCallback onNovaColuna;
  final ValueChanged<KanbanMove<CommissionResumoModel>> onMove;
  final ValueChanged<CommissionResumoModel> onItemTap;
  final ValueChanged<KanbanColumnMove> onColumnMove;
  final Widget Function(CommissionColumn coluna, int indice, int total)
  menuDaColuna;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Button(
                text: 'Nova coluna',
                icon: Icons.add_rounded,
                onPressed: onNovaColuna,
              ),
            ),
          ),
          Expanded(
            child: GlassPanel(
              padding: const EdgeInsets.all(12),
              child: StylePackScope(
                pack: sgaBoardPack,
                child: KanbanBoard<CommissionResumoModel>(
                  cardHeight: 104,
                  columns: [
                    for (final coluna in colunas)
                      KanbanColumnData<CommissionResumoModel>(
                        id: coluna.id,
                        title: coluna.titulo,
                        items: coluna.commissions,
                      ),
                  ],
                  itemId: (commission) => commission.id,
                  itemBuilder: (context, commission) =>
                      CommissionCard(commission: commission),
                  onMove: onMove,
                  onItemTap: onItemTap,
                  onColumnMove: onColumnMove,
                  columnActionsBuilder: (context, column, indice) =>
                      menuDaColuna(colunas[indice], indice, colunas.length),
                  emptyLabel: 'Nenhum pedido aqui',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
