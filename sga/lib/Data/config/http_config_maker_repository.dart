import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Configuração de orçamento na API: `GET` e `PATCH /config-maker`.
///
/// Corpo e resposta: `{ usaCatalogo, exibirValorSimulado }` (booleanos, padrão
/// `true`). O `PATCH` é parcial (ao menos um campo, campo extra é 400) e
/// devolve o estado final. Só vale para pedidos criados depois da mudança.
class HttpConfigMakerRepository implements ConfigMakerRepository {
  HttpConfigMakerRepository(this._client);

  final ApiClient _client;

  static ConfigMakerModel _ler(Object? json) {
    final j = mapaDe(json);
    return ConfigMakerModel(
      usaCatalogo: j['usaCatalogo'] != false,
      exibirValorSimulado: j['exibirValorSimulado'] != false,
    );
  }

  @override
  Future<ConfigMakerModel> carregar() async =>
      _ler(await _client.get('/config-maker'));

  @override
  Future<ConfigMakerModel> salvar({
    bool? usaCatalogo,
    bool? exibirValorSimulado,
  }) async => _ler(
    await _client.patch(
      '/config-maker',
      corpo: {
        if (usaCatalogo != null) 'usaCatalogo': usaCatalogo,
        if (exibirValorSimulado != null)
          'exibirValorSimulado': exibirValorSimulado,
      },
    ),
  );
}
