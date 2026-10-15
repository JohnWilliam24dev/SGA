import 'package:easy_ui/easy_ui.dart'
    show Breakpoints, Button, ScreenSize;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Shared/widgets/glass/glass_panel.dart';
import 'catalog_item.dart';

/// Painel de uma aba: título, descrição, botão de adicionar e as linhas (ou o
/// estado vazio). Genérico no tipo do item.
class CatalogList<T> extends StatelessWidget {
  const CatalogList({
    super.key,
    required this.title,
    required this.description,
    required this.addLabel,
    required this.items,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.rowBuilder,
  });

  final String title;
  final String description;
  final String addLabel;
  final String emptyTitle;
  final String emptyDescription;
  final List<T> items;
  final VoidCallback onAdd;
  final ValueChanged<T> onEdit;
  final ValueChanged<T> onRemove;
  final Widget Function(T) rowBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 18),
            if (items.isEmpty)
              EmptyCatalog(
                title: emptyTitle,
                description: emptyDescription,
                onCreate: onAdd,
              )
            else
              for (final item in items)
                CatalogItem(
                  content: rowBuilder(item),
                  onEdit: () => onEdit(item),
                  onRemove: () => onRemove(item),
                ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = SgaColors.of(context);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.heading,
          ),
        ),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 13, color: colors.muted)),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            Breakpoints.standard.sizeFor(constraints.maxWidth) ==
            ScreenSize.mobile;
        final action = Button(
          text: addLabel,
          icon: Icons.add_rounded,
          expanded: mobile,
          onPressed: onAdd,
        );
        if (mobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info, const SizedBox(height: 14), action],
          );
        }
        return Row(children: [Expanded(child: info), action]);
      },
    );
  }
}
