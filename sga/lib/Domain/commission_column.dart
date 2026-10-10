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
  });

  final String id;
  final String titulo;
  final StatusTipo tipo;
  final int ordem;
  final List<CommissionResumoModel> commissions;

  CommissionColumn copyWith({List<CommissionResumoModel>? commissions}) {
    return CommissionColumn(
      id: id,
      titulo: titulo,
      tipo: tipo,
      ordem: ordem,
      commissions: commissions ?? this.commissions,
    );
  }

  @override
  String toString() => 'CommissionColumn($id, ${commissions.length} commissions)';
}
