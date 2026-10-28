import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

final _resumo = {
  'periodo': {'de': '2026-10-01', 'ate': '2026-10-31', 'fuso': 'America/Sao_Paulo'},
  'totais': {'pedidos': 10, 'concluidos': 4, 'cancelados': 1, 'emAberto': 5},
  'concluidosNoPeriodo': 3,
  'receita': '450.50',
  'ticketMedio': '150.17',
  'porStatus': [
    {'statusId': 's1', 'nome': 'Fila', 'tipo': 'INICIAL', 'total': 5},
    {'statusId': 's2', 'nome': 'Concluído', 'tipo': 'CONCLUIDO', 'total': 4},
  ],
  'porTipoProduto': [
    {'tipoProdutoId': 't1', 'nome': 'Ilustração', 'total': 7, 'receita': '300.00'},
  ],
};

({HttpRelatorioRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpRelatorioRepository(client), adapter: adapter);
}

void main() {
  test('sem datas não manda query (o servidor usa o mês corrente)', () async {
    final t = _montar((_) async => jsonBody(_resumo, 200));
    await t.repo.carregarResumo();
    final c = t.adapter.chamadas.single;
    expect(c.path, '/relatorios/resumo');
    expect(c.queryParameters, isEmpty);
  });

  test('manda de e ate como YYYY-MM-DD', () async {
    final t = _montar((_) async => jsonBody(_resumo, 200));
    await t.repo.carregarResumo(de: DateTime(2026, 9), ate: DateTime(2026, 9, 30));
    expect(t.adapter.chamadas.single.queryParameters, {
      'de': '2026-09-01',
      'ate': '2026-09-30',
    });
  });

  test('converte o resumo: dinheiro em double e duas bases de tempo', () async {
    final t = _montar((_) async => jsonBody(_resumo, 200));
    final r = await t.repo.carregarResumo();

    expect((r.pedidos, r.concluidos, r.cancelados, r.emAberto), (10, 4, 1, 5));
    expect((r.receita, r.ticketMedio, r.concluidosNoPeriodo), (450.5, 150.17, 3));
    expect(r.de, DateTime(2026, 10));
    expect(r.taxaConclusao, 0.4);
    expect(r.porStatus.map((s) => (s.nome, s.tipo, s.total)), [
      ('Fila', StatusTipo.inicial, 5),
      ('Concluído', StatusTipo.concluido, 4),
    ]);
    expect((r.porTipo.single.nome, r.porTipo.single.receita), ('Ilustração', 300.0));
  });

  test('tipo nulo no relatório vira "Sem tipo"', () async {
    final t = _montar((_) async => jsonBody({
          ..._resumo,
          'porTipoProduto': [
            {'tipoProdutoId': null, 'nome': null, 'total': 2, 'receita': '80.00'},
          ],
        }, 200));
    final r = await t.repo.carregarResumo();
    expect((r.porTipo.single.nome, r.porTipo.single.total), ('Sem tipo', 2));
  });

  test('período inválido (400) chega com a mensagem do servidor', () async {
    final t = _montar((_) async => jsonBody({'error': 'Período maior que 366 dias.'}, 400));
    await expectLater(
      t.repo.carregarResumo(),
      throwsA(isA<ApiException>().having((e) => e.mensagem, 'mensagem', 'Período maior que 366 dias.')),
    );
  });
}
