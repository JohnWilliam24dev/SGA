import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commission_detail_page.dart';

import '../support/helpers.dart';

/// Falha ao carregar o detalhe enquanto [falhar] for verdadeiro. A falha é
/// assíncrona, como seria numa chamada de rede de verdade.
class _RepositorioQueFalhaNoDetalhe extends FakeCommissionRepository {
  _RepositorioQueFalhaNoDetalhe() : super(latencia: Duration.zero);

  bool falhar = true;
  int chamadas = 0;

  @override
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId) async {
    chamadas++;
    if (falhar) throw Exception('sem conexão');
    return super.carregarDetalhe(commissionId);
  }
}

/// Busca o resumo no repositório. O fake usa Future.delayed, que dentro do
/// testWidgets (relógio falso) nunca completa sozinho e trava o teste: por
/// isso roda no relógio real, com runAsync.
Future<CommissionResumoModel> _resumo(
  WidgetTester tester,
  CommissionRepository repo,
  String id,
) async {
  final colunas = (await tester.runAsync(() => repo.carregarQuadro()))!;
  return colunas.expand((c) => c.commissions).firstWhere((c) => c.id == id);
}

Widget _pagina(
  CommissionRepository repo,
  CommissionResumoModel resumo, {
  VoidCallback? onBack,
  bool compact = false,
}) {
  return sgaHome(
    CommissionDetailPage(
      repository: repo,
      commission: resumo,
      statusNome: 'Orçamento',
      onBack: onBack ?? () {},
      compact: compact,
    ),
  );
}

/// Avanço de tempo fixo (em vez de pumpAndSettle): se algo na tela ficar
/// animando para sempre, o teste falha nas expectativas em vez de travar.
Future<void> _aguardar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('mostra o cabeçalho na hora e os dados completos ao carregar', (
    tester,
  ) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: const Duration(milliseconds: 50));
    final resumo = await _resumo(
      tester,
      FakeCommissionRepository(latencia: Duration.zero),
      'c1',
    );

    await tester.pumpWidget(_pagina(repo, resumo));
    expect(find.text('Marina Costa'), findsOneWidget);
    expect(find.text('Ilustração · Orçamento'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await _aguardar(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Orçamento'), findsOneWidget); // título da seção
    expect(find.text('R\$ 280,00'), findsOneWidget);
    expect(find.text('marina.costa@exemplo.com'), findsOneWidget);
    expect(find.text('@marinacosta'), findsOneWidget);
    expect(find.textContaining('Fundo simples'), findsOneWidget);
    expect(find.textContaining('Ilustração full body'), findsOneWidget);
  });

  testWidgets('orçamento fechado aparece e sem adicionais avisa que não há', (
    tester,
  ) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c6');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);

    expect(find.text('R\$ 360,00'), findsWidgets);
    expect(find.text('Nenhum adicional neste pedido.'), findsOneWidget);
  });

  testWidgets('sem e-mail, mostra "Não informado"', (tester) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c9');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);

    expect(find.text('Não informado'), findsOneWidget);
    expect(find.text('(71) 96666-0009'), findsOneWidget);
  });

  testWidgets('se falhar, mostra o erro e tentar de novo recarrega', (tester) async {
    useTallViewport(tester);
    final repo = _RepositorioQueFalhaNoDetalhe();
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);
    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(repo.chamadas, 1);

    repo.falhar = false;
    await tester.tap(find.text('Tentar de novo'));
    await _aguardar(tester);

    expect(repo.chamadas, 2);
    expect(find.text('Não foi possível carregar'), findsNothing);
    expect(find.text('@marinacosta'), findsOneWidget);
  });

  testWidgets('o botão Voltar avisa a tela que chamou', (tester) async {
    useTallViewport(tester);
    var voltou = false;
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo, onBack: () => voltou = true));
    await _aguardar(tester);
    await tester.tap(find.text('Voltar'));

    expect(voltou, isTrue);
  });

  testWidgets('na nota (desktop), o X fecha e avisa a tela que chamou', (
    tester,
  ) async {
    useTallViewport(tester);
    var fechou = false;
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(
      _pagina(repo, resumo, onBack: () => fechou = true, compact: true),
    );
    await _aguardar(tester);
    expect(find.text('@marinacosta'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));

    expect(fechou, isTrue);
  });

  testWidgets('Fechar Orçamento pede confirmação e trava a edição', (tester) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);
    await tester.enterText(find.widgetWithText(TextField, '280,00'), '350,00');
    await tester.tap(find.text('Fechar Orçamento'));
    await _aguardar(tester);
    expect(find.text('Fechar orçamento?'), findsOneWidget);

    await tester.tap(find.text('Fechar orçamento'));
    await _aguardar(tester);
    await _aguardar(tester);

    expect(find.text('Fechar Orçamento'), findsNothing);
    expect(find.text('R\$ 350,00'), findsOneWidget);
    expect((await tester.runAsync(() => repo.carregarDetalhe('c1')))!.orcamentoFinal, 350);
  });

  testWidgets('pedido em Concluído sem fechar não deixa editar o orçamento', (
    tester,
  ) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    await tester.runAsync(
      () => repo.mover(commissionId: 'c1', paraColunaId: 'concluido', paraIndice: 0),
    );
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);

    expect(find.text('Fechar Orçamento'), findsNothing);
    expect(find.text('Ainda não fechado'), findsOneWidget);
  });

  testWidgets('adicionar e remover adicional atualiza o valor simulado', (
    tester,
  ) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);
    await tester.tap(find.byTooltip('Aumentar quantidade'));
    await _aguardar(tester);
    expect(find.text('R\$ 320,00'), findsOneWidget);

    await tester.tap(find.byTooltip('Remover adicional'));
    await _aguardar(tester);
    await _aguardar(tester);
    expect(find.text('Nenhum adicional neste pedido.'), findsOneWidget);
    expect(find.text('R\$ 240,00'), findsOneWidget);
  });

  testWidgets('Aceitar copia o valor simulado para o orçamento', (tester) async {
    useTallViewport(tester);
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final resumo = await _resumo(tester, repo, 'c1');

    await tester.pumpWidget(_pagina(repo, resumo));
    await _aguardar(tester);
    await tester.enterText(find.widgetWithText(TextField, '280,00'), '999,00');
    await tester.tap(find.text('Aceitar'));
    await tester.pump();

    expect(find.widgetWithText(TextField, '280,00'), findsOneWidget);
  });
}
