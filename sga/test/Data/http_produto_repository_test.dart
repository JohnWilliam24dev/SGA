import 'dart:typed_data';

import 'package:dio/dio.dart' show FormData, RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

Map<String, dynamic> _produto(String id, {String? descricao}) => {
      'id': id, 'nome': 'Arte $id', 'descricao': descricao,
      'imagemUrl': 'https://img/$id.png',
      'tipoProduto': {'id': 't1', 'nome': 'Ilustração'},
      'criadoEm': '2026-10-01T10:00:00.000Z',
    };

({HttpProdutoRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpProdutoRepository(client), adapter: adapter);
}

final _png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

void main() {
  test('listar pede com offset e traduz o tipo aninhado e a paginação', () async {
    final t = _montar((_) async => jsonBody({
          'itens': [_produto('p1', descricao: 'Retrato')], 'total': 51, 'temMais': true,
        }, 200));

    final pagina = await t.repo.listar(offset: 50);

    expect(t.adapter.chamadas.single.uri.queryParameters, {'offset': '50'});
    expect(pagina.itens.single.tipoProdutoId, 't1');
    expect(pagina.itens.single.imagemUrl, 'https://img/p1.png');
    expect((pagina.total, pagina.temMais), (51, true));
  });

  test('criar envia multipart com os campos e a imagem com o tipo certo', () async {
    final t = _montar((_) async => jsonBody(_produto('novo'), 201));

    final r = await t.repo.criar(NovoProduto(
      nome: 'Retrato', tipoProdutoId: 't1', descricao: 'Aquarela', imagem: _png,
    ));

    final req = t.adapter.chamadas.single;
    final form = req.data as FormData;
    expect((req.method, req.path), ('POST', '/produtos'));
    expect({for (final f in form.fields) f.key: f.value},
        {'tipoProdutoId': 't1', 'nome': 'Retrato', 'descricao': 'Aquarela'});
    final arquivo = form.files.single;
    expect(arquivo.key, 'imagem');
    expect(arquivo.value.filename, 'imagem.png');
    expect(arquivo.value.contentType.toString(), 'image/png');
    expect(r.id, 'novo');
  });

  test('criar sem descrição não envia o campo', () async {
    final t = _montar((_) async => jsonBody(_produto('novo'), 201));
    await t.repo.criar(NovoProduto(nome: 'A', tipoProdutoId: 't1', imagem: _png));
    final form = t.adapter.chamadas.single.data as FormData;
    expect(form.fields.map((f) => f.key), ['tipoProdutoId', 'nome']);
  });

  test('imagem que não é PNG, JPEG ou WebP nem chega ao servidor', () async {
    final t = _montar((_) async => jsonBody(_produto('x'), 201));
    await expectLater(
      t.repo.criar(NovoProduto(nome: 'A', tipoProdutoId: 't1', imagem: Uint8List.fromList([1, 2, 3]))),
      throwsA(isA<ProdutoRegraException>()),
    );
    expect(t.adapter.chamadas, isEmpty);
  });

  test('atualizar usa PATCH sem imagem; limparDescricao manda vazio', () async {
    final t = _montar((_) async => jsonBody(_produto('p1'), 200));
    await t.repo.atualizar('p1', nome: 'Novo', tipoProdutoId: 't2', descricao: 'D');
    await t.repo.atualizar('p1', nome: 'Novo', tipoProdutoId: 't2', limparDescricao: true);
    await t.repo.atualizar('p1', nome: 'Novo', tipoProdutoId: 't2');

    final [a, b, c] = t.adapter.chamadas;
    expect((a.method, a.path), ('PATCH', '/produtos/p1'));
    expect(a.data, {'nome': 'Novo', 'tipoProdutoId': 't2', 'descricao': 'D'});
    expect(b.data, {'nome': 'Novo', 'tipoProdutoId': 't2', 'descricao': ''});
    expect(c.data, {'nome': 'Novo', 'tipoProdutoId': 't2'});
  });

  test('excluir usa DELETE', () async {
    final t = _montar((_) async => jsonBody(null, 204));
    await t.repo.excluir('p1');
    expect((t.adapter.chamadas.single.method, t.adapter.chamadas.single.path), ('DELETE', '/produtos/p1'));
  });

  test('413 do servidor vira ProdutoRegraException', () async {
    final t = _montar((_) async => jsonBody({'error': 'Imagem grande demais'}, 413));
    await expectLater(
      t.repo.criar(NovoProduto(nome: 'A', tipoProdutoId: 't1', imagem: _png)),
      throwsA(isA<ProdutoRegraException>().having((e) => e.mensagem, 'mensagem', 'Imagem grande demais')),
    );
  });

  test('erro de servidor continua ApiException', () async {
    final t = _montar((_) async => jsonBody({'error': 'x'}, 500));
    await expectLater(t.repo.listar(), apiErro(ApiErroTipo.servidor));
  });
}
