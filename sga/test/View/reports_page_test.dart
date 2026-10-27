import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show CustomPaint, Size, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/reports/reports_page.dart';

import '../support/helpers.dart';

Widget _page(Widget child) => sgaHome(Tela(child: child));

void main() {
  testWidgets('relatórios se adapta a uma tela móvel sem overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _page(
        ReportsPage(
          repository: FakeRelatorioRepository(
            FakeCommissionRepository(latencia: Duration.zero),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pedidos no período'), findsOneWidget);
    expect(find.text('Receita'), findsOneWidget);
    expect(find.text('Ticket médio'), findsOneWidget);
    expect(find.text('Taxa de conclusão'), findsOneWidget);
    expect(find.text('Pedidos por tipo de arte'), findsOneWidget);
    expect(find.text('Pedidos por status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no desktop mostra rosca com legenda e barras por coluna', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _page(
        ReportsPage(
          repository: FakeRelatorioRepository(
            FakeCommissionRepository(latencia: Duration.zero),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.textContaining('%'), findsWidgets);
    expect(find.text('Fila'), findsOneWidget);
    expect(find.text('Este mês'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar no período troca o filtro e busca de novo', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Espiao(
      FakeRelatorioRepository(FakeCommissionRepository(latencia: Duration.zero)),
    );

    await tester.pumpWidget(_page(ReportsPage(repository: repo)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Este mês'));
    await tester.pumpAndSettle();

    expect(find.text('Mês passado'), findsOneWidget);
    expect(repo.pedidos.length, 2);
    expect(repo.pedidos.first, (de: null, ate: null));
    expect(repo.pedidos.last.de, isNotNull);
    expect(repo.pedidos.last.ate!.isAfter(repo.pedidos.last.de!), isTrue);
  });
}

class _Espiao implements RelatorioRepository {
  _Espiao(this._base);

  final RelatorioRepository _base;
  final pedidos = <({DateTime? de, DateTime? ate})>[];

  @override
  Future<RelatorioResumoModel> carregarResumo({DateTime? de, DateTime? ate}) {
    pedidos.add((de: de, ate: ate));
    return _base.carregarResumo(de: de, ate: ate);
  }
}
