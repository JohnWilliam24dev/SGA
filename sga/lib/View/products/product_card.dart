import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' show Button, ButtonVariant;
import 'package:flutter/material.dart' show Icon, Icons;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';

/// Cartão de um produto na grade: imagem (ou ícone), nome, tipo e Editar.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.produto,
    required this.tipo,
    required this.preview,
    required this.onEdit,
  });

  final ProdutoModel produto;
  final String tipo;
  final Uint8List? preview;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.input,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                height: 72,
                width: double.infinity,
                child: preview != null
                    ? Image.memory(preview!, fit: BoxFit.cover)
                    : produto.imagemUrl.isEmpty
                        ? _Vazio(colors)
                        : Image.network(
                            produto.imagemUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _Vazio(colors),
                          ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              produto.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            const Spacer(),
            Text(
              tipo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Button(
              text: 'Editar',
              variant: ButtonVariant.outline,
              expanded: true,
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Imagem de reserva: gradiente com ícone, para produto sem foto ou foto que
/// não carregou.
class _Vazio extends StatelessWidget {
  const _Vazio(this.colors);

  final SgaColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.chartTertiary, colors.chartSecondary]),
      ),
      child: Center(child: Icon(Icons.inventory_2_outlined, color: colors.text)),
    );
  }
}
