import 'dart:math' as math;

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

  testWidgets('cada coluna tem pontinhos, alça de arrastar e selo de contagem', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      _pagina(FakeCommissionRepository(latencia: Duration.zero)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.more_vert), findsNWidgets(4));
    expect(find.byIcon(Icons.drag_indicator), findsNWidgets(4));
    expect(find.text('0'), findsOneWidget); // coluna Cancelado, vazia
  });

  testWidgets('o card arrastado fica inclinado, como no Trello', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      _pagina(FakeCommissionRepository(latencia: Duration.zero)),
    );
    await tester.pumpAndSettle();

    // Só o ângulo exato (dragTilt do pack) identifica o card inclinado: o
    // Flutter usa Transforms rotacionados em outros lugares.
    bool inclinado(Widget w) {
      if (w is! Transform) return false;
      final m = w.transform.storage;
      return (math.atan2(m[1], m[0]) - 0.035).abs() < 1e-6;
    }

    expect(find.byWidgetPredicate(inclinado), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Marina Costa')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump();
    expect(find.byWidgetPredicate(inclinado), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byWidgetPredicate(inclinado), findsNothing);
  });
}
