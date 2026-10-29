import 'package:dio/dio.dart' show DioException, DioExceptionType;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';

import '../../support/fake_adapter.dart';

({ApiClient client, FakeAdapter adapter, void Function(Duration) avancar})
_montar([Future<dynamic> Function(String rota)? alvo]) {
  var agora = DateTime(2026, 10, 28, 12);
  final adapter = FakeAdapter(
    (o) async => jsonBody({'rota': '${o.method} ${o.path}'}, 200),
  );
  final client = ApiClient(
    config: const ApiConfig(baseUrl: 'http://api.teste/'),
    storage: MemoryTokenStorage(tokensA1),
    adapter: adapter,
    cache: ApiCache(agora: () => agora),
  );
  return (
    client: client,
    adapter: adapter,
    avancar: (d) => agora = agora.add(d),
  );
}

void main() {
  test('a mesma leitura em menos de 1 minuto vai ao servidor uma vez só', () async {
    final t = _montar();
    await t.client.get('/status');
    t.avancar(const Duration(seconds: 30));
    await t.client.get('/status');
    expect(t.adapter.contar('/status'), 1);
  });

  test('depois de 1 minuto pede de novo', () async {
    final t = _montar();
    await t.client.get('/status');
    t.avancar(const Duration(minutes: 1));
    await t.client.get('/status');
    expect(t.adapter.contar('/status'), 2);
  });

  test('query diferente é outra leitura; a ordem dos parâmetros não importa', () async {
    final t = _montar();
    await t.client.get('/commissions', query: {'statusId': 's1', 'offset': 50});
    await t.client.get('/commissions', query: {'offset': 50, 'statusId': 's1'});
    await t.client.get('/commissions', query: {'statusId': 's2', 'offset': 50});
    expect(t.adapter.contar('/commissions'), 2);
  });

  test('qualquer escrita esvazia o cache', () async {
    final t = _montar();
    await t.client.get('/status');
    await t.client.patch('/status/s1', corpo: {'nome': 'Novo'});
    await t.client.get('/status');
    expect(t.adapter.contar('/status'), 2);
  });

  test('ignorarCache vai ao servidor mesmo com resposta guardada', () async {
    final t = _montar();
    await t.client.get('/status');
    await t.client.get('/status', ignorarCache: true);
    expect(t.adapter.contar('/status'), 2);
  });

  test('/auth e rotas públicas nunca são guardadas', () async {
    final t = _montar();
    await t.client.get('/auth/2fa/estado');
    await t.client.get('/auth/2fa/estado');
    await t.client.get('/publica', autenticado: false);
    await t.client.get('/publica', autenticado: false);
    expect(t.adapter.contar('/auth/2fa/estado'), 2);
    expect(t.adapter.contar('/publica'), 2);
  });

  test('leituras simultâneas iguais viram uma chamada', () async {
    final t = _montar();
    await Future.wait([t.client.get('/status'), t.client.get('/status')]);
    expect(t.adapter.contar('/status'), 1);
  });

  test('erro não é guardado: tentar de novo vai ao servidor', () async {
    var falhar = true;
    final adapter = FakeAdapter((o) async {
      if (falhar) {
        throw DioException(requestOptions: o, type: DioExceptionType.connectionError);
      }
      return jsonBody({'ok': true}, 200);
    });
    final client = ApiClient(
      config: const ApiConfig(baseUrl: 'http://api.teste/'),
      storage: MemoryTokenStorage(tokensA1),
      adapter: adapter,
    );
    await expectLater(client.get('/status'), apiErro(ApiErroTipo.conexao));
    falhar = false;
    expect(await client.get('/status'), {'ok': true});
    expect(adapter.contar('/status'), 2);
  });

  test('fim de sessão descarta o cache', () async {
    final t = _montar();
    await t.client.get('/status');
    t.client.onSessaoEncerrada = () {};
    // Simula o aviso de sessão encerrada (refresh recusado).
    final adapter = FakeAdapter((o) async => o.path == '/auth/refresh'
        ? jsonBody({'error': 'Sessão inválida'}, 401)
        : jsonBody({'x': 1}, 401));
    final client = ApiClient(
      config: const ApiConfig(baseUrl: 'http://api.teste/'),
      storage: MemoryTokenStorage(tokensA1),
      adapter: adapter,
    );
    var avisos = 0;
    client.onSessaoEncerrada = () => avisos++;
    await expectLater(client.get('/status'), apiErro(ApiErroTipo.sessaoExpirada));
    expect(avisos, 1);
  });
}
