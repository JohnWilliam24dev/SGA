import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

CommissionResumoModel _c(String id) => CommissionResumoModel(
      id: id, token: 'T$id', nomeCliente: 'Cliente $id', tipoProdutoNome: 'Arte',
      precoSimulado: 10, posicao: 0, criadoEm: DateTime(2026, 10, 1),
    );

CommissionColumn _col(String id, List<String> ids, {int? total, bool temMais = false}) =>
    CommissionColumn(
      id: id, titulo: id, tipo: StatusTipo.emAndamento, ordem: 1,
      commissions: [for (final i in ids) _c(i)], total: total, temMais: temMais,
    );

void main() {
  test('sem total, a quantidade é o que está carregado', () {
    final c = _col('a', ['1', '2']);
    expect((c.quantidade, c.restantes, c.temMais), (2, 0, false));
  });

  test('com total, a quantidade é o total e restam os não carregados', () {
    final c = _col('a', ['1', '2'], total: 120, temMais: true);
    expect((c.quantidade, c.restantes), (120, 118));
  });

  test('mover para outra coluna acerta o total das duas', () {
    final r = moverCommission(
      [_col('a', ['1', '2'], total: 120, temMais: true), _col('b', ['3'], total: 7)],
      commissionId: '1', paraColunaId: 'b', paraIndice: 0,
    );
    expect((r[0].quantidade, r[0].commissions.length), (119, 1));
    expect((r[1].quantidade, r[1].commissions.length), (8, 2));
    expect(r[0].temMais, isTrue);
  });

  test('reordenar na mesma coluna não muda o total', () {
    final r = moverCommission(
      [_col('a', ['1', '2', '3'], total: 80, temMais: true)],
      commissionId: '1', paraColunaId: 'a', paraIndice: 2,
    );
    expect(r.single.commissions.map((c) => c.id), ['2', '3', '1']);
    expect(r.single.quantidade, 80);
  });

  test('coluna sem total continua sem total depois de mover', () {
    final r = moverCommission(
      [_col('a', ['1']), _col('b', [])],
      commissionId: '1', paraColunaId: 'b', paraIndice: 0,
    );
    expect(r.map((c) => c.total), [null, null]);
    expect(r[1].quantidade, 1);
  });
}
