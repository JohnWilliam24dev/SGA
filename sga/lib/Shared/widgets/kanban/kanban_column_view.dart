import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show Icons, Material, MaterialType;
import 'package:flutter/services.dart' show SystemMouseCursors;
import 'package:flutter/widgets.dart' hide Icon;
import 'package:flutter/widgets.dart' as widgets show Icon;

import 'kanban_models.dart';

/// Uma coluna do quadro: cabeçalho e a lista rolável de cards arrastáveis.
///
/// O cabeçalho tem, da esquerda para a direita: a contagem de itens e o botão
/// de ações da coluna ([actions], opcional); o título, centralizado; e o ícone
/// de arrastar a coluna ([showDragHandle]).
///
/// Quem decide *para onde* o card vai é o `KanbanBoard`;
/// a coluna só desenha o estado que recebe (inclusive o espaço reservado
/// onde o card será solto) e repassa os eventos de arrasto.
class KanbanColumnView<T> extends StatelessWidget {
  const KanbanColumnView({
    super.key,
    required this.column,
    required this.columnKey,
    required this.listKey,
    required this.scrollController,
    required this.cardWidth,
    required this.cardHeight,
    required this.gap,
    required this.listPadding,
    required this.draggingId,
    required this.hoverIndex,
    required this.emptyLabel,
    required this.itemId,
    required this.itemBuilder,
    this.onItemTap,
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.actions,
    this.showDragHandle = false,
    this.columnWidth = 300,
    this.onColumnDragStarted,
    this.onColumnDragUpdate,
    this.onColumnDragEnd,
  });

  final KanbanColumnData<T> column;

  /// Chaves usadas pelo board para medir a coluna inteira e a área da lista.
  final GlobalKey columnKey;
  final GlobalKey listKey;

  final ScrollController scrollController;
  final double cardWidth;
  final double cardHeight;
  final double gap;
  final double listPadding;

  /// Item sendo arrastado agora (de qualquer coluna), ou `null`.
  final String? draggingId;

  /// Posição do espaço reservado nesta coluna (contando sem o item
  /// arrastado), ou `null` se o arrasto não está sobre ela.
  final int? hoverIndex;

  /// Quanto é preciso segurar o card antes de ele poder ser arrastado.
  /// Evita que um clique/toque simples (ou um deslize para rolar) pegue o card.
  static const Duration holdToDrag = Duration(milliseconds: 200);

  final String emptyLabel;
  final String Function(T item) itemId;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<T>? onItemTap;
  final ValueChanged<String> onDragStarted;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  /// Botão de ações da coluna (ex.: o menu de três pontinhos), à esquerda
  /// do título, logo depois da contagem.
  final Widget? actions;

  /// Mostra, à direita, o ícone que arrasta a coluna inteira.
  final bool showDragHandle;

  /// Largura da coluna, usada para o "fantasma" que acompanha o ponteiro.
  final double columnWidth;
  final VoidCallback? onColumnDragStarted;
  final ValueChanged<Offset>? onColumnDragUpdate;
  final VoidCallback? onColumnDragEnd;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    final background = Color.alphaBlend(
      tokens.primaryColor.withValues(alpha: 0.07),
      tokens.backgroundColor,
    );
    final children = _buildChildren(context, tokens);

    return DecoratedBox(
      key: columnKey,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.borderColor),
      ),
      child: KeyedSubtree(
        key: ValueKey<String>('kanban-column-${column.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(tokens),
            Expanded(
              child: SingleChildScrollView(
                key: listKey,
                controller: scrollController,
                padding: EdgeInsets.all(listPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Label(
                              type: LabelType.caption,
                              text: emptyLabel,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]
                      : children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Largura reservada a cada lado do título, para ele ficar no centro mesmo
  /// com a contagem e o menu de um lado e o ícone de arrastar do outro.
  static const double _headerSide = 76;

  Widget _header(ThemeTokens tokens) {
    final menu = actions;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
      child: Row(
        children: [
          SizedBox(
            width: _headerSide,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Badge(text: '${column.items.length}'),
                  if (menu != null) ...[const SizedBox(width: 2), menu],
                ],
              ),
            ),
          ),
          Expanded(
            child: Label(
              type: LabelType.subtitle,
              text: column.title,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: _headerSide,
            child: Align(
              alignment: Alignment.centerRight,
              child: showDragHandle ? _handle(tokens) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle(ThemeTokens tokens) {
    final icon = widgets.Icon(
      Icons.drag_indicator_rounded,
      size: 22,
      color: tokens.mutedTextColor,
    );
    return Draggable<String>(
      key: ValueKey<String>('kanban-column-handle-${column.id}'),
      data: column.id,
      // O fantasma da coluna fica centrado no ponteiro, não ao lado do ícone.
      dragAnchorStrategy: (draggable, context, position) =>
          Offset(columnWidth / 2, 22),
      feedback: _ghost(tokens),
      childWhenDragging: Opacity(opacity: 0.3, child: icon),
      onDragStarted: onColumnDragStarted,
      onDragUpdate: (details) => onColumnDragUpdate?.call(details.globalPosition),
      onDragEnd: (_) => onColumnDragEnd?.call(),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Padding(padding: const EdgeInsets.all(6), child: icon),
      ),
    );
  }

  Widget _ghost(ThemeTokens tokens) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: columnWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tokens.primaryColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Label(
                    type: LabelType.subtitle,
                    text: column.title,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Badge(text: '${column.items.length}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context, ThemeTokens tokens) {
    final children = <Widget>[];
    final placeholder = _placeholder(tokens);
    // Posição entre os itens "de verdade": o item arrastado não conta, pois
    // sai da lista enquanto está na mão do usuário.
    var visibleIndex = 0;

    for (final item in column.items) {
      final id = itemId(item);
      if (id != draggingId) {
        if (hoverIndex == visibleIndex) children.add(placeholder);
        visibleIndex++;
      }
      // O item arrastado continua na árvore (sem ocupar espaço): se o
      // widget que iniciou o arrasto fosse desmontado, o fim do arrasto
      // nunca seria avisado.
      children.add(_draggable(context, item, id));
    }
    if (hoverIndex != null && hoverIndex == visibleIndex) {
      children.add(placeholder);
    }
    return children;
  }

  Widget _placeholder(ThemeTokens tokens) {
    return Padding(
      key: const ValueKey<String>('kanban-placeholder'),
      padding: EdgeInsets.only(bottom: gap),
      child: SizedBox(
        height: cardHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tokens.primaryColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _draggable(BuildContext context, T item, String id) {
    // O toque simples fica no próprio card; o LongPressDraggable só vence a
    // disputa de gestos depois de segurar por [holdToDrag], e a rolagem vence
    // ao deslizar. Por isso clicar, segurar e deslizar não se confundem.
    final onTap = onItemTap;
    final card = SizedBox(height: cardHeight, child: itemBuilder(context, item));
    final cell = Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: onTap == null
          ? card
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(item),
              child: card,
            ),
    );
    final feedback = Material(
      type: MaterialType.transparency,
      child: Transform.rotate(
        angle: 0.035,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: itemBuilder(context, item),
        ),
      ),
    );

    return LongPressDraggable<String>(
      key: ValueKey<String>(id),
      data: id,
      delay: holdToDrag,
      feedback: feedback,
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () => onDragStarted(id),
      onDragUpdate: (details) => onDragUpdate(details.globalPosition),
      onDragEnd: (_) => onDragEnd(),
      child: cell,
    );
  }
}
