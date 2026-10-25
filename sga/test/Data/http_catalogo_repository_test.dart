import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

Map<String, dynamic> _tipo(String id, {bool ativo = true, List<String> adds = const []}) => {
      'id': id, 'nome': 'Tipo $id', 'precoBase': '120.00', 'habilitado': ativo,
      'criadoEm': '2026-10-01T10:00:00.000Z', 'adicionalIds': adds,
    };

Map<String, dynamic> _add(String id, {bool ativo = true, String? fixo = '40.00', String? pct}) => {
      'id': id, 'nome': 'Add $id', 'descricao': null, 'precoFixo': fixo,
      'porcentagem': pct, 'habilitado': ativo, 'criadoEm': '2026-10-01T10:00:00.000Z',
    };

({HttpCatalogoRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpCatalogoRepository(client), adapter: adapter);
}

Map<String, dynamic> _corpo(RequestOptions o) => Map<String, dynamic>.from(o.data as Map);

void main() {
  test('listarTipos converte o preço em texto e os vínculos', () async {
    final t = _montar((_) async => jsonBody([_tipo('t1', adds: ['a1', 'a2'])], 200));
    final tipos = await t.repo.listarTipos();
    expect(tipos.single.tipo.precoBase, 120.0);
    expect(tipos.single.adicionalIds, {'a1', 'a2'});
  });

  test('listarAdicionais lê valor fixo e porcentagem em texto ou nulos', () async {
    final t = _montar((_) async => jsonBody([
          _add('a1'),
          _add('a2', fixo: null, pct: '15.50'),
        ], 200));
    final lista = await t.repo.listarAdicionais();
    expect((lista[0].precoFixo, lista[0].porcentagem), (40.0, null));
    expect((lista[1].precoFixo, lista[1].porcentagem), (null, 15.5));
  });

  test('carregarOpcoes só traz habilitados e seus adicionais habilitados', () async {
    final t = _montar((o) async => o.path == '/tipos-produto'
        ? jsonBody([
            _tipo('t1', adds: ['a1', 'a2']),
            _tipo('t2', ativo: false, adds: ['a1']),
          ], 200)
        : jsonBody([_add('a1'), _add('a2', ativo: false)], 200));

    final opcoes = await t.repo.carregarOpcoes();

    expect(opcoes.map((o) => o.tipo.id), ['t1']);
    expect(opcoes.single.adicionais.map((a) => a.id), ['a1']);
  });

  test('criar tipo faz POST e depois PUT dos adicionais', () async {
    final t = _montar((o) async => o.method == 'POST'
        ? jsonBody(_tipo('novo'), 201)
        : jsonBody(_tipo('novo', adds: ['a1']), 200));

    final r = await t.repo.salvarTipo(
      nome: 'Retrato', precoBase: 99.999, habilitado: true, adicionalIds: {'a1'},
    );

    final [post, put] = t.adapter.chamadas;
    expect((post.method, post.path), ('POST', '/tipos-produto'));
    expect(_corpo(post), {'nome': 'Retrato', 'precoBase': 100.0, 'habilitado': true});
    expect((put.method, put.path), ('PUT', '/tipos-produto/novo/adicionais'));
    expect(_corpo(put), {'adicionalIds': ['a1']});
    expect(r.tipo.id, 'novo');
  });

  test('editar tipo usa PATCH no id', () async {
    final t = _montar((_) async => jsonBody(_tipo('t1'), 200));
    await t.repo.salvarTipo(id: 't1', nome: 'X', precoBase: 10, habilitado: false, adicionalIds: {});
    expect(t.adapter.chamadas.first.method, 'PATCH');
    expect(t.adapter.chamadas.first.path, '/tipos-produto/t1');
  });

  test('criar adicional manda só a regra escolhida e omite descrição vazia', () async {
    final t = _montar((_) async => jsonBody(_add('a9'), 201));
    await t.repo.salvarAdicional(nome: 'Fundo', descricao: '  ', precoFixo: 40, habilitado: true);
    expect(_corpo(t.adapter.chamadas.single), {'nome': 'Fundo', 'precoFixo': 40.0, 'habilitado': true});
  });

  test('editar adicional troca a regra e "" apaga a descrição', () async {
    final t = _montar((_) async => jsonBody(_add('a1', fixo: null, pct: '20.00'), 200));
    await t.repo.salvarAdicional(id: 'a1', nome: 'Fundo', descricao: '', porcentagem: 20, habilitado: true);
    final req = t.adapter.chamadas.single;
    expect((req.method, req.path), ('PATCH', '/adicionais/a1'));
    expect(_corpo(req), {'nome': 'Fundo', 'descricao': '', 'porcentagem': 20.0, 'habilitado': true});
  });

  test('habilitar manda só o campo habilitado', () async {
    final t = _montar((_) async => jsonBody({}, 200));
    await t.repo.definirTipoHabilitado('t1', false);
    await t.repo.definirAdicionalHabilitado('a1', true);
    expect(_corpo(t.adapter.chamadas[0]), {'habilitado': false});
    expect(_corpo(t.adapter.chamadas[1]), {'habilitado': true});
  });

  test('excluir item em uso (409) vira CatalogoRegraException com a mensagem', () async {
    final t = _montar((_) async => jsonBody({'error': 'Tipo em uso: desabilite-o'}, 409));
    await expectLater(
      t.repo.excluirTipo('t1'),
      throwsA(isA<CatalogoRegraException>().having((e) => e.mensagem, 'mensagem', 'Tipo em uso: desabilite-o')),
    );
    await expectLater(t.repo.excluirAdicional('a1'), throwsA(isA<CatalogoRegraException>()));
  });

  test('erro de servidor continua ApiException', () async {
    final t = _montar((_) async => jsonBody({'error': 'x'}, 500));
    await expectLater(t.repo.listarTipos(), apiErro(ApiErroTipo.servidor));
  });
}
