import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';

import '../../support/fake_adapter.dart';

const _restrita = SessaoTokens(
  accessToken: 'a',
  refreshToken: 'r',
  makerId: 'm1',
  escopo: 'ativar2fa',
);

void main() {
  test('começa carregando e vira deslogado sem sessão guardada', () async {
    final store = SessaoStore(MemoryTokenStorage());
    expect(store.estado, SessaoEstado.carregando);
    await store.carregar();
    expect(store.estado, SessaoEstado.deslogado);
  });

  test('restaura sessão completa e sessão restrita', () async {
    final completa = SessaoStore(MemoryTokenStorage(tokensA1));
    final restrita = SessaoStore(MemoryTokenStorage(_restrita));
    await completa.carregar();
    await restrita.carregar();
    expect(completa.estado, SessaoEstado.logada);
    expect(completa.makerId, 'm1');
    expect(restrita.estado, SessaoEstado.restrita);
  });

  test('iniciar guarda a sessão, guarda os dados e avisa quem escuta', () async {
    final storage = MemoryTokenStorage();
    final store = SessaoStore(storage);
    await store.carregar();
    var avisos = 0;
    store.addListener(() => avisos++);

    await store.iniciar(tokensA1, nome: 'Maria', email: 'm@x.com');

    expect(store.estado, SessaoEstado.logada);
    expect(store.nome, 'Maria');
    expect((await storage.ler())!.accessToken, 'a1');
    expect(avisos, 1);
  });

  test('encerrar apaga a sessão e os dados de exibição', () async {
    final store = SessaoStore(MemoryTokenStorage(tokensA1));
    await store.iniciar(tokensA1, nome: 'Maria');
    await store.encerrar();
    expect(store.estado, SessaoEstado.deslogado);
    expect(store.nome, isNull);
    expect(store.refreshToken, isNull);
  });

  test('sincronizar enxerga a sessão apagada pela renovação do token', () async {
    final storage = MemoryTokenStorage(tokensA1);
    final store = SessaoStore(storage);
    await store.carregar();
    await storage.limpar();
    await store.sincronizar();
    expect(store.estado, SessaoEstado.deslogado);
  });

  test('códigos de recuperação restantes são lidos uma única vez', () async {
    final store = SessaoStore(MemoryTokenStorage());
    await store.iniciar(tokensA1, codigosRestantes: 2);
    expect(store.consumirCodigosRestantes(), 2);
    expect(store.consumirCodigosRestantes(), isNull);
  });
}
