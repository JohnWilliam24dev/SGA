import 'package:easy_ui/easy_ui.dart' show ErrorState, Loader;
import 'package:flutter/material.dart'
    show Material, MaterialType, Tab, TabBar, TabBarView, TabController;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import 'catalog_actions.dart';
import 'catalog_entries.dart';
import 'catalog_list.dart';
import 'catalog_rows.dart';

/// Catálogo do Maker: abas Tipos de produtos e Adicionais, lidos e gravados
/// pelo [CatalogoAdminRepository]. Sem [repository], usa o catálogo simulado.
class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.repository});

  final CatalogoAdminRepository? repository;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin, CatalogActions<CatalogPage> {
  late final _tabs = TabController(length: 2, vsync: this);
  @override
  late final CatalogoAdminRepository repo =
      widget.repository ?? FakeCatalogoAdminRepository();
  @override
  List<CatalogType> types = [];
  @override
  List<CatalogAdditional> additionals = [];
  bool _carregando = true;
  String? _falha;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _falha = null;
    });
    final falha = await recarregar();
    if (mounted) {
      setState(() {
        _carregando = false;
        _falha = falha;
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Loader(message: 'Carregando catálogo...');
    if (_falha != null) {
      return ErrorState(description: _falha, onRetry: _carregar);
    }
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
                  onEnabled: (v) => alternarTipo(item, v),
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
                  onEnabled: (v) => alternarAdicional(item, v),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
