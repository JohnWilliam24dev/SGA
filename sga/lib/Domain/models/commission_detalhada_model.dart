import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'commission_adicional_model.dart';
import 'commission_resumo_model.dart';

/// Commission completa, como vem ao abrir os detalhes: tudo do resumo mais
/// status, contato, descrição, referência e os adicionais escolhidos.
@immutable
class CommissionDetalhadaModel extends CommissionResumoModel {
  const CommissionDetalhadaModel({
    required super.id,
    required super.token,
    required super.nomeCliente,
    required super.tipoProdutoNome,
    required super.precoSimulado,
    super.orcamentoFinal,
    required super.posicao,
    required super.criadoEm,
    required this.statusId,
    required this.tipoProdutoId,
    required this.contato,
    required this.descricao,
    required this.imagemRefUrl,
    this.email,
    required this.adicionais,
  });

  factory CommissionDetalhadaModel.fromJson(Map<String, dynamic> json) {
    final resumo = CommissionResumoModel.fromJson(json);
    return CommissionDetalhadaModel(
      id: resumo.id,
      token: resumo.token,
      nomeCliente: resumo.nomeCliente,
      tipoProdutoNome: resumo.tipoProdutoNome,
      precoSimulado: resumo.precoSimulado,
      orcamentoFinal: resumo.orcamentoFinal,
      posicao: resumo.posicao,
      criadoEm: resumo.criadoEm,
      statusId: json['statusId'] as String,
      tipoProdutoId: json['tipoProdutoId'] as String,
      contato: json['contato'] as String,
      descricao: json['descricao'] as String,
      imagemRefUrl: json['imagemRefUrl'] as String,
      email: json['email'] as String?,
      adicionais: [
        for (final item in json['adicionais'] as List<dynamic>)
          CommissionAdicionalModel.fromJson(item as Map<String, dynamic>),
      ],
    );
  }

  final String statusId;
  final String tipoProdutoId;
  final String contato;
  final String descricao;
  final String imagemRefUrl;
  final String? email;
  final List<CommissionAdicionalModel> adicionais;

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'statusId': statusId,
        'tipoProdutoId': tipoProdutoId,
        'contato': contato,
        'descricao': descricao,
        'imagemRefUrl': imagemRefUrl,
        'email': email,
        'adicionais': [for (final a in adicionais) a.toJson()],
      };

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is CommissionDetalhadaModel &&
        other.statusId == statusId &&
        other.tipoProdutoId == tipoProdutoId &&
        other.contato == contato &&
        other.descricao == descricao &&
        other.imagemRefUrl == imagemRefUrl &&
        other.email == email &&
        listEquals(other.adicionais, adicionais);
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        statusId,
        tipoProdutoId,
        contato,
        descricao,
        imagemRefUrl,
        email,
        Object.hashAll(adicionais),
      );

  @override
  String toString() => 'CommissionDetalhadaModel($id, $nomeCliente)';
}
