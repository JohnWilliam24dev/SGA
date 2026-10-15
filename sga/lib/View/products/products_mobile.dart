import 'package:flutter/material.dart' show Icon, Icons, InkWell;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// Telas de Produtos no celular: primeiro um menu com as duas ações; cada
/// uma abre numa seção própria, com seta para voltar.
enum ProductsMobileView { menu, form, catalog }

class ProductsMobileMenu extends StatelessWidget {
  const ProductsMobileMenu({
    super.key,
    required this.onAddProduct,
    required this.onMyProducts,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onMyProducts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'O que você gostaria de fazer?',
            style: TextStyle(fontSize: 13, color: SgaColors.of(context).muted),
          ),
          const SizedBox(height: 16),
          _AcaoCard(
            title: 'Adicionar Produto',
            description: 'Cadastre um novo item para o seu portfólio.',
            icon: Icons.add_box_outlined,
            onTap: onAddProduct,
          ),
          const SizedBox(height: 12),
          _AcaoCard(
            title: 'Meus produtos',
            description: 'Veja e gerencie os produtos já cadastrados.',
            icon: Icons.inventory_2_outlined,
            onTap: onMyProducts,
          ),
        ],
      ),
    );
  }
}

class _AcaoCard extends StatelessWidget {
  const _AcaoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: GlassPanel(
          child: Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0x1A168BF1),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(icon, color: colors.chartPrimary),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: colors.muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.chartPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
