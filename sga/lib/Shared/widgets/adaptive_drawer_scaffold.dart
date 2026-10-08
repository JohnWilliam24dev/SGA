import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart'
    show AppBar, Drawer, Icons, InkWell, Material, Scaffold, Tooltip;
import 'package:flutter/services.dart' show SystemMouseCursors;
import 'package:flutter/widgets.dart' hide Icon;

import 'sga_logo.dart';
import 'sidebar_toggle_icon.dart';

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
///   principal é empurrado para o lado. A barra pode ser **recolhida** pelo
///   ícone de painel no topo dela e vira uma faixa só de ícones; recolhida, a
///   logo do sistema vira o ícone de "mostrar a barra" ao passar o mouse;
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

  /// Se informado, o cabeçalho ganha o controle de recolher/expandir (só no
  /// desktop).
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: _CollapsedLogoButton(onTap: onToggleCollapse)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Row(
        children: [
          const SgaLogo(size: 40),
          const SizedBox(width: 14),
          const Expanded(
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
          if (onToggleCollapse != null) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: 'Recolher menu',
              child: Material(
                color: const Color(0x00000000),
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onToggleCollapse,
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: SidebarToggleIcon(size: 17),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Barra recolhida: mostra a logo do sistema e, com o mouse por cima, troca
/// pelo ícone de "mostrar a barra lateral". Tocar (ou clicar) expande.
class _CollapsedLogoButton extends StatefulWidget {
  const _CollapsedLogoButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  State<_CollapsedLogoButton> createState() => _CollapsedLogoButtonState();
}

class _CollapsedLogoButtonState extends State<_CollapsedLogoButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);

    return Tooltip(
      message: 'Expandir menu',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _hover
                    ? SizedBox(
                        key: const ValueKey<String>('expandir'),
                        width: 36,
                        height: 36,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: tokens.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SidebarToggleIcon(size: 19, showArrow: true),
                          ),
                        ),
                      )
                    : const SgaLogo(key: ValueKey<String>('logo'), size: 36),
              ),
            ),
          ),
        ),
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
