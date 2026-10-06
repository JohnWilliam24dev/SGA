import 'package:flutter/foundation.dart' show immutable;

/// Um pedido de arte (commission): quem pediu e o que foi pedido.
@immutable
class Commission {
  const Commission({
    required this.id,
    required this.cliente,
    required this.descricao,
  });

  final String id;
  final String cliente;
  final String descricao;

  @override
  bool operator ==(Object other) {
    return other is Commission &&
        other.id == id &&
        other.cliente == cliente &&
        other.descricao == descricao;
  }

  @override
  int get hashCode => Object.hash(id, cliente, descricao);

  @override
  String toString() => 'Commission($id, $cliente)';
}
