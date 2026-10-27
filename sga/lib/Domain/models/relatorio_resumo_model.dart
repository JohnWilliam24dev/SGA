import 'package:flutter/foundation.dart' show immutable;

import 'status_model.dart';

/// Pedidos de uma coluna do quadro no período (status ATUAL do pedido).
@immutable
class RelatorioPorStatus {
  const RelatorioPorStatus({
    required this.nome,
    required this.tipo,
    required this.total,
  });

  final String nome;
  final StatusTipo tipo;
  final int total;
}

/// Pedidos de um tipo de produto: `total` na base de pedidos criados no
/// período e `receita` na base de pedidos concluídos nele.
@immutable
class RelatorioPorTipo {
  const RelatorioPorTipo({
    required this.nome,
    required this.total,
    required this.receita,
  });

  final String nome;
  final int total;
  final double receita;
}

/// Resumo do período (`GET /relatorios/resumo`). Tem duas bases de tempo,
/// de propósito: [pedidos], [concluidos], [cancelados], [emAberto], [porStatus]
/// e `RelatorioPorTipo.total` contam pedidos CRIADOS no período;
/// [receita], [ticketMedio] e `RelatorioPorTipo.receita` contam pedidos
/// CONCLUÍDOS no período ([concluidosNoPeriodo]).
@immutable
class RelatorioResumoModel {
  const RelatorioResumoModel({
    required this.de,
    required this.ate,
    required this.pedidos,
    required this.concluidos,
    required this.cancelados,
    required this.emAberto,
    required this.concluidosNoPeriodo,
    required this.receita,
    required this.ticketMedio,
    required this.porStatus,
    required this.porTipo,
  });

  final DateTime de;
  final DateTime ate;
  final int pedidos;
  final int concluidos;
  final int cancelados;
  final int emAberto;
  final int concluidosNoPeriodo;
  final double receita;
  final double ticketMedio;
  final List<RelatorioPorStatus> porStatus;
  final List<RelatorioPorTipo> porTipo;

  /// Dos pedidos criados no período, a fatia que já foi concluída.
  double get taxaConclusao => pedidos == 0 ? 0 : concluidos / pedidos;
}
