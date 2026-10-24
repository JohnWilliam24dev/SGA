import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Colunas do kanban na API: `/status` (lista, criação, edição, exclusão) e
/// `PUT /status/ordem`. 400 e 409 do servidor viram [StatusRegraException]
/// com a mensagem dele.
class HttpStatusRepository implements StatusRepository {
  HttpStatusRepository(this._client);

  final ApiClient _client;

  Future<T> _regra<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      if (e.ehRegra) throw StatusRegraException(e.mensagem);
      rethrow;
    }
  }

  @override
  Future<List<StatusModel>> listar() => _regra(() async {
        final lista = [
          for (final j in listaDe(await _client.get('/status')))
            StatusModel.fromJson(j),
        ];
        return lista..sort((a, b) => a.ordem.compareTo(b.ordem));
      });

  @override
  Future<StatusModel> criar(String nome) => _regra(() async =>
      StatusModel.fromJson(
        mapaDe(await _client.post('/status', corpo: {'nome': nome})),
      ));

  @override
  Future<void> renomear(String id, String nome) =>
      _regra(() => _client.patch('/status/$id', corpo: {'nome': nome}));

  @override
  Future<void> trocarTipo(String id, StatusTipo tipo) => _regra(
        () => _client.patch('/status/$id', corpo: {'tipo': tipo.valorApi}),
      );

  @override
  Future<void> excluir(String id) => _regra(() => _client.delete('/status/$id'));

  @override
  Future<void> reordenar(List<String> idsNaNovaOrdem) => _regra(
        () => _client.put('/status/ordem', corpo: {'ids': idsNaNovaOrdem}),
      );
}
