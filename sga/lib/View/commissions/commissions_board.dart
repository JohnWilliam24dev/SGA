import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'column_header.dart';
import 'commission_card.dart';
import 'kanban_style.dart';

/// Quadro de commissions: o kanban dentro do painel glass (o botão "+" que
/// cria coluna e pedido fica por cima, na tela). Só desenha; quem decide o
/// que fazer com cada gesto é a tela.
class CommissionsBoard extends StatelessWidget {
  const CommissionsBoard({
    super.key,
    required this.colunas,
    required this.onMove,
    required this.onItemTap,
    required this.onColumnMove,
    required this.menuDaColuna,
    this.onLoadMore,
    this.carregandoMais = const {},
  });

  final List<CommissionColumn> colunas;
  final ValueChanged<KanbanMove<CommissionResumoModel>> onMove;
  final ValueChanged<CommissionResumoModel> onItemTap;
  final ValueChanged<KanbanColumnMove> onColumnMove;
  final Widget Function(CommissionColumn coluna, int indice, int total)
  menuDaColuna;

  /// Pede a próxima página de uma coluna; [carregandoMais] são as colunas
  /// que estão buscando uma agora.
  final ValueChanged<CommissionColumn>? onLoadMore;
  final Set<String> carregandoMais;

  @override
  Widget build(BuildContext context) {
    // No celular o painel já tem margem do shell: sem folga lateral dentro dele.
    final compact = MediaQuery.sizeOf(context).width < glassCompactWidth;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                        count: colunas[indice].quantidade,
                        restantes: colunas[indice].restantes,
                        carregandoMais: carregandoMais.contains(column.id),
                        onLoadMore: onLoadMore == null
                            ? null
                            : () => onLoadMore!(colunas[indice]),
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
