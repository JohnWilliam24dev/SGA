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

Finder _naColuna(String colunaId, String texto) {
  return find.descendant(
    of: find.byKey(ValueKey('kanban-column-$colunaId')),
    matching: find.text(texto),
  );
}

Future<void> _arrastar(
  WidgetTester tester,
  Offset origem,
  Offset destino,
) async {
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

  testWidgets('mostra o carregamento e depois as colunas com os pedidos', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(
      _pagina(FakeCommissionRepository(latencia: Duration.zero)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    for (final coluna in [
      'Fila',
      'Em andamento',
      'Concluído',
      'Cancelado',
    ]) {
      expect(find.text(coluna), findsOneWidget);
    }
    expect(_naColuna('fila', 'Marina Costa'), findsOneWidget);
  });

  testWidgets('o card mostra cliente, tipo de produto e valor', (tester) async {
    viewport(tester);
    await tester.pumpWidget(
      _pagina(FakeCommissionRepository(latencia: Duration.zero)),
    );
    await tester.pumpAndSettle();

    // c1: ainda sem orçamento final, mostra o simulado.
    expect(_naColuna('fila', 'Ilustração'), findsWidgets);
    expect(_naColuna('fila', 'R\$ 280,00 (simulado)'), findsOneWidget);
    // c4: orçamento final fechado, mostra só ele.
    expect(_naColuna('em-andamento', 'R\$ 560,00'), findsOneWidget);
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
    expect(status, 'Em andamento');
  });

  testWidgets('apertar e segurar move o card e não abre o detalhe', (
    tester,
  ) async {
    viewport(tester);
    var aberturas = 0;
    await tester.pumpWidget(
      _pagina(
        FakeCommissionRepository(latencia: Duration.zero),
        onOpen: (_, _) => aberturas++,
      ),
    );
    await tester.pumpAndSettle();

    await _arrastar(
      tester,
      tester.getCenter(find.text('Marina Costa')),
      tester.getCenter(find.text('Beatriz Lima')),
    );

    expect(_naColuna('em-andamento', 'Marina Costa'), findsOneWidget);
    expect(aberturas, 0);
  });

  testWidgets(
    'segurar sem soltar na hora e largar no mesmo lugar não abre o detalhe',
    (tester) async {
      viewport(tester);
      var aberturas = 0;
      await tester.pumpWidget(
        _pagina(
          FakeCommissionRepository(latencia: Duration.zero),
          onOpen: (_, _) => aberturas++,
        ),
      );
      await tester.pumpAndSettle();

      final gesto = await tester.startGesture(
        tester.getCenter(find.text('Marina Costa')),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await gesto.up();
      await tester.pumpAndSettle();

      expect(aberturas, 0);
    },
  );

  testWidgets('arrastar um pedido para outra coluna o move', (tester) async {
    viewport(tester);
    await tester.pumpWidget(
      _pagina(FakeCommissionRepository(latencia: Duration.zero)),
    );
    await tester.pumpAndSettle();

    await _arrastar(
      tester,
      tester.getCenter(find.text('Marina Costa')),
      tester.getCenter(find.text('Beatriz Lima')),
    );

    expect(_naColuna('em-andamento', 'Marina Costa'), findsOneWidget);
    expect(_naColuna('fila', 'Marina Costa'), findsNothing);
  });

  testWidgets('se o repositório falhar, o pedido volta e um aviso aparece', (
    tester,
  ) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(_RepositorioQueFalha()));
    await tester.pumpAndSettle();

    await _arrastar(
      tester,
      tester.getCenter(find.text('Marina Costa')),
      tester.getCenter(find.text('Beatriz Lima')),
    );

    expect(_naColuna('fila', 'Marina Costa'), findsOneWidget);
    expect(find.text('Não foi possível mover a commission.'), findsOneWidget);
  });

  group('colunas no próprio quadro', () {
    Future<void> abrirMenu(WidgetTester tester, String id, String acao) async {
      await tester.tap(find.byKey(ValueKey('column-menu-$id')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(acao));
      await tester.pumpAndSettle();
    }

    double x(WidgetTester tester, String id) {
      return tester.getTopLeft(find.byKey(ValueKey('kanban-column-$id'))).dx;
    }

    testWidgets('Renomear troca o título da coluna', (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      await abrirMenu(tester, 'fila', 'Renomear');
      await tester.enterText(
        find.byKey(const ValueKey('status-nome-campo')),
        'Entrada',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(_naColuna('fila', 'Entrada'), findsOneWidget);
      expect(find.text('Fila'), findsNothing);
      // Os pedidos continuam na coluna.
      expect(_naColuna('fila', 'Marina Costa'), findsOneWidget);
    });

    testWidgets('Nova coluna cria uma coluna vazia no fim do quadro', (
      tester,
    ) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nova coluna'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('status-nome-campo')),
        'Revisão',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Criar'));
      await tester.pumpAndSettle();

      expect(_naColuna('status-1', 'Revisão'), findsOneWidget);
      expect(_naColuna('status-1', 'Nenhum pedido aqui'), findsOneWidget);
      expect(x(tester, 'status-1'), greaterThan(x(tester, 'cancelado')));
    });

    testWidgets('Mover para a direita pelo menu troca a ordem das colunas', (
      tester,
    ) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      await abrirMenu(tester, 'fila', 'Mover para a direita');

      expect(x(tester, 'fila'), greaterThan(x(tester, 'em-andamento')));
      expect(x(tester, 'fila'), lessThan(x(tester, 'concluido')));
    });

    testWidgets('arrastar o ícone da coluna a leva para onde for solta', (
      tester,
    ) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      final icone = tester.getCenter(
        find.byKey(const ValueKey('kanban-column-handle-fila')),
      );
      final destino = tester.getCenter(
        find.byKey(const ValueKey('kanban-column-concluido')),
      );
      final gesto = await tester.startGesture(icone);
      await gesto.moveTo(icone + const Offset(40, 0));
      await tester.pump();
      await gesto.moveTo(Offset(destino.dx, icone.dy));
      await tester.pump(const Duration(milliseconds: 50));
      await gesto.up();
      await tester.pumpAndSettle();

      expect(x(tester, 'em-andamento'), lessThan(x(tester, 'concluido')));
      expect(x(tester, 'concluido'), lessThan(x(tester, 'fila')));
      expect(x(tester, 'fila'), lessThan(x(tester, 'cancelado')));
      // Os pedidos foram junto com a coluna.
      expect(_naColuna('fila', 'Marina Costa'), findsOneWidget);
    });

    testWidgets('excluir coluna com pedidos mostra quantos e a mantém', (
      tester,
    ) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      await abrirMenu(tester, 'em-andamento', 'Excluir coluna');
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(find.textContaining('6 commissions'), findsOneWidget);
      expect(find.byKey(const ValueKey('kanban-column-em-andamento')), findsOneWidget);
    });

    testWidgets('excluir o último Cancelado mostra o motivo e o mantém', (
      tester,
    ) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      await abrirMenu(tester, 'cancelado', 'Excluir coluna');
      await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
      await tester.pumpAndSettle();

      expect(find.textContaining('última coluna do tipo Cancelado'), findsOneWidget);
      expect(find.byKey(const ValueKey('kanban-column-cancelado')), findsOneWidget);
    });

    testWidgets('Alterar tipo muda o tipo e respeita as regras', (tester) async {
      viewport(tester);
      await tester.pumpWidget(
        _pagina(FakeCommissionRepository(latencia: Duration.zero)),
      );
      await tester.pumpAndSettle();

      // O único Concluído não pode virar outro tipo.
      await abrirMenu(tester, 'concluido', 'Alterar tipo');
      await tester.tap(find.byKey(const ValueKey('tipo-emAndamento')));
      await tester.pumpAndSettle();
      expect(find.textContaining('última coluna do tipo Concluído'), findsOneWidget);
    });
  });
}
