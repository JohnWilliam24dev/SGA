import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

Map<String, dynamic> _cartao(String id, {String? orcamento}) => {
      'id': id, 'token': 'AB3DE', 'nomeCliente': 'Ana', 'contato': '@ana',
      'tipoProduto': 'Ilustração', 'precoSimulado': '120.00',
      'orcamentoFinal': orcamento, 'posicao': 0, 'statusId': 's1',
      'imagemRefUrl': 'https://x/img.png', 'criadoEm': '2026-10-01T10:00:00.000Z',
    };

Map<String, dynamic> _coluna(String id, int ordem, String tipo,
        {int total = 0, bool temMais = false, List<Object> cartoes = const []}) =>
    {
      'status': {'id': id, 'nome': 'Col $id', 'ordem': ordem, 'tipo': tipo},
      'total': total, 'temMais': temMais, 'cartoes': cartoes,
    };

const _detalhe = {
  'id': 'c1', 'token': 'AB3DE', 'nomeCliente': 'Ana', 'contato': '@ana',
  'email': null, 'descricao': 'Quero um retrato', 'imagemRefUrl': 'https://x/i.png',
  'precoSimulado': '160.00', 'orcamentoFinal': '150.50', 'posicao': 2,
  'criadoEm': '2026-10-01T10:00:00.000Z',
  'status': {'id': 's1', 'nome': 'Fila', 'tipo': 'INICIAL'},
  'tipoProduto': {'id': 't1', 'nome': 'Ilustração'},
  'adicionais': [
    {'adicionalId': 'a1', 'nome': 'Fundo', 'quantidade': 2, 'descricaoCliente': 'Praia',
     'valorUnitario': '40.00', 'subtotal': '80.00'},
  ],
};

({HttpCommissionRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpCommissionRepository(client), adapter: adapter);
}

void main() {
  test('quadro: ordena as colunas e traduz cartões, dinheiro e totais', () async {
    final t = _montar((_) async => jsonBody({
          'colunas': [
            _coluna('s2', 2, 'EM_ANDAMENTO'),
            _coluna('s1', 1, 'INICIAL', total: 120, temMais: true,
                cartoes: [_cartao('c1'), _cartao('c2', orcamento: '150.50')]),
          ],
        }, 200));

    final colunas = await t.repo.carregarQuadro();

    expect(colunas.map((c) => c.id), ['s1', 's2']);
    final fila = colunas.first;
    expect(fila.titulo, 'Col s1');
    expect(fila.tipo, StatusTipo.inicial);
    expect((fila.quantidade, fila.temMais, fila.restantes), (120, true, 118));
    expect(fila.commissions.first.tipoProdutoNome, 'Ilustração');
    expect(fila.commissions.first.precoSimulado, 120.0);
    expect(fila.commissions.first.orcamentoFinal, isNull);
    expect(fila.commissions.last.orcamentoFinal, 150.5);
  });

  test('carregarMais pede a coluna com offset e devolve a página', () async {
    final t = _montar((_) async => jsonBody({
          'colunas': [_coluna('s1', 1, 'INICIAL', total: 52, cartoes: [_cartao('c51')])],
        }, 200));

    final pagina = await t.repo.carregarMais('s1', offset: 50);

    expect(t.adapter.chamadas.single.uri.queryParameters, {'statusId': 's1', 'offset': '50'});
    expect(pagina.itens.single.id, 'c51');
    expect((pagina.total, pagina.temMais), (52, false));
  });

  test('detalhe: achata status e tipo e converte os adicionais', () async {
    final t = _montar((_) async => jsonBody(_detalhe, 200));

    final d = await t.repo.carregarDetalhe('c1');

    expect(t.adapter.chamadas.single.path, '/commissions/c1');
    expect((d.statusId, d.tipoProdutoId, d.tipoProdutoNome), ('s1', 't1', 'Ilustração'));
    expect((d.precoSimulado, d.orcamentoFinal), (160.0, 150.5));
    expect(d.email, isNull);
    expect(d.adicionais.single.valorUnitario, 40.0);
    expect(d.adicionais.single.subtotal, 80.0);
    expect(d.adicionais.single.descricaoCliente, 'Praia');
  });

  test('mover manda statusId e posição (limitada a 100000)', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.mover(commissionId: 'c1', paraColunaId: 's2', paraIndice: 3);
    await t.repo.mover(commissionId: 'c1', paraColunaId: 's2', paraIndice: 999999);

    final req = t.adapter.chamadas.first;
    expect((req.method, req.path), ('PATCH', '/commissions/c1/mover'));
    expect(Map<String, dynamic>.from(req.data as Map), {'statusId': 's2', 'posicao': 3});
    expect((t.adapter.chamadas.last.data as Map)['posicao'], 100000);
  });

  test('409 ao mover vira CommissionRegraException com a mensagem do servidor', () async {
    final t = _montar((_) async => jsonBody({'error': 'Pedido já concluído'}, 409));
    await expectLater(
      t.repo.mover(commissionId: 'c1', paraColunaId: 's2', paraIndice: 0),
      throwsA(isA<CommissionRegraException>().having((e) => e.mensagem, 'mensagem', 'Pedido já concluído')),
    );
  });

  test('erro do servidor continua ApiException (não é regra)', () async {
    final t = _montar((_) async => jsonBody({'error': 'x'}, 500));
    await expectLater(t.repo.carregarQuadro(), apiErro(ApiErroTipo.servidor));
  });

  test('contarPorStatus lê totalCommissions de /status', () async {
    final t = _montar((_) async => jsonBody([
          {'id': 's1', 'nome': 'Fila', 'ordem': 1, 'tipo': 'INICIAL', 'totalCommissions': 3},
          {'id': 's2', 'nome': 'Feito', 'ordem': 2, 'tipo': 'CONCLUIDO', 'totalCommissions': 0},
        ], 200));
    expect(await t.repo.contarPorStatus('s1'), 3);
    expect(await t.repo.contarPorStatus('nao-existe'), 0);
  });

  test('ações sem contrato no backend recusam com mensagem clara', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await expectLater(
      t.repo.fecharOrcamento('c1', 10),
      throwsA(isA<CommissionRegraException>()),
    );
    expect(await t.repo.orcamentoEditavel('c1'), isFalse);
    expect(t.adapter.chamadas, isEmpty);
  });
}
