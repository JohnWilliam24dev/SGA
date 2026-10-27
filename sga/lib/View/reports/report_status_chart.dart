import 'package:easy_ui/easy_ui.dart' show Button, ButtonVariant;
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter/widgets.dart';

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// "Pedidos por status": uma barra de progresso por coluna do quadro, com a
/// fatia dos pedidos do período que está em cada uma.
class ReportStatusChart extends StatelessWidget {
  const ReportStatusChart({
    super.key,
    required this.itens,
    required this.periodo,
    required this.onPickPeriod,
  });

  final List<RelatorioPorStatus> itens;

  /// Nome do período mostrado no botão; tocar nele troca o período.
  final String periodo;
  final VoidCallback onPickPeriod;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    final total = itens.fold<int>(0, (soma, s) => soma + s.total);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedidos por status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 13),
          if (total == 0)
            Text('Ainda não há pedidos.', style: TextStyle(color: colors.muted))
          else
            for (final item in itens)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.nome,
                            style: TextStyle(fontSize: 11, color: colors.text),
                          ),
                        ),
                        Text(
                          '${item.total}',
                          style: TextStyle(fontSize: 11, color: colors.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: item.total / total,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: const Color(0x66FFFFFF),
                      valueColor: AlwaysStoppedAnimation(colors.chartPrimary),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Button(
              text: periodo,
              variant: ButtonVariant.outline,
              onPressed: onPickPeriod,
            ),
          ),
        ],
      ),
    );
  }
}
