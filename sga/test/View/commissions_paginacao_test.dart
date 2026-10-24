import 'package:easy_ui/easy_ui.dart' show Tela;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commissions_page.dart';

import '../support/helpers.dart';

CommissionResumoModel _c(String id, String cliente) => CommissionResumoModel(
      id: id, token: 'T$id', nomeCliente: cliente, tipoProdutoNome: 'Arte',
      precoSimulado: 10, posicao: 0, criadoEm: DateTime(2026, 10, 1),
    );

/// Uma coluna com 3 pedidos no total, mas só o primeiro carregado.
class _Paginado extends FakeCommissionRepository {
  _Paginado({this.falha = false}) : super(latencia: Duration.zero);

  final bool falha;
  final offsets = <int>[];

  @override
  Future<List<CommissionColumn>> carregarQuadro() async => [
        CommissionColumn(
          id: 'fila', titulo: 'Fila', tipo: StatusTipo.inicial, ordem: 1,
          commissions: [_c('c1', 'Ana')], total: 3, temMais: true,
        ),
      ];

  @override
  Future<Pagina<CommissionResumoModel>> carregarMais(
    String statusId, {
    required int offset,
  }) async {
    offsets.add(offset);
    if (falha) throw const CommissionRegraException('Servidor ocupado');
    return Pagina(
      itens: [_c('c2', 'Bia'), _c('c3', 'Caio')],
      total: 3,
      temMais: false,
    );
  }
}

Widget _pagina(_Paginado repo) => sgaHome(
      Tela(
        child: CommissionsPage(
          repository: repo,
          statusRepository: repo.statusRepository,
          onOpenCommission: (_, _) {},
        ),
      ),
    );

void main() {
  void viewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('coluna paginada mostra o total e o botão Carregar mais', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(_Paginado()));
    await tester.pumpAndSettle();

    expect(find.text('Carregar mais (2)'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // selo com o total, não com 1
    expect(find.textContaining('Bia'), findsNothing);
  });

  testWidgets('Carregar mais traz a próxima página e some quando acaba', (tester) async {
    viewport(tester);
    final repo = _Paginado();
    await tester.pumpWidget(_pagina(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Carregar mais (2)'));
    await tester.pumpAndSettle();

    expect(repo.offsets, [1]); // já havia 1 pedido na tela
    expect(find.textContaining('Bia'), findsOneWidget);
    expect(find.textContaining('Caio'), findsOneWidget);
    expect(find.textContaining('Carregar mais'), findsNothing);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('falha ao carregar mais mostra a mensagem e mantém o botão', (tester) async {
    viewport(tester);
    await tester.pumpWidget(_pagina(_Paginado(falha: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Carregar mais (2)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Servidor ocupado'), findsOneWidget);
    expect(find.text('Carregar mais (2)'), findsOneWidget);
  });
}
