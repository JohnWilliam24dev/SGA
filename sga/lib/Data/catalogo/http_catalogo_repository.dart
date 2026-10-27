import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Catálogo na API: `/tipos-produto` e `/adicionais` (administração) e as
/// opções para montar pedido, que combinam as duas listas. 400 e 409 do
/// servidor viram [CatalogoRegraException] com a mensagem dele.
class HttpCatalogoRepository
    implements CatalogoRepository, CatalogoAdminRepository {
  HttpCatalogoRepository(this._client);

  final ApiClient _client;

  Future<T> _regra<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on ApiException catch (e) {
      if (e.ehRegra) throw CatalogoRegraException(e.mensagem);
      rethrow;
    }
  }

  @override
  Future<List<TipoCatalogado>> listarTipos() => _regra(() async => [
        for (final j in listaDe(await _client.get('/tipos-produto')))
          tipoCatalogadoDeApi(j),
      ]);

  @override
  Future<List<AdicionalModel>> listarAdicionais() => _regra(() async => [
        for (final j in listaDe(await _client.get('/adicionais')))
          adicionalDoCatalogoDeApi(j),
      ]);

  /// `GET /catalogo/opcoes`: só tipos e adicionais habilitados, no formato
  /// da vitrine pública. O `valorUnitario` vem calculado pelo servidor, mas o
  /// [AdicionalModel] guarda a regra (`precoFixo` ou `porcentagem`) e o app
  /// recalcula igual com `preco.dart` para estimar o pedido.
  @override
  Future<List<OpcaoDeTipo>> carregarOpcoes() async {
    final json = mapaDe(await _client.get('/catalogo/opcoes'));
    return [
      for (final t in listaDe(json['tipos']))
        OpcaoDeTipo(
          tipo: tipoDeApi({...t, 'habilitado': true}),
          adicionais: [
            for (final a in listaDe(t['adicionais']))
              adicionalDoCatalogoDeApi({...a, 'habilitado': true}),
          ],
        ),
    ];
  }

  @override
  Future<TipoCatalogado> salvarTipo({
    String? id,
    required String nome,
    required double precoBase,
    required bool habilitado,
    required Set<String> adicionalIds,
  }) => _regra(() async {
        final corpo = {
          'nome': nome,
          'precoBase': duasCasas(precoBase),
          'habilitado': habilitado,
        };
        final salvo = mapaDe(
          id == null
              ? await _client.post('/tipos-produto', corpo: corpo)
              : await _client.patch('/tipos-produto/$id', corpo: corpo),
        );
        final tipo = tipoDeApi(salvo);
        await _client.put(
          '/tipos-produto/${tipo.id}/adicionais',
          corpo: {'adicionalIds': adicionalIds.toList()},
        );
        return TipoCatalogado(tipo: tipo, adicionalIds: {...adicionalIds});
      });

  @override
  Future<void> definirTipoHabilitado(String id, bool habilitado) => _regra(
        () => _client.patch('/tipos-produto/$id', corpo: {'habilitado': habilitado}),
      );

  @override
  Future<void> excluirTipo(String id) =>
      _regra(() => _client.delete('/tipos-produto/$id'));

  @override
  Future<AdicionalModel> salvarAdicional({
    String? id,
    required String nome,
    String? descricao,
    double? precoFixo,
    double? porcentagem,
    required bool habilitado,
  }) => _regra(() async {
        final texto = descricao?.trim() ?? '';
        final corpo = {
          'nome': nome,
          // Na edição, "" apaga a descrição; na criação, só vai se houver.
          if (id != null || texto.isNotEmpty) 'descricao': texto,
          if (precoFixo != null) 'precoFixo': duasCasas(precoFixo),
          if (porcentagem != null) 'porcentagem': duasCasas(porcentagem),
          'habilitado': habilitado,
        };
        return adicionalDoCatalogoDeApi(mapaDe(
          id == null
              ? await _client.post('/adicionais', corpo: corpo)
              : await _client.patch('/adicionais/$id', corpo: corpo),
        ));
      });

  @override
  Future<void> definirAdicionalHabilitado(String id, bool habilitado) => _regra(
        () => _client.patch('/adicionais/$id', corpo: {'habilitado': habilitado}),
      );

  @override
  Future<void> excluirAdicional(String id) =>
      _regra(() => _client.delete('/adicionais/$id'));
}
