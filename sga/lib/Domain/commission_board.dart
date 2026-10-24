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
  String? origemId;
  final restantes = <CommissionColumn>[];

  for (final coluna in colunas) {
    final indice = coluna.commissions.indexWhere((c) => c.id == commissionId);
    if (indice == -1) {
      restantes.add(coluna);
      continue;
    }
    movida = coluna.commissions[indice];
    origemId = coluna.id;
    restantes.add(
      coluna.copyWith(
        commissions: [...coluna.commissions]..removeAt(indice),
        // Mudando de coluna, o total da origem diminui (ver abaixo o destino).
        total: coluna.id == paraColunaId ? null : _somar(coluna.total, -1),
      ),
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
          total: origemId == paraColunaId ? null : _somar(coluna.total, 1),
        )
      else
        coluna,
  ];
}

/// Soma [delta] ao total de uma coluna paginada (`null` fica `null`).
int? _somar(int? total, int delta) => total == null ? null : total + delta;

/// Move a coluna [columnId] para a posição [paraIndice] do quadro e renumera
/// a `ordem` de todas de 1 em diante.
///
/// [paraIndice] conta a partir da lista **já sem** a coluna movida (0 é o
/// início). Se a coluna não existir, devolve [colunas] sem alterações.
List<CommissionColumn> moverColuna(
  List<CommissionColumn> colunas, {
  required String columnId,
  required int paraIndice,
}) {
  final de = colunas.indexWhere((c) => c.id == columnId);
  if (de == -1) return colunas;

  final novas = [...colunas];
  final coluna = novas.removeAt(de);
  novas.insert(paraIndice.clamp(0, novas.length).toInt(), coluna);
  return [
    for (var i = 0; i < novas.length; i++) novas[i].copyWith(ordem: i + 1),
  ];
}
