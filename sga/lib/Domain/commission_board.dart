import 'models/commission_resumo_model.dart';
import 'commission_column.dart';

/// Move uma commission para [paraColunaId], na posição [paraIndice].
///
/// [paraIndice] conta a partir da lista de destino **já sem** a commission
/// movida (vale também ao reordenar dentro da mesma coluna). Se a commission
/// ou a coluna não existirem, devolve [colunas] sem alterações.
List<CommissionColumn> moverCommission(
  List<CommissionColumn> colunas, {
  required String commissionId,
  required String paraColunaId,
  required int paraIndice,
}) {
  CommissionResumoModel? movida;
  final restantes = <CommissionColumn>[];

  for (final coluna in colunas) {
    final indice = coluna.commissions.indexWhere((c) => c.id == commissionId);
    if (indice == -1) {
      restantes.add(coluna);
      continue;
    }
    movida = coluna.commissions[indice];
    restantes.add(
      coluna.copyWith(commissions: [...coluna.commissions]..removeAt(indice)),
    );
  }

  if (movida == null || !restantes.any((c) => c.id == paraColunaId)) {
    return colunas;
  }

  return [
    for (final coluna in restantes)
      if (coluna.id == paraColunaId)
        coluna.copyWith(
          commissions: [...coluna.commissions]..insert(
              paraIndice.clamp(0, coluna.commissions.length).toInt(),
              movida,
            ),
        )
      else
        coluna,
  ];
}
