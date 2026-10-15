import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/shared.dart' hide NavDestination;
import 'column_header.dart';
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
    // No celular o painel já tem margem do shell: sem folga lateral dentro dele.
    final compact = MediaQuery.sizeOf(context).width < glassCompactWidth;
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
              padding: compact
                  ? const EdgeInsets.symmetric(vertical: 10)
                  : const EdgeInsets.all(12),
              child: StylePackScope(
                pack: sgaBoardPackFor(dark: SgaColors.of(context).dark),
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
                  columnHeaderBuilder: (context, column, indice, handle) =>
                      ColumnHeader(
                        title: column.title,
                        count: column.items.length,
                        menu: menuDaColuna(
                          colunas[indice],
                          indice,
                          colunas.length,
                        ),
                        handle: handle,
                      ),
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
