import 'dart:typed_data';

import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';
import 'product_card.dart';

/// Painel "Meus produtos": grade de cartões com imagem, nome, tipo e Editar.
class ProductCatalog extends StatelessWidget {
  const ProductCatalog({
    super.key,
    required this.products,
    required this.types,
    required this.previews,
    required this.onEdit,
  });

  final List<ProdutoModel> products;
  final List<TipoProdutoModel> types;
  final Map<String, Uint8List> previews;
  final ValueChanged<ProdutoModel> onEdit;

  String _tipoDe(ProdutoModel produto) {
    for (final tipo in types) {
      if (tipo.id == produto.tipoProdutoId) return tipo.nome;
    }
    return 'Tipo indisponível';
  }

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meus produtos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 10),
          if (products.isEmpty)
            Text(
              'Nenhum produto cadastrado.',
              style: TextStyle(color: colors.muted),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 210,
                mainAxisExtent: 190,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) => ProductCard(
                produto: products[i],
                tipo: _tipoDe(products[i]),
                preview: previews[products[i].id],
                onEdit: () => onEdit(products[i]),
              ),
            ),
        ],
      ),
    );
  }
}
