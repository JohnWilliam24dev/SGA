import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commission_detail_page.dart';

import '../support/helpers.dart';

class _RepositorioQueFalhaNoDetalhe extends FakeCommissionRepository {
  _RepositorioQueFalhaNoDetalhe() : super(latencia: Duration.zero);

  bool falhar = true;

  @override
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId) {
    if (falhar) throw Exception('sem conexão');
    return super.carregarDetalhe(commissionId);
  }
}

Future<CommissionResumoModel> _resumo(CommissionRepository repo, String id) async {
  final colunas = await repo.carregarQuadro();
  return colunas.expand((c) => c.commissions).firstWhere((c) => c.id == id);
}

Widget _pagina(
  CommissionRepository repo,
  CommissionResumoModel resumo, {
  VoidCallback? onBack,
}) {
  return sgaHome(
    CommissionDetailPage(
      repository: repo,
      commission: resumo,
      statusNome: 'Orçamento',
      onBack: onBack ?? () {},
    ),
  );
}

void main() {
  testWidgets('mostra o cabeçalho na hora e os dados completos ao carregar', (tester) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: const Duration(milliseconds: 50));
    final resumo = await _resumo(FakeCommissionRepository(latencia: Duration.zero), 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    expect(find.text('Marina Costa'), findsOneWidget);
    expect(find.text('Ilustração · Orçamento'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('R\$ 280,00'), findsOneWidget);
    expect(find.text('Ainda não fechado'), findsOneWidget);
    expect(find.textContaining('Ilustração full body'), findsOneWidget);
    expect(find.text('1x Fundo simples'), findsOneWidget);
    expect(find.text('R\$ 40,00 cada · subtotal R\$ 40,00'), findsOneWidget);
    expect(find.text('@marinacosta'), findsOneWidget);
    expect(find.text('marina.costa@exemplo.com'), findsOneWidget);
    expect(find.text('tok-c1'), findsOneWidget);
  });

  testWidgets('orçamento fechado e sem adicionais', (tester) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(repo, 'c6');

    await tester.pumpWidget(_pagina(repo, resumo));
    await tester.pumpAndSettle();

    expect(find.text('Ainda não fechado'), findsNothing);
    expect(find.text('R\$ 360,00'), findsNWidgets(2));
    expect(find.text('Nenhum adicional neste pedido.'), findsOneWidget);
  });

  testWidgets('sem e-mail, o campo nem aparece', (tester) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(repo, 'c9');

    await tester.pumpWidget(_pagina(repo, resumo));
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsNothing);
    expect(find.text('(71) 96666-0009'), findsOneWidget);
  });

  testWidgets('se falhar, mostra o erro e tentar de novo recarrega', (tester) async {
    useTallViewport(tester);
    final repo = _RepositorioQueFalhaNoDetalhe();
    final resumo = await _resumo(repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar os detalhes'), findsOneWidget);

    repo.falhar = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar os detalhes'), findsNothing);
    expect(find.text('@marinacosta'), findsOneWidget);
  });

  testWidgets('Voltar avisa a tela que chamou', (tester) async {
    useTallViewport(tester);
    var voltou = false;
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo, onBack: () => voltou = true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));

    expect(voltou, isTrue);
  });
}
