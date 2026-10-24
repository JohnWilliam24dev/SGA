import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

({HttpDoisFatorRepository repo, FakeAdapter adapter, SessaoStore store})
_montar(Future<ResponseBody> Function(RequestOptions) responder) {
  final storage = MemoryTokenStorage(tokensRestrita);
  final store = SessaoStore(storage);
  final adapter = FakeAdapter(responder);
  return (
    repo: HttpDoisFatorRepository(client: clienteDe(adapter, storage), sessao: store),
    adapter: adapter,
    store: store,
  );
}

void main() {
  test('inativo: consulta o estado, inicia e devolve segredo e uri', () async {
    final t = _montar((o) async => o.path == '/auth/2fa/estado'
        ? jsonBody({'ativo': false, 'codigosRecuperacaoRestantes': 0}, 200)
        : jsonBody({'segredo': 'ABCD', 'uri': 'otpauth://totp/x'}, 200));

    final inicio = await t.repo.iniciar();

    expect(inicio, const DoisFatorInicio(segredo: 'ABCD', uri: 'otpauth://totp/x'));
    expect(t.adapter.chamadas.map((c) => c.path), ['/auth/2fa/estado', '/auth/2fa/iniciar']);
    expect(t.adapter.chamadas.first.headers['Authorization'], 'Bearer a1');
  });

  test('já ativo: devolve null e não inicia de novo', () async {
    final t = _montar(
      (_) async => jsonBody({'ativo': true, 'codigosRecuperacaoRestantes': 5}, 200),
    );
    expect(await t.repo.iniciar(), isNull);
    expect(t.adapter.contar('/auth/2fa/iniciar'), 0);
  });

  test('confirmar manda o código e devolve os códigos de recuperação', () async {
    final codigos = [for (var i = 1; i <= 8; i++) 'COD$i'];
    final t = _montar((_) async => jsonBody({'codigosRecuperacao': codigos}, 200));

    final r = await t.repo.confirmar('123456');

    expect(r, codigos);
    expect(Map<String, dynamic>.from(t.adapter.chamadas.single.data as Map), {'codigo': '123456'});
  });

  test('código errado vira ApiException', () async {
    final t = _montar((_) async => jsonBody({'error': 'Código inválido'}, 400));
    await expectLater(t.repo.confirmar('000000'), apiErro(ApiErroTipo.validacao));
  });

  test('concluir renova a sessão e o store vira logado', () async {
    final t = _montar((_) async => jsonBody(sessaoJson('2'), 200));
    await t.store.carregar();
    expect(t.store.estado, SessaoEstado.restrita);

    await t.repo.concluirAtivacao();

    expect(t.adapter.chamadas.single.path, '/auth/refresh');
    expect(Map<String, dynamic>.from(t.adapter.chamadas.single.data as Map), {'refreshToken': 'r1'});
    expect(t.store.estado, SessaoEstado.logada);
  });

  test('refresh recusado ao concluir derruba a sessão no store', () async {
    final t = _montar((_) async => jsonBody({'error': 'Sessão inválida'}, 401));
    await t.store.carregar();

    await expectLater(t.repo.concluirAtivacao(), apiErro(ApiErroTipo.sessaoExpirada));

    expect(t.store.estado, SessaoEstado.deslogado);
  });
}
