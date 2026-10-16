import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import '../catalog/catalog_page.dart';
import '../commissions/commissions_page.dart';
import '../products/products_page.dart';
import '../profile/maker_profile_page.dart';
import '../reports/reports_page.dart';
import '../settings/settings_page.dart';
import '../support/support_page.dart';
import 'main_nav.dart';

/// Área autenticada do SGA: o shell glass (menu, cabeçalho e fundo azul) e a
/// seção escolhida. As seções recebem repositórios, nunca mocks diretos.
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.commissionRepository,
    required this.statusRepository,
    required this.onOpenCommission,
    required this.onLogout,
    required this.maker,
    this.catalogoRepository = const FakeCatalogoRepository(),
  });

  final CommissionRepository commissionRepository;
  final StatusRepository statusRepository;
  final CatalogoRepository catalogoRepository;
  final void Function(CommissionResumoModel commission, String statusNome)
  onOpenCommission;
  final VoidCallback onLogout;
  final Maker maker;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  String _selecionado = Secao.orders;
  late Maker _maker;

  @override
  void initState() {
    super.initState();
    _maker = widget.maker;
  }

  void _ir(String id) => setState(() => _selecionado = id);

  Widget _pagina() {
    return switch (_selecionado) {
      Secao.reports => ReportsPage(repository: widget.commissionRepository),
      Secao.products => const ProductsPage(),
      Secao.productTypes => const CatalogPage(),
      Secao.profile => MakerProfilePage(
        maker: _maker,
        onMakerChanged: (maker) => setState(() => _maker = maker),
      ),
      Secao.settings => const SettingsPage(),
      Secao.support => const SupportPage(),
      _ => CommissionsPage(
        repository: widget.commissionRepository,
        statusRepository: widget.statusRepository,
        catalogo: widget.catalogoRepository,
        onOpenCommission: widget.onOpenCommission,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassAppShell(
      destinations: destinosDoMenu,
      selectedId: _selecionado,
      onSelect: _ir,
      title: destinoDe(_selecionado).label,
      subtitle: subtituloDe(_selecionado),
      body: _pagina(),
      onLogout: widget.onLogout,
      maker: _maker,
      onOpenProfile: () => _ir(Secao.profile),
      onOpenSettings: () => _ir(Secao.settings),
      onOpenSupport: () => _ir(Secao.support),
    );
  }
}
