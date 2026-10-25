import 'package:dio/dio.dart' show DioMediaType, FormData, MultipartFile;

import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Portfólio na API: `GET/POST/PATCH/DELETE /produtos`. A criação vai em
/// `multipart/form-data` com a imagem. 400, 409 e 413 do servidor viram
/// [ProdutoRegraException] com a mensagem dele.
class HttpProdutoRepository implements ProdutoRepository {
  HttpProdutoRepository(this._client);

  final ApiClient _client;

  Future<T> _regra<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      if (e.ehRegra || e.tipo == ApiErroTipo.arquivoGrande) {
        throw ProdutoRegraException(e.mensagem);
      }
      rethrow;
    }
  }

  @override
  Future<Pagina<ProdutoModel>> listar({int offset = 0}) => _regra(() async {
        final json = mapaDe(await _client.get('/produtos', query: {'offset': offset}));
        return Pagina(
          itens: [for (final j in listaDe(json['itens'])) produtoDeApi(j)],
          total: json['total'] as int,
          temMais: json['temMais'] as bool,
        );
      });

  @override
  Future<ProdutoModel> criar(NovoProduto novo) => _regra(() async {
        final mime = mimeDaImagem(novo.imagem);
        if (mime == null) {
          throw const ProdutoRegraException('Use uma imagem PNG, JPG ou WebP.');
        }
        final corpo = FormData.fromMap({
          'tipoProdutoId': novo.tipoProdutoId,
          'nome': novo.nome,
          if (novo.descricao != null) 'descricao': novo.descricao,
          'imagem': MultipartFile.fromBytes(
            novo.imagem,
            filename: 'imagem.${extensaoDaImagem(mime)}',
            contentType: DioMediaType.parse(mime),
          ),
        });
        return produtoDeApi(mapaDe(await _client.post('/produtos', corpo: corpo)));
      });

  @override
  Future<ProdutoModel> atualizar(
    String id, {
    required String nome,
    required String tipoProdutoId,
    String? descricao,
    bool limparDescricao = false,
  }) => _regra(() async => produtoDeApi(mapaDe(
        await _client.patch('/produtos/$id', corpo: {
          'nome': nome,
          'tipoProdutoId': tipoProdutoId,
          if (limparDescricao) 'descricao': '' else if (descricao != null) 'descricao': descricao,
        }),
      )));

  @override
  Future<void> excluir(String id) => _regra(() => _client.delete('/produtos/$id'));
}
