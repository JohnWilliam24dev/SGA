import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import '../commissions/commissions_page.dart';
import '../catalog/catalog_page.dart';
import '../profile/maker_profile_page.dart';
import '../products/products_page.dart';
import '../reports/reports_page.dart';
import '../settings/settings_page.dart';
import '../support/support_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.commissionRepository,
    required this.statusRepository,
    required this.onOpenCommission,
    required this.onLogout,
    required this.maker,
  });

  final CommissionRepository commissionRepository;
  final StatusRepository statusRepository;
  final void Function(CommissionResumoModel commission, String statusNome)
  onOpenCommission;
  final VoidCallback onLogout;
  final Maker maker;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const String _orders = 'orders';
  static const String _reports = 'reports';
  static const String _products = 'products';
  static const String _productTypes = 'product-types';
  static const String _profile = 'profile';
  static const String _settings = 'settings';
  static const String _support = 'support';

  String _selecionado = _orders;
  late Maker _maker;

  @override
  void initState() {
    super.initState();
    _maker = widget.maker;
  }

  Widget _pagina() {
    switch (_selecionado) {
      case _reports:
        return ReportsPage(repository: widget.commissionRepository);
      case _products:
        return const ProductsPage();
      case _productTypes:
        return const CatalogPage();
      case _profile:
        return MakerProfilePage(
          maker: _maker,
          onMakerChanged: (maker) => setState(() => _maker = maker),
        );
      case _settings:
        return const SettingsPage();
      case _support:
        return const SupportPage();
      case _orders:
      default:
        return CommissionsPage(
          repository: widget.commissionRepository,
          statusRepository: widget.statusRepository,
          onOpenCommission: widget.onOpenCommission,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      brand: const SgaLogo(size: 32),
      destinations: [
        const NavDestination(
          id: _orders,
          label: 'Pedidos',
          icon: Icons.view_kanban_outlined,
          description: 'Acompanhe cada pedido por etapa.',
        ),
        const NavDestination(
          id: _reports,
          label: 'Relatório',
          icon: Icons.pie_chart_outline_rounded,
          description: 'Veja a distribuição dos seus pedidos.',
        ),
        const NavDestination(
          id: _products,
          label: 'Produtos',
          icon: Icons.inventory_2_outlined,
          description: 'Cadastre o que você vende.',
        ),
        const NavDestination(
          id: _productTypes,
          label: 'Catálogo',
          icon: Icons.category_outlined,
          description: 'Defina tipos e adicionais.',
        ),
      ],
      selectedId: _selecionado,
      onSelect: (id) => setState(() => _selecionado = id),
      profileMenu: Menu(
        onSelected: (id) {
          if (id == 'logout') {
            widget.onLogout();
          } else {
            setState(() => _selecionado = id);
          }
        },
        child: Avatar(initials: _maker.inicial, diameter: 32),
        items: [
          const MenuItem(
            id: _profile,
            text: 'Meu Perfil',
            icon: Icons.person_outline,
          ),
          const MenuItem(
            id: _settings,
            text: 'Configurações',
            icon: Icons.settings_outlined,
          ),
          const MenuItem(
            id: _support,
            text: 'Suporte',
            icon: Icons.support_agent_outlined,
          ),
          const MenuDivider(),
          const MenuItem(
            id: 'logout',
            text: 'Sair',
            icon: Icons.logout_rounded,
          ),
        ],
      ),
      child: _pagina(),
    );
  }
}
