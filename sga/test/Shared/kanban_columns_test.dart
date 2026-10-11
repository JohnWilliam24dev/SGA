import 'package:easy_ui/easy_ui.dart' show Tela;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Shared/shared.dart';

import '../support/helpers.dart';

const _colunas = [
  KanbanColumnData<String>(
    id: 'a',
    title: 'Coluna A',
    items: ['a1', 'a2', 'a3'],
  ),
  KanbanColumnData<String>(id: 'b', title: 'Coluna B', items: ['b1']),
  KanbanColumnData<String>(id: 'c', title: 'Coluna C', items: []),
];

Widget _board({
  ValueChanged<KanbanColumnMove>? onColumnMove,
  bool comMenu = true,
}) {
  return sgaHome(
    Tela(
      child: KanbanBoard<String>(
        columns: _colunas,
        itemId: (s) => s,
        itemBuilder: (context, s) => Center(child: Text(s)),
        onMove: (_) {},
        onColumnMove: onColumnMove,
        columnActionsBuilder: comMenu
            ? (context, coluna, indice) =>
                  Icon(Icons.more_vert, key: ValueKey('menu-${coluna.id}'))
            : null,
      ),
    ),
  );
}

void _viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets(
    'cabeçalho: contador e menu à esquerda, título centralizado, ícone de arrastar à direita',
    (tester) async {
      _viewport(tester);
      await tester.pumpWidget(_board(onColumnMove: (_) {}));
      await tester.pumpAndSettle();

      final coluna = find.byKey(const ValueKey('kanban-column-a'));
      final contador = tester.getCenter(
        find.descendant(of: coluna, matching: find.text('3')),
      );
      final menu = tester.getCenter(find.byKey(const ValueKey('menu-a')));
      final titulo = tester.getCenter(find.text('Coluna A'));
      final icone = tester.getCenter(
        find.byKey(const ValueKey('kanban-column-handle-a')),
      );

      expect(contador.dx, lessThan(menu.dx));
      expect(menu.dx, lessThan(titulo.dx));
      expect(titulo.dx, lessThan(icone.dx));
      expect((titulo.dx - tester.getCenter(coluna).dx).abs(), lessThan(2));
    },
  );

  testWidgets('sem onColumnMove e sem menu, o cabeçalho não mostra nenhum dos dois', (
    tester,
  ) async {
    _viewport(tester);
    await tester.pumpWidget(_board(comMenu: false));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('kanban-column-handle-a')), findsNothing);
    expect(find.byKey(const ValueKey('menu-a')), findsNothing);
    expect(find.text('Coluna A'), findsOneWidget);
  });

  testWidgets('arrastar o ícone até o fim avisa a nova posição da coluna', (
    tester,
  ) async {
    _viewport(tester);
    final movimentos = <KanbanColumnMove>[];
    await tester.pumpWidget(_board(onColumnMove: movimentos.add));
    await tester.pumpAndSettle();

    final icone = tester.getCenter(
      find.byKey(const ValueKey('kanban-column-handle-a')),
    );
    final destino = tester.getCenter(
      find.byKey(const ValueKey('kanban-column-c')),
    );
    final gesto = await tester.startGesture(icone);
    await gesto.moveTo(icone + const Offset(40, 0));
    await tester.pump();
    await gesto.moveTo(Offset(destino.dx, icone.dy));
    await tester.pump(const Duration(milliseconds: 50));

    // Enquanto arrasta, um espaço reservado marca onde a coluna cairia.
    expect(
      find.byKey(const ValueKey('kanban-column-placeholder')),
      findsOneWidget,
    );

    await gesto.up();
    await tester.pumpAndSettle();

    expect(movimentos, [
      const KanbanColumnMove(columnId: 'a', fromIndex: 0, toIndex: 2),
    ]);
    expect(
      find.byKey(const ValueKey('kanban-column-placeholder')),
      findsNothing,
    );
  });

  testWidgets('soltar a coluna onde estava não avisa nada', (tester) async {
    _viewport(tester);
    final movimentos = <KanbanColumnMove>[];
    await tester.pumpWidget(_board(onColumnMove: movimentos.add));
    await tester.pumpAndSettle();

    final icone = tester.getCenter(
      find.byKey(const ValueKey('kanban-column-handle-a')),
    );
    final gesto = await tester.startGesture(icone);
    await gesto.moveTo(icone + const Offset(40, 0));
    await tester.pump();
    await gesto.moveTo(icone);
    await tester.pump(const Duration(milliseconds: 50));
    await gesto.up();
    await tester.pumpAndSettle();

    expect(movimentos, isEmpty);
  });

  testWidgets('no celular não há ícone de arrastar (a ordem muda pelo menu)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_board(onColumnMove: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('kanban-column-handle-a')), findsNothing);
    expect(find.byKey(const ValueKey('menu-a')), findsOneWidget);
  });
}
