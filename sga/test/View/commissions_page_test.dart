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

Widget _pagina(CommissionRepository repo) {
  return sgaHome(Tela(child: CommissionsPage(repository: repo)));
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

  testWidgets('o card mostra o cliente e só o começo da descrição', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(FakeCommissionRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    final descricao = tester.widget<Text>(
      find.textContaining('Ilustração full body da personagem original'),
    );
    expect(descricao.maxLines, 3);
    expect(descricao.overflow, TextOverflow.ellipsis);
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
