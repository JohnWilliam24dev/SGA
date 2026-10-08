import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart' hide Icon;

import 'kanban_models.dart';

/// Uma coluna do quadro: cabeçalho (título e contagem) e a lista rolável de
/// cards arrastáveis. Quem decide *para onde* o card vai é o `KanbanBoard`;
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
    required this.onDragStarted,
    required this.onDragUpdate,
    required this.onDragEnd,
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
  final ValueChanged<String> onDragStarted;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
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
    final cell = Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: SizedBox(height: cardHeight, child: itemBuilder(context, item)),
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
