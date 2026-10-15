import 'package:easy_ui/easy_ui.dart' show AsyncView, Toast;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import 'report_metrics.dart';
import 'report_status_chart.dart';
import 'report_type_chart.dart';

/// Relatório de pedidos: números de destaque, pedidos por tipo (rosca) e
/// por status (barras). Lê o mesmo quadro de commissions da tela de Pedidos.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.repository});

  final CommissionRepository repository;

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<CommissionColumn>>(
      load: () => repository.carregarQuadro(),
      builder: (context, colunas) {
        final pedidos = colunas.expand((c) => c.commissions).toList();
        final feitos = pedidos.where((o) => o.orcamentoFinal != null).length;
        final taxa = pedidos.isEmpty ? 0 : (feitos * 100 / pedidos.length).round();

        final tipo = ReportTypeChart(orders: pedidos);
        final status = ReportStatusChart(
          columns: colunas,
          onPickPeriod: () =>
              Toast.show(context, text: 'Filtro por período em breve.'),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReportMetricGrid(
                items: [
                  ReportMetric(
                    'Pedidos no mês',
                    '${pedidos.length}',
                    Icons.receipt_long_outlined,
                  ),
                  const ReportMetric(
                    'Prazo médio de entrega',
                    '6 dias',
                    Icons.schedule_outlined,
                  ),
                  ReportMetric(
                    'Taxa de conclusão',
                    '$taxa%',
                    Icons.trending_up_rounded,
                  ),
                  const ReportMetric(
                    'Clientes recorrentes',
                    '12',
                    Icons.people_outline_rounded,
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
      },
    );
  }
}
