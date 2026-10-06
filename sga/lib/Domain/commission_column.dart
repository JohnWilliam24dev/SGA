import 'package:flutter/foundation.dart' show immutable;

import 'commission.dart';

/// Uma coluna do quadro de commissions (ex.: "Em produção").
///
/// As colunas não são fixas: vêm de uma lista, então o quadro pode ter
/// quantas etapas o ateliê precisar.
@immutable
class CommissionColumn {
  const CommissionColumn({
    required this.id,
    required this.titulo,
    this.commissions = const <Commission>[],
  });

  final String id;
  final String titulo;
  final List<Commission> commissions;

  CommissionColumn copyWith({List<Commission>? commissions}) {
    return CommissionColumn(
      id: id,
      titulo: titulo,
      commissions: commissions ?? this.commissions,
    );
  }

  @override
  String toString() => 'CommissionColumn($id, ${commissions.length} commissions)';
}
