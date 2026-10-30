import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/new_order_sheet.dart';
import 'package:sga/View/settings/orcamento_section.dart';
import 'package:sga/View/settings/settings_page.dart';

import '../support/helpers.dart';

void main() {
  testWidgets('Configurações liga e desliga o catálogo e grava na hora', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeConfigMakerRepository(latencia: Duration.zero);

    await tester.pumpWidget(sgaHome(Tela(child: SettingsPage(config: repo))));
    await tester.pumpAndSettle();
    expect(find.text('Orçamento dos pedidos'), findsOneWidget);
    expect(find.textContaining('tipo de produto, adicionais'), findsOneWidget);

    // A página tem outros interruptores: aqui interessa o da seção de orçamento.
    await tester.tap(
      find.descendant(
        of: find.byType(OrcamentoSection),
        matching: find.byWidgetPredicate((w) => w is Toggle),
      ).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('orça cada pedido à mão'), findsOneWidget);
    expect((await repo.carregar()).usaCatalogo, isFalse);
  });

  testWidgets('sem repositório de config a seção não aparece', (tester) async {
    await tester.pumpWidget(sgaHome(const Tela(child: SettingsPage())));
    await tester.pumpAndSettle();
    expect(find.text('Orçamento dos pedidos'), findsNothing);
  });

  testWidgets('novo pedido no modo manual não pede tipo nem adicionais', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(sgaHome(const Scaffold(body: NewOrderSheet(opcoes: [], manual: true))));
    await tester.pumpAndSettle();
    expect(find.text('Nome do cliente'), findsOneWidget);
    expect(find.text('Tipo do produto'), findsNothing);
    expect(find.text('Adicionais'), findsNothing);

    await tester.pumpWidget(sgaHome(const Scaffold(body: NewOrderSheet(opcoes: []))));
    await tester.pumpAndSettle();
    expect(find.text('Tipo do produto'), findsOneWidget);
  });
}
