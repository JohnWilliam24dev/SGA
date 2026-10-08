import 'package:flutter/foundation.dart' show immutable;

/// Extra que o cliente pode somar ao pedido (ex.: "Fundo detalhado").
/// Cobra um valor fixo ([precoFixo]), um percentual sobre o preço
/// ([porcentagem]) ou nenhum dos dois; a API decide qual vem preenchido.
@immutable
class AdicionalModel {
  const AdicionalModel({
    required this.id,
    required this.nome,
    this.descricao,
    this.precoFixo,
    this.porcentagem,
    required this.habilitado,
  });

  factory AdicionalModel.fromJson(Map<String, dynamic> json) {
    return AdicionalModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      precoFixo: (json['precoFixo'] as num?)?.toDouble(),
      porcentagem: (json['porcentagem'] as num?)?.toDouble(),
      habilitado: json['habilitado'] as bool,
    );
  }

  final String id;
  final String nome;
  final String? descricao;
  final double? precoFixo;
  final double? porcentagem;
  final bool habilitado;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'precoFixo': precoFixo,
        'porcentagem': porcentagem,
        'habilitado': habilitado,
      };

  @override
  bool operator ==(Object other) {
    return other is AdicionalModel &&
        other.id == id &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.precoFixo == precoFixo &&
        other.porcentagem == porcentagem &&
        other.habilitado == habilitado;
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, descricao, precoFixo, porcentagem, habilitado);

  @override
  String toString() => 'AdicionalModel($id, $nome)';
}
