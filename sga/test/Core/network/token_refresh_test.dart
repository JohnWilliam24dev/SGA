import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';

import '../../support/fake_adapter.dart';

/// Servidor em que o token `a1` expirou e a renovação entrega o `a2`.
FakeAdapter servidor({
  Future<ResponseBody> Function(RequestOptions)? refresh,
  bool sempre401 = false,
}) =>
    FakeAdapter((o) async {
      if (o.path == '/auth/refresh') {
        return refresh != null
            ? refresh(o)
            : Future.delayed(
                const Duration(milliseconds: 10),
                () => jsonBody(sessaoJson('2'), 200),
              );
      }
      final velho = o.headers['Authorization'] == 'Bearer a1';
      return (velho || sempre401)
          ? jsonBody({'error': 'Token expirado'}, 401)
          : jsonBody({'caminho': o.path}, 200);
    });

void main() {
  test('401 renova uma vez, repete a chamada e guarda a sessão nova', () async {
    final adapter = servidor();
    final storage = MemoryTokenStorage(tokensA1);
    final client = clienteDe(adapter, storage);

    final r = await client.get('/status');

    expect(r, {'caminho': '/status'});
    expect(adapter.contar('/auth/refresh'), 1);
    expect(adapter.chamadas.last.headers['Authorization'], 'Bearer a2');
    expect((await storage.ler())!.refreshToken, 'r2');
  });

  test('chamadas simultâneas com 401 geram um único refresh', () async {
    final adapter = servidor();
    final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));

    final r = await Future.wait([
      client.get('/a'),
      client.get('/b'),
      client.get('/c'),
    ]);

    expect(r.map((e) => e['caminho']), ['/a', '/b', '/c']);
    expect(adapter.contar('/auth/refresh'), 1);
  });

  test('refresh recusado encerra a sessão e avisa o app', () async {
    final adapter = servidor(
      refresh: (_) async => jsonBody({'error': 'Sessão inválida'}, 401),
    );
    final storage = MemoryTokenStorage(tokensA1);
    final client = clienteDe(adapter, storage);
    var avisos = 0;
    client.onSessaoEncerrada = () => avisos++;

    await expectLater(
      client.get('/status'),
      apiErro(ApiErroTipo.sessaoExpirada),
    );

    expect(await storage.ler(), isNull);
    expect(avisos, 1);
  });

  test('refresh sem rede mantém a sessão', () async {
    final adapter = servidor(
      refresh: (o) async => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      ),
    );
    final storage = MemoryTokenStorage(tokensA1);
    final client = clienteDe(adapter, storage);
    var avisos = 0;
    client.onSessaoEncerrada = () => avisos++;

    await expectLater(client.get('/status'), apiErro(ApiErroTipo.conexao));

    expect(await storage.ler(), isNotNull);
    expect(avisos, 0);
  });

  test('chamada repetida que volta 401 não entra em laço', () async {
    final adapter = servidor(sempre401: true);
    final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));

    await expectLater(
      client.get('/status'),
      apiErro(ApiErroTipo.sessaoExpirada),
    );

    expect(adapter.contar('/auth/refresh'), 1);
    expect(adapter.contar('/status'), 2);
  });
}
