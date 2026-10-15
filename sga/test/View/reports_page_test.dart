import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Size, Widget;
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
          repository: FakeCommissionRepository(latencia: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pedidos no mês'), findsOneWidget);
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
          repository: FakeCommissionRepository(latencia: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.textContaining('%'), findsWidgets);
    expect(find.text('Fila'), findsOneWidget);
    expect(find.text('Escolher período'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
