import '../../Domain/domain.dart';
import 'api_mappers.dart';

/// `GET /relatorios/resumo`: dinheiro em texto vira `double` e as datas
/// `YYYY-MM-DD` (no fuso do Maker) viram `DateTime` de calendário.
RelatorioResumoModel relatorioDeApi(Map<String, dynamic> j) {
  final periodo = mapaDe(j['periodo']);
  final totais = mapaDe(j['totais']);
  return RelatorioResumoModel(
    de: DateTime.parse(periodo['de'] as String),
    ate: DateTime.parse(periodo['ate'] as String),
    pedidos: totais['pedidos'] as int,
    concluidos: totais['concluidos'] as int,
    cancelados: totais['cancelados'] as int,
    emAberto: totais['emAberto'] as int,
    concluidosNoPeriodo: j['concluidosNoPeriodo'] as int,
    receita: dinheiro(j['receita']),
    ticketMedio: dinheiro(j['ticketMedio']),
    porStatus: [
      for (final s in listaDe(j['porStatus']))
        RelatorioPorStatus(
          nome: s['nome'] as String,
          tipo: StatusTipo.fromApi(s['tipo'] as String),
          total: s['total'] as int,
        ),
    ],
    porTipo: [
      for (final t in listaDe(j['porTipoProduto']))
        RelatorioPorTipo(
          nome: t['nome'] as String,
          total: t['total'] as int,
          receita: dinheiro(t['receita']),
        ),
    ],
  );
}
