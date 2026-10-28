import 'package:flutter/foundation.dart' show immutable;

import 'models/models.dart';
import 'preco.dart';

/// Pedido que o próprio Maker cria pelo painel, com os dados que o cliente
/// preencheria no formulário público.
@immutable
class NovaCommission {
  const NovaCommission({
    required this.nomeCliente,
    required this.contato,
    this.email,
    required this.descricao,
    this.tipoProdutoId,
    this.tipoProdutoNome,
    this.precoBase,
    this.adicionais = const [],
  });

  final String nomeCliente;
  final String contato;
  final String? email;
  final String descricao;
  /// Os três ficam nulos no modo manual (o Maker orça o pedido à mão).
  final String? tipoProdutoId;
  final String? tipoProdutoNome;
  final double? precoBase;
  final List<CommissionAdicionalModel> adicionais;

  /// Preço base mais os adicionais escolhidos; nulo sem tipo de produto.
  double? get precoSimulado => precoBase == null
      ? null
      : arredondarCentavos(precoBase! + somaDosAdicionais(adicionais));
}
