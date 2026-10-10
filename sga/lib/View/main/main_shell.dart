import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import '../commissions/commissions_page.dart';
import '../catalog/catalog_page.dart';
import '../dashboard/dashboard_pages.dart';
import '../profile/maker_profile_page.dart';
import '../settings/settings_page.dart';
import '../support/support_page.dart';

/// Área autenticada do SGA. As seções consomem contratos de dados, nunca os
/// mocks diretamente: a troca por API poderá acontecer por repositório.
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
  static const String _finance = 'finance';
  static const String _reports = 'reports';
  static const String _products = 'products';
  static const String _productTypes = 'product-types';
  static const String _profile = 'profile';
  static const String _settings = 'settings';
  static const String _support = 'support';

  static const List<GlassDestination> _destinos = [
    GlassDestination(_orders, 'Pedidos', Icons.view_kanban_outlined),
    GlassDestination(
      _finance,
      'Financeiro',
      Icons.account_balance_wallet_outlined,
    ),
    GlassDestination(
      _reports,
      'Relatório de pedidos',
      Icons.pie_chart_outline_rounded,
    ),
    GlassDestination(_products, 'Produtos', Icons.inventory_2_outlined),
    GlassDestination(
      _productTypes,
      'Tipos de produtos',
      Icons.category_outlined,
    ),
  ];

  String _selecionado = _orders;
  late Maker _maker;

  @override
  void initState() {
    super.initState();
    _maker = widget.maker;
  }

  Widget _pagina() {
    switch (_selecionado) {
      case _finance:
        return FinanceiroPage(repository: widget.commissionRepository);
      case _reports:
        return RelatoriosPage(repository: widget.commissionRepository);
      case _products:
        return const ProdutosPage();
      case _productTypes:
        return const CatalogPage();
      case _profile:
        return MakerProfilePage(
          maker: _maker,
          onMakerChanged: (maker) => setState(() => _maker = maker),
        );
      case _settings:
        return SettingsPage(statusRepository: widget.statusRepository);
      case _support:
        return const SupportPage();
      case _orders:
      default:
        return CommissionsPage(
          repository: widget.commissionRepository,
          onOpenCommission: widget.onOpenCommission,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destino = switch (_selecionado) {
      _profile => const GlassDestination(
        _profile,
        'Perfil',
        Icons.person_outline,
      ),
      _settings => const GlassDestination(
        _settings,
        'Configurações',
        Icons.settings_outlined,
      ),
      _support => const GlassDestination(
        _support,
        'Suporte',
        Icons.support_agent_outlined,
      ),
      _ => _destinos.firstWhere((d) => d.id == _selecionado),
    };
    final subtitle = switch (_selecionado) {
      _orders => 'Acompanhe cada pedido por etapa, do orçamento até a entrega.',
      _finance => 'Receitas, valores a receber e movimentações do mês.',
      _reports => 'Veja como seus pedidos se distribuem por tipo e status.',
      _products =>
        'Cadastre o que você vende e mantenha o catálogo atualizado.',
      _productTypes =>
        'Defina os tipos de produto e os adicionais disponíveis para pedidos.',
      _profile => 'Mantenha sua apresentação, regras de trabalho e termos sempre atualizados.',
      _settings => 'Personalize a aparência e as colunas do seu quadro de pedidos.',
      _support => 'Encontre ajuda sempre que precisar.',
      _ => '',
    };

    return GlassAppShell(
      destinations: _destinos,
      selectedId: _selecionado,
      onSelect: (id) => setState(() => _selecionado = id),
      title: destino.label,
      subtitle: subtitle,
      body: _pagina(),
      onLogout: widget.onLogout,
      maker: _maker,
      onOpenProfile: () => setState(() => _selecionado = _profile),
      onOpenSettings: () => setState(() => _selecionado = _settings),
      onOpenSupport: () => setState(() => _selecionado = _support),
    );
  }
}
