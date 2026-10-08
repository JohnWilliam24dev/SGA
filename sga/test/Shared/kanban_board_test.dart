import 'package:easy_ui/easy_ui.dart' show Tela;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Shared/shared.dart';

import '../support/helpers.dart';

const _colunas = [
  KanbanColumnData<String>(id: 'a', title: 'Coluna A', items: ['a1', 'a2', 'a3']),
  KanbanColumnData<String>(id: 'b', title: 'Coluna B', items: ['b1']),
  KanbanColumnData<String>(id: 'c', title: 'Coluna C', items: []),
];

Widget _board({
  List<KanbanColumnData<String>> colunas = _colunas,
  ValueChanged<KanbanMove>? onMove,
}) {
  return sgaHome(
    Tela(
      child: KanbanBoard<String>(
        columns: colunas,
        itemId: (s) => s,
        itemBuilder: (context, s) => Center(child: Text(s)),
        onMove: onMove ?? (_) {},
      ),
    ),
  );
}

void _viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Segura o card (toque longo) e o leva até [destino], passo a passo.
Future<void> _arrastar(WidgetTester tester, Offset origem, Offset destino) async {
  final gesto = await tester.startGesture(origem);
  await tester.pump(const Duration(milliseconds: 400));
  await gesto.moveTo(origem + const Offset(12, 12));
  await tester.pump();
  await gesto.moveTo(destino);
  await tester.pump(const Duration(milliseconds: 50));
  await gesto.up();
  await tester.pumpAndSettle();
}

void main() {
  group('desktop', () {
    testWidgets('mostra todas as colunas lado a lado, com os cards', (tester) async {
      _viewport(tester, const Size(1200, 800));
      await tester.pumpWidget(_board());
      await tester.pumpAndSettle();

      for (final titulo in ['Coluna A', 'Coluna B', 'Coluna C']) {
        expect(find.text(titulo), findsOneWidget);
      }
      for (final item in ['a1', 'a2', 'a3', 'b1']) {
        expect(find.text(item), findsOneWidget);
      }
      expect(find.byType(PageView), findsNothing);
      expect(find.text('Nenhum item aqui'), findsOneWidget); // coluna C vazia
    });

    testWidgets('arrastar um card para outra coluna avisa o movimento', (tester) async {
      _viewport(tester, const Size(1200, 800));
      KanbanMove? movimento;
      await tester.pumpWidget(_board(onMove: (m) => movimento = m));
      await tester.pumpAndSettle();

      await _arrastar(
        tester,
        tester.getCenter(find.text('a1')),
        tester.getCenter(find.text('b1')),
      );

      expect(
        movimento,
        const KanbanMove(itemId: 'a1', fromColumnId: 'a', toColumnId: 'b', toIndex: 0),
      );
    });

    testWidgets('soltar numa coluna vazia coloca o card nela', (tester) async {
      _viewport(tester, const Size(1200, 800));
      KanbanMove? movimento;
      await tester.pumpWidget(_board(onMove: (m) => movimento = m));
      await tester.pumpAndSettle();

      final colunaC = tester.getCenter(find.byKey(const ValueKey('kanban-column-c')));
      await _arrastar(tester, tester.getCenter(find.text('b1')), colunaC);

      expect(movimento?.toColumnId, 'c');
      expect(movimento?.toIndex, 0);
    });

    testWidgets('reordenar dentro da mesma coluna', (tester) async {
      _viewport(tester, const Size(1200, 800));
      KanbanMove? movimento;
      await tester.pumpWidget(_board(onMove: (m) => movimento = m));
      await tester.pumpAndSettle();

      await _arrastar(
        tester,
        tester.getCenter(find.text('a1')),
        tester.getCenter(find.text('a3')),
      );

      expect(
        movimento,
        const KanbanMove(itemId: 'a1', fromColumnId: 'a', toColumnId: 'a', toIndex: 2),
      );
    });

    testWidgets('soltar no mesmo lugar não avisa movimento', (tester) async {
      _viewport(tester, const Size(1200, 800));
      var chamadas = 0;
      await tester.pumpWidget(_board(onMove: (_) => chamadas++));
      await tester.pumpAndSettle();

      final origem = tester.getCenter(find.text('a2'));
      await _arrastar(tester, origem, origem + const Offset(0, 4));

      expect(chamadas, 0);
    });
  });

  group('celular', () {
    testWidgets('uma coluna por vez, em páginas', (tester) async {
      _viewport(tester, const Size(400, 800));
      await tester.pumpWidget(_board());
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Coluna A'), findsOneWidget);
      expect(find.text('a1'), findsOneWidget);
    });

    testWidgets('deslizar leva à coluna seguinte e encaixa', (tester) async {
      _viewport(tester, const Size(400, 800));
      await tester.pumpWidget(_board());
      await tester.pumpAndSettle();

      await tester.fling(find.byType(PageView), const Offset(-200, 0), 1200);
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      final pagina = pageView.controller.page!;
      expect(pagina, closeTo(pagina.roundToDouble(), 0.001)); // nunca no meio
      expect(pagina.round(), 1);
    });
  });

  group('segurar para mover (mouse e toque)', () {
    testWidgets('com o mouse também é preciso segurar o card', (tester) async {
      _viewport(tester, const Size(1200, 800));
      KanbanMove? movimento;
      await tester.pumpWidget(_board(onMove: (m) => movimento = m));
      await tester.pumpAndSettle();

      final origem = tester.getCenter(find.text('a1'));
      final destino = tester.getCenter(find.text('b1'));
      final gesto = await tester.startGesture(origem, kind: PointerDeviceKind.mouse);
      await tester.pump(const Duration(milliseconds: 400)); // segurou
      await gesto.moveTo(origem + const Offset(12, 12));
      await tester.pump();
      await gesto.moveTo(destino);
      await tester.pump(const Duration(milliseconds: 50));
      await gesto.up();
      await tester.pumpAndSettle();

      expect(
        movimento,
        const KanbanMove(itemId: 'a1', fromColumnId: 'a', toColumnId: 'b', toIndex: 0),
      );
    });

    testWidgets('mover logo de cara, sem segurar, não pega o card', (tester) async {
      _viewport(tester, const Size(1200, 800));
      var chamadas = 0;
      await tester.pumpWidget(_board(onMove: (_) => chamadas++));
      await tester.pumpAndSettle();

      for (final tipo in [PointerDeviceKind.mouse, PointerDeviceKind.touch]) {
        final origem = tester.getCenter(find.text('a1'));
        final destino = tester.getCenter(find.text('b1'));
        final gesto = await tester.startGesture(origem, kind: tipo);
        await gesto.moveTo(destino); // sem esperar o "segurar"
        await tester.pump(const Duration(milliseconds: 50));
        await gesto.up();
        await tester.pumpAndSettle();
      }

      expect(chamadas, 0);
    });

    testWidgets('um clique simples não move nem esconde o card', (tester) async {
      _viewport(tester, const Size(1200, 800));
      var chamadas = 0;
      await tester.pumpWidget(_board(onMove: (_) => chamadas++));
      await tester.pumpAndSettle();

      await tester.tap(find.text('a1'));
      await tester.pumpAndSettle();

      expect(chamadas, 0);
      expect(find.text('a1'), findsOneWidget);
    });

    testWidgets('arrastar o fundo com o mouse rola o quadro na horizontal',
        (tester) async {
      // Largura de tablet/desktop (colunas lado a lado), mas estreita o
      // bastante para as colunas não caberem.
      _viewport(tester, const Size(700, 800));
      await tester.pumpWidget(_board());
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsNothing);

      final topo = tester.getTopLeft(find.byType(KanbanBoard<String>));
      final gesto = await tester.startGesture(
        topo + const Offset(6, 300),
        kind: PointerDeviceKind.mouse,
      );
      await gesto.moveBy(const Offset(-100, 0));
      await tester.pump();
      await gesto.moveBy(const Offset(-100, 0));
      await tester.pump();
      await gesto.up();
      await tester.pumpAndSettle();

      final rolagem = tester.widget<SingleChildScrollView>(
        find.byWidgetPredicate(
          (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
        ),
      );
      expect(rolagem.controller!.offset, greaterThan(50));
    });
  });

  group('largura de celular', () {
    testWidgets('janela estreita usa páginas mesmo com mouse (sem depender da plataforma)',
        (tester) async {
      _viewport(tester, const Size(400, 800));
      await tester.pumpWidget(_board());
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('deslizar com o mouse na coluna também troca de página e encaixa',
        (tester) async {
      _viewport(tester, const Size(400, 800));
      await tester.pumpWidget(_board());
      await tester.pumpAndSettle();

      final gesto = await tester.startGesture(
        tester.getCenter(find.text('a1')),
        kind: PointerDeviceKind.mouse,
      );
      await gesto.moveBy(const Offset(-60, 0));
      await tester.pump();
      await gesto.moveBy(const Offset(-60, 0));
      await tester.pump();
      await gesto.up();
      await tester.pumpAndSettle();

      final pagina = tester.widget<PageView>(find.byType(PageView)).controller.page!;
      expect(pagina, closeTo(pagina.roundToDouble(), 0.001));
      expect(pagina.round(), 1);
    });
  });
}
