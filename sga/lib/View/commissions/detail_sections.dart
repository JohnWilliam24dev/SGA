import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/widgets/glass/glass_panel.dart';

/// Um bloco do detalhe: painel de vidro na página (celular) e caixa
/// levemente tingida na nota (desktop).
class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    required this.compact,
  });

  final String title;
  final List<Widget> children;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Label(type: LabelType.subtitle, text: title),
        for (final child in children) ...[
          SizedBox(height: compact ? 6 : 10),
          child,
        ],
      ],
    );
    if (!compact) {
      return GlassPanel(padding: const EdgeInsets.all(18), child: content);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x14336E99),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: content),
    );
  }
}
