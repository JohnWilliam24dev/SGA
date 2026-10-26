import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

const _base = Maker(nome: 'Ana', email: 'ana@x.com', senha: '', aceitouTermos: true);

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

    expect(t.adapter.chamadas.single.path, '/makers/m1');
    expect((m.nome, m.termosServico), ('Ana Souza', 'Pago antes'));
    expect((m.faz, m.naoFaz), (['Retrato'], ['NSFW']));
    expect((m.email, m.senha), ('', ''));
  });

  test('carregar com campos nulos devolve vazios', () async {
    final t = _montar((_) async => jsonBody({
          'id': 'm1', 'nome': 'Ana', 'termosCondicoes': null, 'facoENaoFaco': null,
        }, 200));
    final m = await t.repo.carregar('m1');
    expect((m.termosServico, m.faz, m.naoFaz), ('', <String>[], <String>[]));
  });

  test('salvar manda só o que mudou', () async {
    final t = _montar((_) async => jsonBody({}, 200));

    await t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(nome: 'Ana B'));
    await t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(termosServico: 'Novos'));

    expect(t.adapter.chamadas.first.method, 'PATCH');
    expect(t.adapter.chamadas.first.path, '/makers/m1');
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
    final locais = await t.repo.salvar(
      'm1',
      anterior: _base,
      novo: _base.copyWith(telefone: '1199', cidade: 'Recife'),
    );
    expect(t.adapter.chamadas, isEmpty);
    expect(locais, ['telefone', 'cidade']);
  });

  test('devolve os campos alterados que o servidor não guarda', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    final locais = await t.repo.salvar(
      'm1',
      anterior: _base,
      novo: _base.copyWith(nome: 'Ana B', nomeArtistico: 'AnaArt', email: 'novo@x.com'),
    );
    expect(locais, ['e-mail', 'nome artístico']);
    expect(_corpo(t.adapter.chamadas.single), {'nome': 'Ana B'});
  });

  test('400 do servidor continua ApiException com a mensagem dele', () async {
    final t = _montar((_) async => jsonBody({'error': 'Nome muito longo'}, 400));
    await expectLater(
      t.repo.salvar('m1', anterior: _base, novo: _base.copyWith(nome: 'x')),
      throwsA(isA<ApiException>().having((e) => e.mensagem, 'mensagem', 'Nome muito longo')),
    );
  });
}
