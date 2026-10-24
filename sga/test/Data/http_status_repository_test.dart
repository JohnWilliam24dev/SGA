import 'package:dio/dio.dart'
    show DioException, DioExceptionType, RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

({HttpStatusRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpStatusRepository(client), adapter: adapter);
}

Map<String, dynamic> _status(String id, int ordem, String tipo) => {
      'id': id, 'nome': 'Col $id', 'ordem': ordem, 'tipo': tipo,
      'criadoEm': '2026-10-01T10:00:00.000Z', 'totalCommissions': 4,
    };

void main() {
  test('listar ordena por ordem e ignora campos extras da API', () async {
    final t = _montar((_) async => jsonBody([
          _status('b', 2, 'CONCLUIDO'),
          _status('a', 1, 'INICIAL'),
        ], 200));

    final lista = await t.repo.listar();

    expect(lista.map((s) => s.id), ['a', 'b']);
    expect(lista.last.tipo, StatusTipo.concluido);
  });

  test('criar manda só o nome e devolve o status criado', () async {
    final t = _montar((_) async => jsonBody(_status('n', 5, 'EM_ANDAMENTO'), 201));

    final criado = await t.repo.criar('Revisão');

    expect(t.adapter.chamadas.single.method, 'POST');
    expect(Map<String, dynamic>.from(t.adapter.chamadas.single.data as Map), {'nome': 'Revisão'});
    expect(criado.tipo, StatusTipo.emAndamento);
  });

  test('renomear e trocar tipo usam PATCH com o valor da API', () async {
    final t = _montar((_) async => jsonBody(_status('a', 1, 'INICIAL'), 200));
    await t.repo.renomear('a', 'Nova');
    await t.repo.trocarTipo('a', StatusTipo.cancelado);

    expect(t.adapter.chamadas.map((c) => '${c.method} ${c.path}'), ['PATCH /status/a', 'PATCH /status/a']);
    expect((t.adapter.chamadas[0].data as Map), {'nome': 'Nova'});
    expect((t.adapter.chamadas[1].data as Map), {'tipo': 'CANCELADO'});
  });

  test('reordenar manda a lista completa de ids em PUT /status/ordem', () async {
    final t = _montar((_) async => jsonBody([], 200));
    await t.repo.reordenar(['b', 'a']);

    final req = t.adapter.chamadas.single;
    expect((req.method, req.path), ('PUT', '/status/ordem'));
    expect(req.data as Map, {'ids': ['b', 'a']});
  });

  test('excluir coluna com pedidos (409) vira StatusRegraException', () async {
    final t = _montar((_) async => jsonBody({'error': 'A coluna tem pedidos'}, 409));
    await expectLater(
      t.repo.excluir('a'),
      throwsA(isA<StatusRegraException>().having((e) => e.mensagem, 'mensagem', 'A coluna tem pedidos')),
    );
  });

  test('sem rede continua ApiException de conexão', () async {
    final t = _montar((o) async => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ));
    await expectLater(t.repo.listar(), apiErro(ApiErroTipo.conexao));
  });
}
