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
    this.catalogoAdmin,
    this.produtos,
    this.relatorioRepository,
    this.doisFator,
    this.configMaker,
    this.makerRepository,
    this.makerId,
  });

  final CommissionRepository commissionRepository;
  final StatusRepository statusRepository;
  final CatalogoRepository catalogoRepository;

  /// Administração do catálogo; sem ele, a seção usa o catálogo simulado.
  final CatalogoAdminRepository? catalogoAdmin;

  /// Relatório; sem ele, soma os pedidos do repositório de commissions.
  final RelatorioRepository? relatorioRepository;

  /// Gestão do 2FA em Configurações; sem ele, a seção Segurança não aparece.
  final DoisFatorRepository? doisFator;

  /// Modalidade de orçamento (Configurações e novo pedido).
  final ConfigMakerRepository? configMaker;

  /// Portfólio; sem ele, a seção usa o portfólio simulado.
  final ProdutoRepository? produtos;

  /// Perfil do Maker na API (com o [makerId] da sessão); sem ele, o perfil
  /// fica só na tela.
  final MakerRepository? makerRepository;
  final String? makerId;
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
    _carregarMaker();
  }

  /// Traz o nome, os termos e o "faço e não faço" guardados no servidor.
  Future<void> _carregarMaker() async {
    final repo = widget.makerRepository;
    final id = widget.makerId;
    if (repo == null || id == null) return;
    try {
      final remoto = await repo.carregar(id);
      if (!mounted) return;
      setState(() => _maker = _maker.copyWith(
            nome: remoto.nome,
            termosServico: remoto.termosServico,
            faz: remoto.faz,
            naoFaz: remoto.naoFaz,
          ));
    } catch (_) {
      // O perfil é secundário: sem ele, o app abre com os dados da sessão.
    }
  }

  void _ir(String id) => setState(() => _selecionado = id);

  Widget _pagina() {
    return switch (_selecionado) {
      Secao.reports => ReportsPage(
        repository:
            widget.relatorioRepository ??
            FakeRelatorioRepository(widget.commissionRepository),
      ),
      Secao.products => ProductsPage(
        produtos: widget.produtos,
        catalogo: widget.catalogoAdmin,
      ),
      Secao.productTypes => CatalogPage(repository: widget.catalogoAdmin),
      Secao.profile => MakerProfilePage(
        maker: _maker,
        onMakerChanged: (maker) => setState(() => _maker = maker),
        repository: widget.makerRepository,
        makerId: widget.makerId,
      ),
      Secao.settings => SettingsPage(
        doisFator: widget.doisFator,
        config: widget.configMaker,
      ),
      Secao.support => const SupportPage(),
      _ => CommissionsPage(
        repository: widget.commissionRepository,
        statusRepository: widget.statusRepository,
        catalogo: widget.catalogoRepository,
        configMaker: widget.configMaker,
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
