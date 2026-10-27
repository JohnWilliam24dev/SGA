import 'package:easy_ui/easy_ui.dart' show AsyncView;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/formatters.dart';
import 'periodo_relatorio.dart';
import 'report_metrics.dart';
import 'report_status_chart.dart';
import 'report_type_chart.dart';

/// Relatório de pedidos: números de destaque, pedidos por tipo (rosca) e
/// por status (barras). Os números vêm prontos do servidor, por período.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.repository});

  final RelatorioRepository repository;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  PeriodoRelatorio _periodo = PeriodoRelatorio.esteMes;

  Future<RelatorioResumoModel> _carregar() {
    final i = _periodo.intervalo(DateTime.now());
    return widget.repository.carregarResumo(de: i.de, ate: i.ate);
  }

  @override
  Widget build(BuildContext context) {
    // A chave força nova busca quando o período muda.
    return KeyedSubtree(
      key: ValueKey(_periodo),
      child: AsyncView<RelatorioResumoModel>(
        load: _carregar,
        builder: (context, resumo) => _conteudo(resumo),
      ),
    );
  }

  Widget _conteudo(RelatorioResumoModel r) {
    final tipo = ReportTypeChart(porTipo: r.porTipo);
    final status = ReportStatusChart(
      itens: r.porStatus,
      periodo: _periodo.rotulo,
      onPickPeriod: () => setState(() => _periodo = _periodo.proximo),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReportMetricGrid(
            items: [
              ReportMetric(
                'Pedidos no período',
                '${r.pedidos}',
                Icons.receipt_long_outlined,
              ),
              ReportMetric(
                'Taxa de conclusão',
                '${(r.taxaConclusao * 100).round()}%',
                Icons.trending_up_rounded,
              ),
              ReportMetric(
                'Receita',
                formatarMoeda(r.receita),
                Icons.payments_outlined,
              ),
              ReportMetric(
                'Ticket médio',
                formatarMoeda(r.ticketMedio),
                Icons.sell_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 780) {
                return Column(
                  children: [tipo, const SizedBox(height: 14), status],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: tipo),
                  const SizedBox(width: 14),
                  Expanded(child: status),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
