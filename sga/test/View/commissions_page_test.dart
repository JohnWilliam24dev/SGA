import 'package:easy_ui/easy_ui.dart' show Tela;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commissions_page.dart';

import '../support/helpers.dart';

class _RepositorioQueFalha extends FakeCommissionRepository {
  _RepositorioQueFalha() : super(latencia: Duration.zero);

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) {
    throw Exception('sem conexão');
  }
}

Widget _pagina(
  CommissionRepository repo, {
  void Function(CommissionResumoModel, String)? onOpen,
}) {
  return sgaHome(
    Tela(
      child: CommissionsPage(
        repository: repo,
        onOpenCommission: onOpen ?? (_, __) {},
      ),
    ),
  );
}

Finder _naColuna(String colunaId, String texto) {
  return find.descendant(
    of: find.byKey(ValueKey('kanban-column-$colunaId')),
    matching: find.text(texto),
  );
}

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
  void viewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('mostra o carregamento e depois as colunas com os pedidos', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(FakeCommissionRepository(latencia: Duration.zero)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    for (final coluna in ['Orçamento', 'Em produção', 'Em revisão', 'Entregue']) {
      expect(find.text(coluna), findsOneWidget);
    }
    expect(_naColuna('orcamento', 'Marina Costa'), findsOneWidget);
  });

  testWidgets('o card mostra cliente, tipo de produto e valor', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(FakeCommissionRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    // c1: ainda sem orçamento final, mostra o simulado.
    expect(_naColuna('orcamento', 'Ilustração'), findsWidgets);
    expect(_naColuna('orcamento', 'R\$ 280,00 (simulado)'), findsOneWidget);
    // c4: orçamento final fechado, mostra só ele.
    expect(_naColuna('producao', 'R\$ 560,00'), findsOneWidget);
  });

  testWidgets('tocar no card abre o detalhe com a coluna dele', (tester) async {
    viewport(tester);
    CommissionResumoModel? aberta;
    String? status;
    await tester.pumpWidget(
      _pagina(
        FakeCommissionRepository(latencia: Duration.zero),
        onOpen: (commission, statusNome) {
          aberta = commission;
          status = statusNome;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beatriz Lima'));
    await tester.pumpAndSettle();

    expect(aberta?.id, 'c4');
    expect(status, 'Em produção');
  });

  testWidgets('apertar e segurar move o card e não abre o detalhe', (tester) async {
    viewport(tester);
    var aberturas = 0;
    await tester.pumpWidget(
      _pagina(
        FakeCommissionRepository(latencia: Duration.zero),
        onOpen: (_, __) => aberturas++,
      ),
    );
    await tester.pumpAndSettle();

    await _arrastar(
      tester,
      tester.getCenter(find.text('Marina Costa')),
      tester.getCenter(find.text('Beatriz Lima')),
    );

    expect(_naColuna('producao', 'Marina Costa'), findsOneWidget);
    expect(aberturas, 0);
  });

  testWidgets('segurar sem soltar na hora e largar no mesmo lugar não abre o detalhe',
      (tester) async {
    viewport(tester);
    var aberturas = 0;
    await tester.pumpWidget(
      _pagina(
        FakeCommissionRepository(latencia: Duration.zero),
        onOpen: (_, __) => aberturas++,
      ),
    );
    await tester.pumpAndSettle();

    final gesto = await tester.startGesture(tester.getCenter(find.text('Marina Costa')));
    await tester.pump(const Duration(milliseconds: 400));
    await gesto.up();
    await tester.pumpAndSettle();

    expect(aberturas, 0);
  });

  testWidgets('arrastar um pedido para outra coluna o move', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(FakeCommissionRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    await _arrastar(
      tester,
      tester.getCenter(find.text('Marina Costa')),
      tester.getCenter(find.text('Beatriz Lima')),
    );

    expect(_naColuna('producao', 'Marina Costa'), findsOneWidget);
    expect(_naColuna('orcamento', 'Marina Costa'), findsNothing);
  });

  testWidgets('se o repositório falhar, o pedido volta e um aviso aparece', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(_RepositorioQueFalha()));
    await tester.pumpAndSettle();

    await _arrastar(
      tester,
      tester.getCenter(find.text('Marina Costa')),
      tester.getCenter(find.text('Beatriz Lima')),
    );

    expect(_naColuna('orcamento', 'Marina Costa'), findsOneWidget);
    expect(find.text('Não foi possível mover a commission.'), findsOneWidget);
  });
}
