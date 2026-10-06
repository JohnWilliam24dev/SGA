import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart'
    show AppBar, Drawer, Icons, InkWell, Material, Scaffold;
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
///   principal é empurrado para o lado;
/// - **celular:** a navegação fica num drawer, aberto pelo botão do menu na
///   barra de cima; ao abrir, o fundo escurece.
class AdaptiveDrawerScaffold extends StatelessWidget {
  const AdaptiveDrawerScaffold({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.title,
    required this.body,
    this.onLogout,
  });

  final List<NavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;

  /// Título da área atual (barra de cima no celular, cabeçalho no desktop).
  final String title;
  final Widget body;

  /// Se informado, aparece o item "Sair" no rodapé da navegação.
  final VoidCallback? onLogout;

  static const double sidebarWidth = 264;

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
              title: Label(type: LabelType.subtitle, text: title),
            ),
            drawer: Drawer(
              width: 288,
              backgroundColor: tokens.surfaceColor,
              child: SafeArea(
                child: Builder(
                  builder: (drawerContext) => _NavPanel(
                    destinations: destinations,
                    selectedId: selectedId,
                    onLogout: onLogout,
                    onSelect: (id) {
                      Scaffold.of(drawerContext).closeDrawer();
                      onSelect(id);
                    },
                  ),
                ),
              ),
            ),
            body: SafeArea(top: false, child: body),
          );
        }

        return Scaffold(
          backgroundColor: tokens.backgroundColor,
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.surfaceColor,
                      border: Border(right: BorderSide(color: tokens.borderColor)),
                    ),
                    child: _NavPanel(
                      destinations: destinations,
                      selectedId: selectedId,
                      onSelect: onSelect,
                      onLogout: onLogout,
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
                            vertical: 16,
                          ),
                          child: Label(type: LabelType.title, text: title),
                        ),
                      ),
                      Expanded(child: body),
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

/// Conteúdo da navegação: marca no topo, destinos e o "Sair" no rodapé.
class _NavPanel extends StatelessWidget {
  const _NavPanel({
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.onLogout,
  });

  final List<NavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final destination in destinations)
                _NavTile(
                  icon: destination.icon,
                  label: destination.label,
                  selected: destination.id == selectedId,
                  onTap: () => onSelect(destination.id),
                ),
            ],
          ),
        ),
        if (onLogout != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: _NavTile(
              icon: Icons.logout,
              label: 'Sair',
              selected: false,
              onTap: onLogout!,
            ),
          ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeScope.tokensOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? tokens.primaryColor.withValues(alpha: 0.12)
            : const Color(0x00000000),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: (t) => selected ? t.primaryColor : t.mutedTextColor,
                ),
                const SizedBox(width: 14),
                Expanded(child: Label(text: label, maxLines: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
