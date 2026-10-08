import 'package:flutter/foundation.dart' show immutable;

/// Commission como aparece na listagem (card do kanban): o essencial, sem
/// a descrição nem os adicionais. A versão completa é a
/// [CommissionDetalhadaModel].
@immutable
class CommissionResumoModel {
  const CommissionResumoModel({
    required this.id,
    required this.token,
    required this.nomeCliente,
    required this.tipoProdutoNome,
    required this.precoSimulado,
    this.orcamentoFinal,
    required this.posicao,
    required this.criadoEm,
  });

  factory CommissionResumoModel.fromJson(Map<String, dynamic> json) {
    return CommissionResumoModel(
      id: json['id'] as String,
      token: json['token'] as String,
      nomeCliente: json['nomeCliente'] as String,
      tipoProdutoNome: json['tipoProdutoNome'] as String,
      precoSimulado: (json['precoSimulado'] as num).toDouble(),
      orcamentoFinal: (json['orcamentoFinal'] as num?)?.toDouble(),
      posicao: json['posicao'] as int,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
    );
  }

  final String id;
  final String token;
  final String nomeCliente;
  final String tipoProdutoNome;

  /// Valor estimado pelo simulador, antes de o artista fechar o orçamento.
  final double precoSimulado;

  /// Valor combinado de fato; nulo enquanto o orçamento não foi fechado.
  final double? orcamentoFinal;

  /// Posição do card dentro da coluna.
  final int posicao;
  final DateTime criadoEm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'nomeCliente': nomeCliente,
        'tipoProdutoNome': tipoProdutoNome,
        'precoSimulado': precoSimulado,
        'orcamentoFinal': orcamentoFinal,
        'posicao': posicao,
        'criadoEm': criadoEm.toIso8601String(),
      };

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType &&
        other is CommissionResumoModel &&
        other.id == id &&
        other.token == token &&
        other.nomeCliente == nomeCliente &&
        other.tipoProdutoNome == tipoProdutoNome &&
        other.precoSimulado == precoSimulado &&
        other.orcamentoFinal == orcamentoFinal &&
        other.posicao == posicao &&
        other.criadoEm == criadoEm;
  }

  @override
  int get hashCode => Object.hash(
        id,
        token,
        nomeCliente,
        tipoProdutoNome,
        precoSimulado,
        orcamentoFinal,
        posicao,
        criadoEm,
      );

  @override
  String toString() => 'CommissionResumoModel($id, $nomeCliente)';
}
