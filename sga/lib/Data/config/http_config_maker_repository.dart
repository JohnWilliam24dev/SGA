import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';

/// Configuração de orçamento na API: `GET` e `PATCH /config-maker`.
///
/// ATENÇÃO: contrato PROPOSTO no planejamento do backend (modalidades de
/// orçamento, fase 3), ainda não implementado lá. Corpo: `usaCatalogo` e
/// `exibirValorSimulado` (booleanos). O `PATCH` é parcial (ao menos um campo)
/// e devolve o estado final. Conferir com o `openapi.json` quando sair.
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
