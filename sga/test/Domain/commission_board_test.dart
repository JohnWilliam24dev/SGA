import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

CommissionResumoModel _c(String id) => CommissionResumoModel(
      id: id,
      token: 'tok-$id',
      nomeCliente: 'Cliente $id',
      tipoProdutoNome: 'Ilustração',
      precoSimulado: 100,
      posicao: 0,
      criadoEm: DateTime.utc(2026, 9, 1),
    );

List<CommissionColumn> _quadro() => [
      CommissionColumn(id: 'a', titulo: 'A', commissions: [_c('1'), _c('2'), _c('3')]),
      CommissionColumn(id: 'b', titulo: 'B', commissions: [_c('4')]),
      const CommissionColumn(id: 'c', titulo: 'C'),
    ];

List<String> _ids(List<CommissionColumn> q, String coluna) {
  return q.firstWhere((c) => c.id == coluna).commissions.map((c) => c.id).toList();
}

void main() {
  group('moverCommission', () {
    test('entre colunas, na posição pedida', () {
      final q = moverCommission(_quadro(), commissionId: '2', paraColunaId: 'b', paraIndice: 0);
      expect(_ids(q, 'a'), ['1', '3']);
      expect(_ids(q, 'b'), ['2', '4']);
    });

    test('para uma coluna vazia', () {
      final q = moverCommission(_quadro(), commissionId: '1', paraColunaId: 'c', paraIndice: 0);
      expect(_ids(q, 'c'), ['1']);
    });

    test('reordenando na mesma coluna (índice conta sem o item movido)', () {
      final q = moverCommission(_quadro(), commissionId: '1', paraColunaId: 'a', paraIndice: 2);
      expect(_ids(q, 'a'), ['2', '3', '1']);
    });

    test('índice fora da faixa vai para o fim', () {
      final q = moverCommission(_quadro(), commissionId: '1', paraColunaId: 'b', paraIndice: 99);
      expect(_ids(q, 'b'), ['4', '1']);
    });

    test('commission ou coluna inexistente não altera nada', () {
      final original = _quadro();
      expect(
        moverCommission(original, commissionId: 'x', paraColunaId: 'b', paraIndice: 0),
        same(original),
      );
      expect(
        moverCommission(original, commissionId: '1', paraColunaId: 'x', paraIndice: 0),
        same(original),
      );
    });

    test('não modifica a lista original', () {
      final original = _quadro();
      moverCommission(original, commissionId: '1', paraColunaId: 'b', paraIndice: 0);
      expect(_ids(original, 'a'), ['1', '2', '3']);
    });
  });

  test('repositório simulado carrega as colunas de exemplo e guarda o movimento',
      () async {
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    final colunas = await repo.carregarQuadro();
    expect(colunas.length, greaterThanOrEqualTo(3));

    await repo.mover(commissionId: 'c1', paraColunaId: 'producao', paraIndice: 0);
    final depois = await repo.carregarQuadro();
    expect(_ids(depois, 'producao').first, 'c1');
    expect(_ids(depois, 'orcamento'), isNot(contains('c1')));
  });

  group('detalhe no repositório simulado', () {
    test('traz os dados completos e acompanha a coluna do quadro', () async {
      final repo = FakeCommissionRepository(latencia: Duration.zero);

      final antes = await repo.carregarDetalhe('c1');
      expect(antes.nomeCliente, 'Marina Costa');
      expect(antes.statusId, 'orcamento');
      expect(antes.posicao, 0);
      expect(antes.adicionais, isNotEmpty);

      await repo.mover(commissionId: 'c1', paraColunaId: 'producao', paraIndice: 1);
      final depois = await repo.carregarDetalhe('c1');
      expect(depois.statusId, 'producao');
      expect(depois.posicao, 1);
    });

    test('o resumo do quadro bate com o detalhe', () async {
      final repo = FakeCommissionRepository(latencia: Duration.zero);
      final colunas = await repo.carregarQuadro();
      final resumo = colunas.first.commissions.first;
      final detalhe = await repo.carregarDetalhe(resumo.id);

      expect(detalhe.resumo, resumo);
    });

    test('commission inexistente falha', () {
      final repo = FakeCommissionRepository(latencia: Duration.zero);
      expect(repo.carregarDetalhe('nao-existe'), throwsStateError);
    });
  });
}
