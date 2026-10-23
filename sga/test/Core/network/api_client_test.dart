import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';

import '../../support/fake_adapter.dart';

void main() {
  test('injeta o Bearer e devolve o JSON decodificado', () async {
    final adapter = FakeAdapter((_) async => jsonBody({'ok': true}, 200));
    final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));

    final r = await client.get('/status', query: {'limite': 5});

    expect(r, {'ok': true});
    final req = adapter.chamadas.single;
    expect(req.headers['Authorization'], 'Bearer a1');
    expect(req.uri.toString(), 'http://api.teste/status?limite=5');
  });

  test('sem sessão ou com autenticado: false não manda token', () async {
    final adapter = FakeAdapter((_) async => jsonBody({}, 200));
    final semSessao = clienteDe(adapter, MemoryTokenStorage());
    final publico = clienteDe(adapter, MemoryTokenStorage(tokensA1));

    await semSessao.get('/x');
    await publico.get('/y', autenticado: false);

    expect(adapter.chamadas[0].headers.containsKey('Authorization'), isFalse);
    expect(adapter.chamadas[1].headers.containsKey('Authorization'), isFalse);
  });

  test('204 devolve null', () async {
    final adapter = FakeAdapter((_) async => jsonBody(null, 204));
    final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
    expect(await client.delete('/status/1'), isNull);
  });

  test('traduz as falhas HTTP em ApiException', () async {
    final adapter = FakeAdapter((o) async => switch (o.path) {
          '/conflito' => jsonBody({'error': 'Em uso'}, 409),
          '/limite' => jsonBody(
              {'error': 'Calma'},
              429,
              headers: {'retry-after': ['45']},
            ),
          '/grande' => jsonBody({'error': 'Grande'}, 413),
          _ => jsonBody({'error': 'Falhou'}, 500),
        });
    final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));

    await expectLater(client.get('/conflito'), apiErro(ApiErroTipo.conflito));
    await expectLater(client.get('/grande'), apiErro(ApiErroTipo.arquivoGrande));
    await expectLater(client.get('/outro'), apiErro(ApiErroTipo.servidor));
    await expectLater(
      client.get('/limite'),
      throwsA(isA<ApiException>()
          .having((e) => e.retryAfter, 'retryAfter', const Duration(seconds: 45))
          .having((e) => e.mensagem, 'mensagem', 'Calma')),
    );
  });

  test('falta de rede vira erro de conexão', () async {
    final adapter = FakeAdapter((o) async => throw DioException(
          requestOptions: o,
          type: DioExceptionType.connectionError,
        ));
    final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
    await expectLater(client.get('/status'), apiErro(ApiErroTipo.conexao));
  });

  test('401 de chamada pública (login) não tenta renovar', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody({'error': 'Credenciais inválidas'}, 401),
    );
    final client = clienteDe(adapter, MemoryTokenStorage());

    await expectLater(
      client.post('/auth/login', corpo: {'email': 'a'}, autenticado: false),
      throwsA(isA<ApiException>()
          .having((e) => e.mensagem, 'mensagem', 'Credenciais inválidas')),
    );
    expect(adapter.contar('/auth/refresh'), 0);
  });
}
