import 'package:easy_ui/easy_ui.dart' show Breakpoints, Button, ButtonVariant, ScreenSize;
import 'package:flutter/material.dart' show Icon, IconButton, Icons;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';

/// Uma linha do catálogo: o conteúdo ([content]) e os botões Editar e
/// Excluir. Em tela estreita os botões descem para baixo do conteúdo.
class CatalogItem extends StatelessWidget {
  const CatalogItem({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onRemove,
  });

  final Widget content;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.input,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile =
              Breakpoints.standard.sizeFor(constraints.maxWidth) ==
              ScreenSize.mobile;
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Editar',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Excluir',
                onPressed: onRemove,
                color: colors.error,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          );
          if (mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(children: [Expanded(child: content), actions]);
        },
      ),
    );
  }
}

/// Estado vazio de uma lista, com o botão de cadastrar.
class EmptyCatalog extends StatelessWidget {
  const EmptyCatalog({
    super.key,
    required this.title,
    required this.description,
    required this.onCreate,
  });

  final String title;
  final String description;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 42, color: colors.icon),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w800, color: colors.text),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.muted),
            ),
            const SizedBox(height: 16),
            Button(
              text: 'Cadastrar agora',
              variant: ButtonVariant.outline,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}
