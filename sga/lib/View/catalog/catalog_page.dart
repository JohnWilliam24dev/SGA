import 'package:flutter/material.dart'
    show Material, MaterialType, Tab, TabBar, TabBarView, TabController;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import 'catalog_actions.dart';
import 'catalog_entries.dart';
import 'catalog_list.dart';
import 'catalog_rows.dart';
import 'catalog_seed.dart';

/// Catálogo do Maker: abas Tipos de produtos e Adicionais. Por enquanto os
/// registros vivem em memória, para exercitar os fluxos antes da API.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin, CatalogActions<CatalogPage> {
  late final _tabs = TabController(length: 2, vsync: this);
  @override
  final types = seedTypes();
  @override
  final additionals = seedAdditionals();

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            type: MaterialType.transparency,
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: colors.text,
              unselectedLabelColor: colors.muted,
              indicatorColor: colors.primary,
              indicatorWeight: 3,
              tabs: const [Tab(text: 'Tipos de produtos'), Tab(text: 'Adicionais')],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              CatalogList<CatalogType>(
                title: 'Tipos de produtos',
                description:
                    'Defina o preço base e os adicionais que cada tipo pode oferecer.',
                addLabel: 'Novo tipo',
                items: types,
                emptyTitle: 'Nenhum tipo de produto cadastrado',
                emptyDescription:
                    'Comece criando o primeiro tipo que você oferece.',
                onAdd: editType,
                onEdit: editType,
                onRemove: removeType,
                rowBuilder: (item) => TypeRow(
                  item: item,
                  onEnabled: (v) => setState(
                    () => item.model = typeWithEnabled(item.model, v),
                  ),
                ),
              ),
              CatalogList<CatalogAdditional>(
                title: 'Adicionais',
                description:
                    'Crie extras cobrados por valor fixo ou porcentagem do preço base.',
                addLabel: 'Novo adicional',
                items: additionals,
                emptyTitle: 'Nenhum adicional cadastrado',
                emptyDescription:
                    'Cadastre extras para vinculá-los aos tipos de produto.',
                onAdd: editAdditional,
                onEdit: editAdditional,
                onRemove: removeAdditional,
                rowBuilder: (item) => AdditionalRow(
                  item: item,
                  onEnabled: (v) => setState(
                    () => item.model = additionalWithEnabled(item.model, v),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
