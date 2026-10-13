import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.repository});

  final CommissionRepository repository;

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      load: () => repository.carregarQuadro(),
      builder: (context, colunas) {
        final orders = colunas.expand((c) => c.commissions).toList();
        final completed = orders.where((o) => o.orcamentoFinal != null).length;

        return Div(
          fill: true,
          scrollable: true,
          children: [
            StatGrid(
              items: [
                Stat(
                  label: 'Pedidos no mês',
                  value: orders.length.toString(),
                  icon: Icons.receipt_long_outlined,
                ),
                const Stat(
                  label: 'Prazo médio',
                  value: '6 dias',
                  icon: Icons.schedule_outlined,
                ),
                Stat(
                  label: 'Taxa de conclusão',
                  value: formatPercent(completed, total: orders.length),
                  icon: Icons.trending_up_rounded,
                ),
                const Stat(
                  label: 'Clientes recorrentes',
                  value: '12',
                  icon: Icons.people_outline_rounded,
                ),
              ],
            ),
            Responsive(
              mobile: Div(
                children: [
                  _TypeChart(orders: orders),
                  _StatusChart(orders: orders),
                ],
              ),
              desktop: Div(
                direction: LayoutDirection.horizontal,
                children: [
                  LayoutItem(size: 1.fr, child: _TypeChart(orders: orders)),
                  LayoutItem(size: 1.fr, child: _StatusChart(orders: orders)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TypeChart extends StatelessWidget {
  const _TypeChart({required this.orders});
  final List<CommissionResumoModel> orders;

  @override
  Widget build(BuildContext context) {
    final types = <String, int>{};
    for (final order in orders) {
      types.update(order.tipoProdutoNome, (v) => v + 1, ifAbsent: () => 1);
    }

    return Card(
      child: Div(
        children: [
          const Label(type: LabelType.title, text: 'Pedidos por tipo'),
          if (orders.isEmpty)
            const EmptyState(label: 'Ainda não há pedidos.')
          else
            for (final entry in types.entries)
              _ProgressRow(
                label: entry.key,
                value: entry.value / orders.length,
                amount: entry.value,
              ),
        ],
      ),
    );
  }
}

class _StatusChart extends StatelessWidget {
  const _StatusChart({required this.orders});
  final List<CommissionResumoModel> orders;

  @override
  Widget build(BuildContext context) {
    final completed = orders.where((o) => o.orcamentoFinal != null).length;
    final open = orders.length - completed;

    return Card(
      child: Div(
        children: [
          const Label(type: LabelType.title, text: 'Pedidos por status'),
          if (orders.isEmpty)
            const EmptyState(label: 'Ainda não há pedidos.')
          else ...[
            _ProgressRow(
              label: 'Em aberto',
              value: open / orders.length,
              amount: open,
            ),
            _ProgressRow(
              label: 'Com orçamento',
              value: completed / orders.length,
              amount: completed,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.amount,
  });
  final String label;
  final double value;
  final int amount;

  @override
  Widget build(BuildContext context) => Div(
        gap: 4.px,
        children: [
          Label(text: '$label · $amount', type: LabelType.caption),
          ProgressBar(value: value),
        ],
      );
}
