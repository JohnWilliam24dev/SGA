import 'package:flutter/foundation.dart' show immutable;

/// Item do portfólio do artista, ligado a um tipo de produto.
@immutable
class ProdutoModel {
  const ProdutoModel({
    required this.id,
    required this.nome,
    required this.imagemUrl,
    required this.tipoProdutoId,
    this.descricao,
  });

  factory ProdutoModel.fromJson(Map<String, dynamic> json) {
    return ProdutoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      imagemUrl: json['imagemUrl'] as String,
      tipoProdutoId: json['tipoProdutoId'] as String,
      descricao: json['descricao'] as String?,
    );
  }

  final String id;
  final String nome;
  final String imagemUrl;
  final String tipoProdutoId;
  final String? descricao;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'imagemUrl': imagemUrl,
        'tipoProdutoId': tipoProdutoId,
        'descricao': descricao,
      };

  @override
  bool operator ==(Object other) {
    return other is ProdutoModel &&
        other.id == id &&
        other.nome == nome &&
        other.imagemUrl == imagemUrl &&
        other.tipoProdutoId == tipoProdutoId &&
        other.descricao == descricao;
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, imagemUrl, tipoProdutoId, descricao);

  @override
  String toString() => 'ProdutoModel($id, $nome)';
}
