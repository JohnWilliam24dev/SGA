import 'package:easy_ui/easy_ui.dart' show Breakpoints, ScreenSize;
import 'package:flutter/material.dart' show Icon;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// Um número de destaque do relatório: ícone, rótulo e valor.
class ReportMetric {
  const ReportMetric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

/// Os números de destaque em painéis de vidro: 4 em linha no desktop, 2 por
/// linha no celular.
class ReportMetricGrid extends StatelessWidget {
  const ReportMetricGrid({super.key, required this.items});

  final List<ReportMetric> items;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            Breakpoints.standard.sizeFor(constraints.maxWidth) ==
            ScreenSize.mobile;
        final columns = mobile ? 2 : 4;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: GlassPanel(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, size: 17, color: colors.icon),
                      const SizedBox(height: 10),
                      Text(
                        item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.heading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
