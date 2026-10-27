import 'package:flutter/widgets.dart';

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';
import 'report_donut.dart';

/// "Pedidos por tipo de arte": rosca à esquerda e legenda com a porcentagem
/// de cada tipo. Os três tipos mais pedidos aparecem; o resto vira "Outros".
class ReportTypeChart extends StatelessWidget {
  const ReportTypeChart({super.key, required this.porTipo});

  final List<RelatorioPorTipo> porTipo;

  int get _total => porTipo.fold(0, (soma, t) => soma + t.total);

  List<MapEntry<String, int>> _contagem() {
    final ordenado = [
      for (final t in porTipo)
        if (t.total > 0) MapEntry(t.nome, t.total),
    ]..sort((a, b) => b.value.compareTo(a.value));
    final topo = ordenado.take(3).toList();
    final outros = ordenado.skip(3).fold<int>(0, (soma, e) => soma + e.value);
    return [...topo, if (outros > 0) MapEntry('Outros', outros)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    final cores = [
      colors.chartPrimary,
      colors.chartSecondary,
      colors.chartTertiary,
      colors.chartQuaternary,
    ];
    final contagem = _contagem();
    final fatias = [
      for (var i = 0; i < contagem.length; i++)
        DonutSlice(contagem[i].value / _total, cores[i]),
    ];
    final legenda = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < contagem.length; i++)
          _Legenda(
            '${contagem[i].key} · ${(contagem[i].value * 100 / _total).round()}%',
            cores[i],
          ),
      ],
    );
    final rosca = CustomPaint(
      size: const Size(150, 150),
      painter: DonutPainter(fatias),
    );

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedidos por tipo de arte',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (_total == 0)
            Text('Ainda não há pedidos.', style: TextStyle(color: colors.muted))
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 340) {
                  return Column(
                    children: [rosca, const SizedBox(height: 8), legenda],
                  );
                }
                return Row(
                  children: [
                    rosca,
                    const SizedBox(width: 8),
                    Expanded(child: legenda),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda(this.texto, this.cor);

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const SizedBox(width: 10, height: 10),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 11, color: SgaColors.of(context).text),
            ),
          ),
        ],
      ),
    );
  }
}
