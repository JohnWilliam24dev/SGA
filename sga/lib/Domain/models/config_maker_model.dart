import 'package:flutter/foundation.dart' show immutable;

/// Como o Maker precifica os pedidos novos (decorre das duas chaves).
enum ModalidadePedido {
  /// Tipo de produto, adicionais e valor simulado do catálogo.
  catalogo,

  /// Sem tipo nem simulado: o Maker orça cada pedido à mão.
  manual,
}

/// Configuração de orçamento do Maker (`GET/PATCH /config-maker`). As duas
/// chaves são independentes: voltar ao catálogo restaura a preferência de
/// exibição de antes. Só vale para pedidos criados depois da mudança.
@immutable
class ConfigMakerModel {
  const ConfigMakerModel({
    this.usaCatalogo = true,
    this.exibirValorSimulado = true,
  });

  /// Pedidos novos usam tipo de produto, adicionais e preço calculado.
  final bool usaCatalogo;

  /// O cliente vê os preços do catálogo e o valor simulado.
  final bool exibirValorSimulado;

  ModalidadePedido get modalidade =>
      usaCatalogo ? ModalidadePedido.catalogo : ModalidadePedido.manual;

  /// O que o cliente de fato enxerga: só com catálogo e exibição ligados.
  bool get exibirValores => usaCatalogo && exibirValorSimulado;

  ConfigMakerModel copyWith({bool? usaCatalogo, bool? exibirValorSimulado}) =>
      ConfigMakerModel(
        usaCatalogo: usaCatalogo ?? this.usaCatalogo,
        exibirValorSimulado: exibirValorSimulado ?? this.exibirValorSimulado,
      );

  @override
  bool operator ==(Object other) =>
      other is ConfigMakerModel &&
      other.usaCatalogo == usaCatalogo &&
      other.exibirValorSimulado == exibirValorSimulado;

  @override
  int get hashCode => Object.hash(usaCatalogo, exibirValorSimulado);
}
