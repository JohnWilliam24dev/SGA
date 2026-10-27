import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'commission_edicoes.dart';
import 'commission_regra_exception.dart';
import 'models/models.dart';

/// Reabrir orçamento no repositório simulado. No simulado, "fechado" é ter
/// `orcamentoFinal` (a mesma leitura que o app faz da API).
mixin CommissionReabertura on ChangeNotifier, CommissionEdicoes {
  Future<bool> orcamentoReabrivel(String commissionId) async {
    final d = detalhes[commissionId];
    if (d == null || d.orcamentoFinal == null) return false;
    final statusId = statusIdDe(commissionId);
    for (final s in await statusRepository.listar()) {
      if (s.id != statusId) continue;
      return s.tipo != StatusTipo.concluido && s.tipo != StatusTipo.cancelado;
    }
    return true;
  }

  Future<void> reabrirOrcamento(String commissionId) async {
    await Future<void>.delayed(latencia);
    final d = detalhes[commissionId];
    if (d == null) throw StateError('Commission $commissionId não encontrada');
    if (!await orcamentoReabrivel(commissionId)) {
      throw const CommissionRegraException(
        'O orçamento já está aberto ou o pedido foi encerrado.',
      );
    }
    atualizar(d.copyWith(limparOrcamento: true));
    notifyListeners();
  }
}
