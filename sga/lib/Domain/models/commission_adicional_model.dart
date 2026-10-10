import 'package:flutter/foundation.dart' show immutable;

/// Um adicional escolhido dentro de uma commission: quantos, o que o cliente
/// pediu em texto livre e o valor unitário cobrado na hora.
@immutable
class CommissionAdicionalModel {
  const CommissionAdicionalModel({
    required this.adicionalId,
    required this.nome,
    required this.quantidade,
    required this.descricaoCliente,
    required this.valorUnitario,
  });

  factory CommissionAdicionalModel.fromJson(Map<String, dynamic> json) {
    return CommissionAdicionalModel(
      adicionalId: json['adicionalId'] as String,
      nome: json['nome'] as String,
      quantidade: json['quantidade'] as int,
      descricaoCliente: json['descricaoCliente'] as String?,
      valorUnitario: (json['valorUnitario'] as num).toDouble(),
    );
  }

  final String adicionalId;
  final String nome;
  final int quantidade;
  final String? descricaoCliente;
  final double valorUnitario;

  /// Quanto esse adicional soma no pedido.
  double get subtotal => valorUnitario * quantidade;

  Map<String, dynamic> toJson() => {
        'adicionalId': adicionalId,
        'nome': nome,
        'quantidade': quantidade,
        'descricaoCliente': descricaoCliente,
        'valorUnitario': valorUnitario,
      };

  @override
  bool operator ==(Object other) {
    return other is CommissionAdicionalModel &&
        other.adicionalId == adicionalId &&
        other.nome == nome &&
        other.quantidade == quantidade &&
        other.descricaoCliente == descricaoCliente &&
        other.valorUnitario == valorUnitario;
  }

  @override
  int get hashCode => Object.hash(
        adicionalId,
        nome,
        quantidade,
        descricaoCliente,
        valorUnitario,
      );

  @override
  String toString() => 'CommissionAdicionalModel($nome x$quantidade)';
}
