import 'package:flutter/foundation.dart' show immutable;

import 'models/commission_resumo_model.dart';

/// Uma coluna do quadro de commissions (ex.: "Em produção").
///
/// As colunas não são fixas: vêm de uma lista, então o quadro pode ter
/// quantas etapas o ateliê precisar.
@immutable
class CommissionColumn {
  const CommissionColumn({
    required this.id,
    required this.titulo,
    this.commissions = const <CommissionResumoModel>[],
  });

  final String id;
  final String titulo;
  final List<CommissionResumoModel> commissions;

  CommissionColumn copyWith({List<CommissionResumoModel>? commissions}) {
    return CommissionColumn(
      id: id,
      titulo: titulo,
      commissions: commissions ?? this.commissions,
    );
  }

  @override
  String toString() => 'CommissionColumn($id, ${commissions.length} commissions)';
}
