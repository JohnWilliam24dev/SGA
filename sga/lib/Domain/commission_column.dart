import 'package:flutter/foundation.dart' show immutable;

import 'models/commission_resumo_model.dart';
import 'models/status_model.dart';

/// Uma coluna do quadro de commissions (ex.: "Em andamento"): um status do
/// Maker com os resumos que estão nele.
///
/// As colunas não são fixas: vêm do repositório de status, então o quadro pode
/// ter quantas etapas o ateliê precisar. O [tipo] é o que dá significado à
/// coluna para o sistema; o [titulo] é livre.
@immutable
class CommissionColumn {
  const CommissionColumn({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.ordem,
    this.commissions = const <CommissionResumoModel>[],
    this.total,
    this.temMais = false,
  });

  final String id;
  final String titulo;
  final StatusTipo tipo;
  final int ordem;
  final List<CommissionResumoModel> commissions;

  /// Quantos pedidos a coluna tem no total, quando só parte deles foi
  /// carregada (a API traz 50 por vez). `null` = todos já estão em
  /// [commissions].
  final int? total;

  /// Se ainda há pedidos para carregar nesta coluna.
  final bool temMais;

  /// O número que o selo da coluna mostra.
  int get quantidade => total ?? commissions.length;

  /// Quantos pedidos faltam carregar.
  int get restantes => (quantidade - commissions.length).clamp(0, quantidade);

  CommissionColumn copyWith({
    List<CommissionResumoModel>? commissions,
    int? ordem,
    int? total,
    bool? temMais,
  }) {
    return CommissionColumn(
      id: id,
      titulo: titulo,
      tipo: tipo,
      ordem: ordem ?? this.ordem,
      commissions: commissions ?? this.commissions,
      total: total ?? this.total,
      temMais: temMais ?? this.temMais,
    );
  }

  @override
  String toString() => 'CommissionColumn($id, ${commissions.length} commissions)';
}
