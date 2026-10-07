import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart'
    show AppBar, Drawer, Icons, InkWell, Material, Scaffold, Tooltip;
import 'package:flutter/widgets.dart' hide Icon;

import 'sga_logo.dart';

/// Um destino da navegação lateral.
class NavDestination {
  const NavDestination({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

/// Estrutura do app autenticado, com a navegação lateral responsiva:
///
/// - **tablet/desktop:** a navegação vira uma barra lateral fixa e o conteúdo
///   principal é empurrado para o lado. A barra pode ser **recolhida** (vira
///   uma faixa só de ícones, com dica ao passar o mouse) pelo botão do
///   rodapé dela;
/// - **celular:** a navegação fica num drawer, aberto pelo botão do menu na
///   barra de cima; ao abrir, o fundo escurece.
class AdaptiveDrawerScaffold extends StatefulWidget {
  const AdaptiveDrawerScaffold({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.title,
    required this.body,
    this.onLogout,
    this.initiallyCollapsed = false,
  });

  final List<NavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;

  /// Título da área atual (barra de cima no celular, cabeçalho no desktop).
  final String title;
  final Widget body;

  /// Se informado, aparece o item "Sair" no rodapé da navegação.
  final VoidCallback? onLogout;

  /// Se a barra lateral (tablet/desktop) começa recolhida.
  final bool initiallyCollapsed;

  static const double sidebarWidth = 264;
  static const double collapsedWidth = 72;

  @override
  State<AdaptiveDrawerScaffold> createState() => _AdaptiveDrawerScaffoldState();
}

class _AdaptiveDrawerScaffoldState extends State<AdaptiveDrawerScaffold> {
  late bool _collapsed = widget.initiallyCollapsed;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            Breakpoints.standard.sizeFor(constraints.maxWidth) == ScreenSize.mobile;

        if (mobile) {
          return Scaffold(
            backgroundColor: tokens.backgroundColor,
            appBar: AppBar(
              backgroundColor: tokens.surfaceColor,
              foregroundColor: tokens.textColor,
              surfaceTintColor: const Color(0x00000000),
              scrolledUnderElevation: 0,
              elevation: 0,
              shape: Border(bottom: BorderSide(color: tokens.borderColor)),
              title: _BarTitle(widget.title),
            ),
            drawer: Drawer(
              width: 288,
              backgroundColor: tokens.surfaceColor,
              child: SafeArea(
                child: Builder(
                  builder: (drawerContext) => _NavPanel(
                    destinations: widget.destinations,
                    selectedId: widget.selectedId,
                    onLogout: widget.onLogout,
                    onSelect: (id) {
                      Scaffold.of(drawerContext).closeDrawer();
                      widget.onSelect(id);
                    },
                  ),
                ),
              ),
            ),
            body: SafeArea(top: false, child: widget.body),
          );
        }

        return Scaffold(
          backgroundColor: tokens.backgroundColor,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: _collapsed
                      ? AdaptiveDrawerScaffold.collapsedWidth
                      : AdaptiveDrawerScaffold.sidebarWidth,
                  decoration: BoxDecoration(
                    color: tokens.surfaceColor,
                    border: Border(right: BorderSide(color: tokens.borderColor)),
                  ),
                  // Escolhe o desenho pela largura real (e não pelo estado),
                  // para nada estourar enquanto a barra anima.
                  child: LayoutBuilder(
                    builder: (context, box) => _NavPanel(
                      destinations: widget.destinations,
                      selectedId: widget.selectedId,
                      onSelect: widget.onSelect,
                      onLogout: widget.onLogout,
                      compact: box.maxWidth < 150,
                      onToggleCollapse: () =>
                          setState(() => _collapsed = !_collapsed),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: tokens.surfaceColor,
                          border: Border(
                            bottom: BorderSide(color: tokens.borderColor),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          child: _BarTitle(widget.title),
                        ),
                      ),
                      Expanded(child: widget.body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Título discreto das barras de cima (celular e desktop).
class _BarTitle extends StatelessWidget {
  const _BarTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: tokens.textColor,
        fontSize: tokens.baseFontSize * 1.15,
        fontWeight: FontWeight.w600,
        fontFamily: tokens.fontFamily,
      ),
    );
  }
}

/// Conteúdo da navegação: marca no topo, destinos e, no rodapé, o "Sair" e o
/// botão de recolher. Em modo [compact] mostra só os ícones.
class _NavPanel extends StatelessWidget {
  const _NavPanel({
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.onLogout,
    this.compact = false,
    this.onToggleCollapse,
  });

  final List<NavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback? onLogout;
  final bool compact;

  /// Se informado, aparece o botão de recolher/expandir (só no desktop).
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final destination in destinations)
                _NavTile(
                  icon: destination.icon,
                  label: destination.label,
                  selected: destination.id == selectedId,
                  compact: compact,
                  onTap: () => onSelect(destination.id),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onLogout != null)
                _NavTile(
                  icon: Icons.logout,
                  label: 'Sair',
                  selected: false,
                  compact: compact,
                  onTap: onLogout!,
                ),
              if (onToggleCollapse != null)
                _NavTile(
                  icon: compact ? Icons.chevron_right : Icons.chevron_left,
                  label: compact ? 'Expandir menu' : 'Recolher menu',
                  selected: false,
                  compact: compact,
                  onTap: onToggleCollapse!,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    if (compact) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: SgaLogo(size: 36)),
      );
    }
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          SgaLogo(size: 40),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label(type: LabelType.subtitle, text: 'SGA'),
                Label(
                  type: LabelType.caption,
                  text: 'Gerenciamento Artístico',
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);

    final glyph = Icon(
      icon,
      color: (t) => selected ? t.primaryColor : t.mutedTextColor,
    );
    final content = compact
        ? SizedBox(height: 48, child: Center(child: glyph))
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                glyph,
                const SizedBox(width: 14),
                Expanded(child: Label(text: label, maxLines: 1)),
              ],
            ),
          );

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? tokens.primaryColor.withValues(alpha: 0.12)
            : const Color(0x00000000),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: content),
      ),
    );

    // Sem o texto, a dica ao passar o mouse diz o que cada ícone faz.
    return compact ? Tooltip(message: label, child: tile) : tile;
  }
}
