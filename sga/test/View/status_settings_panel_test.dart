import 'package:easy_ui/easy_ui.dart' show Tela;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/settings/status_settings_panel.dart';

import '../support/helpers.dart';

Widget _painel(StatusRepository repo) {
  return sgaHome(
    Tela(
      child: SingleChildScrollView(child: StatusSettingsPanel(repository: repo)),
    ),
  );
}

void _viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

String _nome(WidgetTester tester, String id) {
  return tester.widget<Text>(find.byKey(ValueKey('status-nome-$id'))).data!;
}

Future<void> _abrirMenu(WidgetTester tester, String id, String acao) async {
  await tester.tap(find.byKey(ValueKey('status-menu-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(acao));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lista as colunas padrão com o tipo de cada uma', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_painel(FakeStatusRepository(latencia: Duration.zero)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(_nome(tester, 'fila'), 'Fila');
    expect(_nome(tester, 'em-andamento'), 'Em andamento');
    expect(_nome(tester, 'concluido'), 'Concluído');
    expect(_nome(tester, 'cancelado'), 'Cancelado');
    expect(find.text('Inicial'), findsOneWidget);
  });

  testWidgets('Nova coluna cria uma coluna Em andamento no fim', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_painel(FakeStatusRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('status-nova')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('status-nome-campo')), 'Revisão');
    await tester.tap(find.widgetWithText(FilledButton, 'Criar'));
    await tester.pumpAndSettle();

    expect(find.text('Revisão'), findsOneWidget);
    expect(_nome(tester, 'status-1'), 'Revisão');
  });

  testWidgets('Renomear troca o nome da coluna', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_painel(FakeStatusRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    await _abrirMenu(tester, 'fila', 'Renomear');
    await tester.enterText(find.byKey(const ValueKey('status-nome-campo')), 'Entrada');
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(_nome(tester, 'fila'), 'Entrada');
  });

  testWidgets('Mover para baixo troca a ordem das colunas', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_painel(FakeStatusRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    await _abrirMenu(tester, 'fila', 'Mover para baixo');

    final fila = tester.getTopLeft(find.byKey(const ValueKey('status-linha-fila')));
    final andamento = tester.getTopLeft(
      find.byKey(const ValueKey('status-linha-em-andamento')),
    );
    expect(fila.dy, greaterThan(andamento.dy));
  });

  testWidgets('Alterar tipo muda o tipo da coluna', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_painel(FakeStatusRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    await _abrirMenu(tester, 'em-andamento', 'Alterar tipo');
    await tester.tap(find.byKey(const ValueKey('tipo-concluido')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('status-linha-em-andamento')),
        matching: find.text('Concluído'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('excluir o último Cancelado mostra o motivo e mantém a coluna', (
    tester,
  ) async {
    _viewport(tester);
    await tester.pumpWidget(_painel(FakeStatusRepository(latencia: Duration.zero)));
    await tester.pumpAndSettle();

    await _abrirMenu(tester, 'cancelado', 'Excluir');
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('última coluna do tipo Cancelado'), findsOneWidget);
    expect(find.byKey(const ValueKey('status-linha-cancelado')), findsOneWidget);
  });

  testWidgets('excluir coluna com cartões mostra quantos e mantém a coluna', (
    tester,
  ) async {
    _viewport(tester);
    final repo = FakeStatusRepository(
      latencia: Duration.zero,
      contarCommissions: (id) async => id == 'em-andamento' ? 3 : 0,
    );
    await tester.pumpWidget(_painel(repo));
    await tester.pumpAndSettle();

    // Em andamento não é tipo obrigatório, então só os cartões impedem.
    await _abrirMenu(tester, 'em-andamento', 'Excluir');
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.textContaining('3 commissions'), findsOneWidget);
    expect(find.byKey(const ValueKey('status-linha-em-andamento')), findsOneWidget);
  });
}
