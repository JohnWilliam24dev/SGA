import 'package:flutter/foundation.dart' show immutable;

/// Dados de uma coluna do [KanbanBoard]: identificador estável, título e os
/// itens na ordem em que aparecem.
@immutable
class KanbanColumnData<T> {
  const KanbanColumnData({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<T> items;
}

/// Pedido de movimentação feito pelo usuário ao soltar um item.
///
/// [toIndex] conta a partir da lista de destino **já sem** o item movido
/// (vale também ao reordenar dentro da mesma coluna).
@immutable
class KanbanMove {
  const KanbanMove({
    required this.itemId,
    required this.fromColumnId,
    required this.toColumnId,
    required this.toIndex,
  });

  final String itemId;
  final String fromColumnId;
  final String toColumnId;
  final int toIndex;

  @override
  bool operator ==(Object other) {
    return other is KanbanMove &&
        other.itemId == itemId &&
        other.fromColumnId == fromColumnId &&
        other.toColumnId == toColumnId &&
        other.toIndex == toIndex;
  }

  @override
  int get hashCode => Object.hash(itemId, fromColumnId, toColumnId, toIndex);

  @override
  String toString() =>
      'KanbanMove($itemId: $fromColumnId -> $toColumnId @ $toIndex)';
}

/// Pedido de movimentação de uma **coluna**, feito ao soltar o ícone de
/// arrastar dela.
///
/// [toIndex] conta a partir da lista de colunas **já sem** a coluna movida
/// (mesma convenção de [KanbanMove]): 0 é o início e `colunas.length - 1`, o
/// fim.
@immutable
class KanbanColumnMove {
  const KanbanColumnMove({
    required this.columnId,
    required this.fromIndex,
    required this.toIndex,
  });

  final String columnId;
  final int fromIndex;
  final int toIndex;

  @override
  bool operator ==(Object other) {
    return other is KanbanColumnMove &&
        other.columnId == columnId &&
        other.fromIndex == fromIndex &&
        other.toIndex == toIndex;
  }

  @override
  int get hashCode => Object.hash(columnId, fromIndex, toIndex);

  @override
  String toString() => 'KanbanColumnMove($columnId: $fromIndex -> $toIndex)';
}
