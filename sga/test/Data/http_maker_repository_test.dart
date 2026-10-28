import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

const _base = Maker(nome: 'Ana', email: 'ana@x.com', aceitouTermos: true);

({HttpMakerRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpMakerRepository(client), adapter: adapter);
}

Map<String, dynamic> _corpo(RequestOptions o) => Map<String, dynamic>.from(o.data as Map);

void main() {
  test('carregar lê nome, termos e as listas do texto faço e não faço', () async {
    final t = _montar((_) async => jsonBody({
          'id': 'm1', 'nome': 'Ana Souza', 'termosCondicoes': 'Pago antes',
          'facoENaoFaco': 'Faço:\n- Retrato\n\nNão faço:\n- NSFW',
        }, 200));

    final m = await t.repo.carregar('m1');

    expect(t.adapter.chamadas.single.path, '/makers/me');
    expect((m.nome, m.termosServico), ('Ana Souza', 'Pago antes'));
    expect(m.faz, ['Retrato']);
    expect(m.naoFaz, ['NSFW']);
    expect(m.email, '');
  });

  test('carregar com campos nulos devolve vazios', () async {
    final t = _montar((_) async => jsonBody({
          'id': 'm1', 'nome': 'Ana', 'termosCondicoes': null, 'facoENaoFaco': null,
        }, 200));
    final m = await t.repo.carregar('m1');
    expect(m.termosServico, '');
    expect(m.faz, isEmpty);
    expect(m.naoFaz, isEmpty);
  });

  test('salvar manda só o que mudou', () async {
    final t = _montar((_) async => jsonBody({}, 200));

    await t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(nome: 'Ana B'));
    await t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(termosServico: 'Novos'));

    expect(t.adapter.chamadas.first.method, 'PATCH');
    expect(t.adapter.chamadas.first.path, '/makers/me');
    expect(_corpo(t.adapter.chamadas[0]), {'nome': 'Ana B'});
    expect(_corpo(t.adapter.chamadas[1]), {'termosCondicoes': 'Novos'});
  });

  test('mudar as listas manda o texto codificado', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(faz: ['A'], naoFaz: ['B']));
    expect(_corpo(t.adapter.chamadas.single), {'facoENaoFaco': 'Faço:\n- A\n\nNão faço:\n- B'});
  });

  test('sem mudança no que o servidor guarda, nem chama a API', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.salvar('m1', anterior: _base, novo: _base);
    expect(t.adapter.chamadas, isEmpty);
  });

  test('o e-mail é da sessão: mudar só ele não chama a API', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(email: 'outro@x.com'));
    expect(t.adapter.chamadas, isEmpty);
  });
}
