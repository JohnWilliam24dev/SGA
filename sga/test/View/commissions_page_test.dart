import 'package:easy_ui/easy_ui.dart' show Tela, Loader;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commissions_page.dart';

import '../support/helpers.dart';

Widget _pagina(
  FakeCommissionRepository repo, {
  void Function(CommissionResumoModel, String)? onOpen,
}) {
  return sgaHome(
    Tela(
      child: CommissionsPage(
        repository: repo,
        statusRepository: repo.statusRepository,
        onOpenCommission: onOpen ?? (_, _) {},
      ),
    ),
  );
}

void main() {
  void viewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('mostra o carregamento e depois as colunas com os pedidos', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      _pagina(FakeCommissionRepository(latencia: Duration.zero)),
    );
    expect(find.byType(Loader), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(Loader), findsNothing);
    for (final coluna in [
      'Fila',
      'Em andamento',
      'Concluído',
      'Cancelado',
    ]) {
      expect(find.text(coluna), findsOneWidget);
    }
    expect(find.text('Marina Costa'), findsOneWidget);
  });
}
