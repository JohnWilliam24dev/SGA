import 'package:dio/dio.dart' show FormData, RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Data/mappers/api_mappers.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

Map<String, dynamic> _cartao(String id, {String? orcamento}) => {
      'id': id, 'token': 'AB3DE', 'nomeCliente': 'Ana', 'contato': '@ana',
      'tipoProduto': 'Ilustração', 'precoSimulado': '120.00',
      'orcamentoFinal': orcamento, 'orcamentoFechado': orcamento != null,
      'posicao': 0, 'statusId': 's1',
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
  'precoSimulado': '160.00', 'orcamentoFinal': '150.50', 'orcamentoFechado': true,
  'posicao': 2,
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

  test('fecharOrcamento faz POST em /orcamento/fechar com 2 casas', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.fecharOrcamento('c1', 150.456);
    final c = t.adapter.chamadas.single;
    expect((c.method, c.path), ('POST', '/commissions/c1/orcamento/fechar'));
    expect(Map<String, dynamic>.from(c.data as Map), {'orcamentoFinal': 150.46});
  });

  test('fechar com orçamento já fechado (409) vira CommissionRegraException', () async {
    final t = _montar((_) async => jsonBody({'error': 'Orçamento fechado.'}, 409));
    await expectLater(
      t.repo.fecharOrcamento('c1', 10),
      throwsA(isA<CommissionRegraException>()
          .having((e) => e.mensagem, 'mensagem', 'Orçamento fechado.')),
    );
  });

  test('salvarAdicionais faz PUT com o conjunto final e usa o nome se não há texto', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.salvarAdicionais('c1', const [
      CommissionAdicionalModel(
        adicionalId: 'a1', nome: 'Fundo', quantidade: 2,
        descricaoCliente: null, valorUnitario: 40,
      ),
    ]);
    final c = t.adapter.chamadas.single;
    expect((c.method, c.path), ('PUT', '/commissions/c1/adicionais'));
    expect(Map<String, dynamic>.from(c.data as Map), {
      'adicionais': [
        {'adicionalId': 'a1', 'quantidade': 2, 'descricaoCliente': 'Fundo'},
      ],
    });
  });

  test('orcamentoEditavel: falso se fechado ou em coluna final', () async {
    Future<bool> com(bool fechado, String tipo) async {
      final t = _montar((_) async => jsonBody({
            'orcamentoFechado': fechado,
            'status': {'id': 's', 'nome': 'x', 'tipo': tipo},
          }, 200));
      return t.repo.orcamentoEditavel('c1');
    }

    expect(await com(false, 'EM_ANDAMENTO'), isTrue);
    expect(await com(true, 'EM_ANDAMENTO'), isFalse);
    expect(await com(false, 'CONCLUIDO'), isFalse);
    expect(await com(false, 'CANCELADO'), isFalse);
  });

  test('reabrirOrcamento faz POST em /orcamento/reabrir', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.reabrirOrcamento('c1');
    final c = t.adapter.chamadas.single;
    expect((c.method, c.path), ('POST', '/commissions/c1/orcamento/reabrir'));
  });

  test('reabrir com orçamento já aberto (409) mostra a mensagem do servidor', () async {
    final t = _montar((_) async => jsonBody({'error': 'O orçamento deste pedido já está aberto.'}, 409));
    await expectLater(
      t.repo.reabrirOrcamento('c1'),
      throwsA(isA<CommissionRegraException>()
          .having((e) => e.mensagem, 'mensagem', 'O orçamento deste pedido já está aberto.')),
    );
  });

  test('orcamentoReabrivel: só fechado e fora de coluna final', () async {
    Future<bool> com(bool fechado, String tipo) async {
      final t = _montar((_) async => jsonBody({
            'orcamentoFechado': fechado,
            'status': {'id': 's', 'nome': 'x', 'tipo': tipo},
          }, 200));
      return t.repo.orcamentoReabrivel('c1');
    }

    expect(await com(true, 'EM_ANDAMENTO'), isTrue);
    expect(await com(false, 'EM_ANDAMENTO'), isFalse);
    expect(await com(true, 'CONCLUIDO'), isFalse);
    expect(await com(true, 'CANCELADO'), isFalse);
  });

  test('criar manda multipart para /commissions/manual e devolve o detalhe', () async {
    final t = _montar((_) async => jsonBody({
          'id': 'c9', 'token': 'AB3DE', 'nomeCliente': 'Bia', 'contato': '@bia',
          'email': null, 'descricao': 'Retrato', 'imagemRefUrl': null,
          'precoSimulado': '160.00', 'orcamentoFinal': null, 'orcamentoFechado': false,
          'posicao': 0, 'criadoEm': '2026-10-26T10:00:00.000Z',
          'status': {'id': 's1', 'nome': 'Fila', 'tipo': 'INICIAL'},
          'tipoProduto': {'id': 't1', 'nome': 'Ilustração'},
          'adicionais': [],
        }, 201));

    final criada = await t.repo.criar(const NovaCommission(
      nomeCliente: 'Bia', contato: '@bia', descricao: 'Retrato',
      tipoProdutoId: 't1', tipoProdutoNome: 'Ilustração', precoBase: 120,
    ));

    final c = t.adapter.chamadas.single;
    expect((c.method, c.path), ('POST', '/commissions/manual'));
    expect(c.data, isA<FormData>());
    final campos = {for (final f in (c.data as FormData).fields) f.key: f.value};
    expect(campos['tipoProdutoId'], 't1');
    expect(campos['adicionais'], '[]');
    expect(campos.containsKey('email'), isFalse);
    expect((criada.id, criada.precoSimulado, criada.imagemRefUrl), ('c9', 160.0, ''));
  });

  test('orçamento só vira "final" no app quando a API diz que está fechado', () {
    final base = {
      'id': 'c1', 'token': 'T', 'nomeCliente': 'x', 'tipoProduto': 'Y',
      'precoSimulado': '100.00', 'orcamentoFinal': '150.00', 'posicao': 0,
      'criadoEm': '2026-10-26T10:00:00.000Z',
    };
    expect(resumoDeApi({...base, 'orcamentoFechado': false}).orcamentoFinal, isNull);
    expect(resumoDeApi({...base, 'orcamentoFechado': true}).orcamentoFinal, 150.0);
  });

  test('ApiException lê os campos da validação por campo', () {
    final e = ApiException.deResposta(400, {
      'error': 'Quantidade do adicional inválida.',
      'campos': [
        {'campo': 'adicionais.1.quantidade', 'mensagem': 'Quantidade do adicional inválida.'},
      ],
    });
    expect(e.campos.single.campo, 'adicionais.1.quantidade');
    expect(e.mensagem, 'Quantidade do adicional inválida.');
  });

  test('pedido sem tipo nem simulado (orçado à mão) é lido sem erro', () {
    final cartao = resumoDeApi({
      'id': 'c1', 'token': 'T', 'nomeCliente': 'x', 'tipoProduto': null,
      'precoSimulado': null, 'orcamentoFinal': null, 'orcamentoFechado': false,
      'posicao': 0, 'criadoEm': '2026-10-26T10:00:00.000Z',
    });
    expect((cartao.tipoProdutoNome, cartao.precoSimulado), (null, null));

    final detalhe = detalheDeApi({
      ..._detalhe, 'tipoProduto': null, 'precoSimulado': null,
      'orcamentoFinal': null, 'orcamentoFechado': false, 'adicionais': [],
    });
    expect((detalhe.tipoProdutoId, detalhe.tipoProdutoNome, detalhe.precoSimulado), (null, null, null));
    expect(detalhe.adicionais, isEmpty);
  });

  test('criar no modo manual não manda tipo nem adicionais', () async {
    final t = _montar((_) async => jsonBody({
          'id': 'c9', 'token': 'AB3DE', 'nomeCliente': 'Bia', 'contato': '@bia',
          'email': null, 'descricao': 'Retrato', 'imagemRefUrl': null,
          'precoSimulado': null, 'orcamentoFinal': null, 'orcamentoFechado': false,
          'posicao': 0, 'criadoEm': '2026-10-26T10:00:00.000Z',
          'status': {'id': 's1', 'nome': 'Fila', 'tipo': 'INICIAL'},
          'tipoProduto': null, 'adicionais': [],
        }, 201));

    final criada = await t.repo.criar(const NovaCommission(
      nomeCliente: 'Bia', contato: '@bia', descricao: 'Retrato',
    ));

    final campos = {for (final f in (t.adapter.chamadas.single.data as FormData).fields) f.key: f.value};
    expect(campos.keys.toSet(), {'nomeCliente', 'contato', 'descricao'});
    expect((criada.tipoProdutoId, criada.precoSimulado), (null, null));
  });

  test('valorSimuladoVisivel: lido do detalhe e verdadeiro quando ausente', () {
    final base = {..._detalhe, 'orcamentoFinal': null, 'orcamentoFechado': false};
    expect(detalheDeApi({...base, 'valorSimuladoVisivel': false}).valorSimuladoVisivel, isFalse);
    expect(detalheDeApi({...base, 'valorSimuladoVisivel': true}).valorSimuladoVisivel, isTrue);
    expect(detalheDeApi(base).valorSimuladoVisivel, isTrue);
  });

  test('429 sem Retry-After (não exposto no CORS) tem mensagem genérica', () {
    final e = ApiException.deResposta(429, {'error': 'Muitas requisições.'});
    expect(e.tipo, ApiErroTipo.limite);
    expect(e.retryAfter, isNull);
    expect(e.mensagemParaUsuario, 'Muitas requisições.');
  });
}
