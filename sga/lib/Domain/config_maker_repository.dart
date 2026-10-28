import 'models/config_maker_model.dart';

/// Configuração de orçamento do Maker.
abstract class ConfigMakerRepository {
  Future<ConfigMakerModel> carregar();

  /// Grava só o que foi informado e devolve o estado final.
  Future<ConfigMakerModel> salvar({bool? usaCatalogo, bool? exibirValorSimulado});
}

/// Versão simulada, em memória.
class FakeConfigMakerRepository implements ConfigMakerRepository {
  FakeConfigMakerRepository({
    this.latencia = const Duration(milliseconds: 200),
    ConfigMakerModel inicial = const ConfigMakerModel(),
  }) : _atual = inicial;

  final Duration latencia;
  ConfigMakerModel _atual;

  @override
  Future<ConfigMakerModel> carregar() async {
    await Future<void>.delayed(latencia);
    return _atual;
  }

  @override
  Future<ConfigMakerModel> salvar({
    bool? usaCatalogo,
    bool? exibirValorSimulado,
  }) async {
    await Future<void>.delayed(latencia);
    return _atual = _atual.copyWith(
      usaCatalogo: usaCatalogo,
      exibirValorSimulado: exibirValorSimulado,
    );
  }
}
