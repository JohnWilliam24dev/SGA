import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/material.dart' as m show Icon;
import 'package:flutter/material.dart' show Chip, IconButton, Icons;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// Painel "Eu faço" / "Eu não faço": título com ícone, lápis para editar a
/// lista e os itens como chips tingidos de verde ou vermelho.
class ScopePanel extends StatelessWidget {
  const ScopePanel({
    super.key,
    required this.does,
    required this.items,
    required this.onEdit,
  });

  final bool does;
  final List<String> items;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    final color = does ? colors.success : colors.negative;
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              m.Icon(
                does ? Icons.check_circle_outline_rounded : Icons.block_rounded,
                color: color,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  does ? 'Eu faço' : 'Eu não faço',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.text,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Editar lista',
                onPressed: onEdit,
                icon: const m.Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text('Nenhum item informado.', style: TextStyle(color: colors.muted))
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final item in items)
                  Chip(
                    label: Text(item),
                    backgroundColor: color.withValues(alpha: .10),
                    side: BorderSide(color: color.withValues(alpha: .25)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
