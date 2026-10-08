import 'package:flutter/foundation.dart' show immutable;

/// Categoria de produto que o artista oferece (ex.: "Ilustração"), com o
/// preço base usado na simulação de valor.
@immutable
class TipoProdutoModel {
  const TipoProdutoModel({
    required this.id,
    required this.nome,
    required this.precoBase,
    required this.habilitado,
  });

  factory TipoProdutoModel.fromJson(Map<String, dynamic> json) {
    return TipoProdutoModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      precoBase: (json['precoBase'] as num).toDouble(),
      habilitado: json['habilitado'] as bool,
    );
  }

  final String id;
  final String nome;
  final double precoBase;
  final bool habilitado;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'precoBase': precoBase,
        'habilitado': habilitado,
      };

  @override
  bool operator ==(Object other) {
    return other is TipoProdutoModel &&
        other.id == id &&
        other.nome == nome &&
        other.precoBase == precoBase &&
        other.habilitado == habilitado;
  }

  @override
  int get hashCode => Object.hash(id, nome, precoBase, habilitado);

  @override
  String toString() => 'TipoProdutoModel($id, $nome)';
}
