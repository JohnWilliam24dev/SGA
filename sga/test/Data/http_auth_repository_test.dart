import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

({HttpAuthRepository repo, FakeAdapter adapter, SessaoStore store})
_montar(
  Future<ResponseBody> Function(RequestOptions) responder, [
  SessaoTokens? inicial,
]) {
  final storage = MemoryTokenStorage(inicial);
  final store = SessaoStore(storage);
  final adapter = FakeAdapter(responder);
  return (
    repo: HttpAuthRepository(client: clienteDe(adapter, storage), sessao: store),
    adapter: adapter,
    store: store,
  );
}

Map<String, dynamic> _corpo(RequestOptions o) =>
    Map<String, dynamic>.from(o.data as Map);

void main() {
  test('cadastro manda só nome, e-mail e senha e cai na sessão restrita', () async {
    final t = _montar(
      (_) async => jsonBody({
        ...sessaoJson('1'),
        'escopo': 'ativar2fa',
        'id': 'm1',
        'nome': 'Maria',
        'email': 'maria@x.com',
      }, 201),
    );

    await t.repo.cadastrar(nome: 'Maria', email: 'maria@x.com', senha: 'Senha12345');

    final req = t.adapter.chamadas.single;
    expect(req.path, '/auth/cadastro');
    expect(_corpo(req), {'nome': 'Maria', 'email': 'maria@x.com', 'senha': 'Senha12345'});
    expect(req.headers.containsKey('Authorization'), isFalse);
    expect(t.store.estado, SessaoEstado.restrita);
    expect(t.store.nome, 'Maria');
  });

  test('login simples entra com sessão completa', () async {
    final t = _montar((_) async => jsonBody(sessaoJson('1'), 200));
    final r = await t.repo.entrar(
      const Credenciais(email: 'maria@x.com', senha: 'Senha12345'),
    );
    expect(r, isA<LoginConcluido>());
    expect(t.store.estado, SessaoEstado.logada);
  });

  test('login de conta com 2FA devolve o desafio e não cria sessão', () async {
    final t = _montar(
      (_) async => jsonBody({
        'requer2fa': true,
        'desafio': 'desafio-1',
        'desafioExpiraEm': '2026-10-23T12:00:00Z',
      }, 200),
    );
    await t.store.carregar();

    final r = await t.repo.entrar(
      const Credenciais(email: 'maria@x.com', senha: 'Senha12345'),
    );

    expect(r, isA<LoginRequer2fa>().having((e) => e.desafio, 'desafio', 'desafio-1'));
    expect(t.store.estado, SessaoEstado.deslogado);
  });

  test('2FA com código do app envia só o código', () async {
    final t = _montar(
      (_) async => jsonBody({...sessaoJson('1'), 'codigosRecuperacaoRestantes': 2}, 200),
    );
    final restantes = await t.repo.confirmarLogin2fa(desafio: 'd', codigo: '123456');

    expect(_corpo(t.adapter.chamadas.single), {'desafio': 'd', 'codigo': '123456'});
    expect(restantes, 2);
    expect(t.store.estado, SessaoEstado.logada);
  });

  test('2FA com código de recuperação envia só o código de recuperação', () async {
    final t = _montar((_) async => jsonBody(sessaoJson('1'), 200));
    await t.repo.confirmarLogin2fa(desafio: 'd', codigoRecuperacao: 'ABCDEF123456');

    expect(
      _corpo(t.adapter.chamadas.single),
      {'desafio': 'd', 'codigoRecuperacao': 'ABCDEF123456'},
    );
  });

  test('credenciais erradas viram ApiException e não criam sessão', () async {
    final t = _montar((_) async => jsonBody({'error': 'Credenciais inválidas'}, 401));
    await t.store.carregar();

    await expectLater(
      t.repo.entrar(const Credenciais(email: 'a@b.com', senha: 'x')),
      throwsA(isA<ApiException>().having((e) => e.mensagem, 'mensagem', 'Credenciais inválidas')),
    );
    expect(t.store.estado, SessaoEstado.deslogado);
  });

  test('logout manda o refresh token e limpa a sessão', () async {
    final t = _montar((_) async => jsonBody(null, 204), tokensA1);
    await t.store.carregar();

    await t.repo.sair();

    final req = t.adapter.chamadas.single;
    expect(req.path, '/auth/logout');
    expect(_corpo(req), {'refreshToken': 'r1'});
    expect(t.store.estado, SessaoEstado.deslogado);
  });

  test('logout sem rede sai do aparelho mesmo assim', () async {
    final t = _montar(
      (o) async => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      ),
      tokensA1,
    );
    await t.store.carregar();

    await t.repo.sair();

    expect(t.store.estado, SessaoEstado.deslogado);
  });
}
