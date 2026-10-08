import 'package:easy_ui/easy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Size, Widget;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/dashboard/dashboard_pages.dart';

import '../support/helpers.dart';

Widget _page(Widget child) => sgaHome(Tela(child: child));

void main() {
  void mobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('financeiro se adapta a uma tela móvel sem overflow', (
    tester,
  ) async {
    mobileViewport(tester);
    await tester.pumpWidget(
      _page(
        FinanceiroPage(
          repository: FakeCommissionRepository(latencia: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Receita do mês'), findsOneWidget);
    expect(find.text('Últimas movimentações'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('relatório se adapta a uma tela móvel sem overflow', (
    tester,
  ) async {
    mobileViewport(tester);
    await tester.pumpWidget(
      _page(
        RelatoriosPage(
          repository: FakeCommissionRepository(latencia: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pedidos por tipo de arte'), findsOneWidget);
    expect(find.text('Pedidos por status'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('produtos no mobile separa cadastro e catálogo', (tester) async {
    mobileViewport(tester);
    await tester.pumpWidget(_page(const ProdutosPage()));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Produto'), findsOneWidget);
    expect(find.text('Meus produtos'), findsOneWidget);
    expect(find.text('Tipo do produto'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Adicionar Produto'));
    await tester.pumpAndSettle();

    expect(find.text('Tipo do produto'), findsOneWidget);
    expect(find.text('Imagem do produto'), findsOneWidget);
    expect(find.text('Prazo (dias)'), findsNothing);
    expect(find.text('Preço (R\$)'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Voltar para produtos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus produtos'));
    await tester.pumpAndSettle();

    expect(find.text('Modelo 3D Vroid completo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
