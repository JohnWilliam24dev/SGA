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
    required this.tipoProdutoId,
    required this.tipoProdutoNome,
    required this.precoBase,
    this.adicionais = const [],
  });

  final String nomeCliente;
  final String contato;
  final String? email;
  final String descricao;
  final String tipoProdutoId;
  final String tipoProdutoNome;
  final double precoBase;
  final List<CommissionAdicionalModel> adicionais;

  /// Preço base mais os adicionais escolhidos.
  double get precoSimulado =>
      arredondarCentavos(precoBase + somaDosAdicionais(adicionais));
}
