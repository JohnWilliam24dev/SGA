import 'package:flutter/material.dart';

import '../../../Domain/maker.dart';
import '../../../Core/theme/sga_theme.dart';
import 'blue_backdrop.dart';
import 'glass_desktop_header.dart';
import 'glass_destination.dart';
import 'glass_mobile_header.dart';
import 'glass_sidebar.dart';

/// Moldura compartilhada das telas internas. Mantém a navegação e o conteúdo
/// separados para que cada área possa continuar recebendo seu próprio
/// repositório quando a API substituir os mocks.
class GlassAppShell extends StatefulWidget {
  const GlassAppShell({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.onLogout,
    required this.maker,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onOpenSupport,
  });

  final List<GlassDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final String title;
  final String subtitle;
  final Widget body;
  final VoidCallback onLogout;
  final Maker maker;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSupport;

  @override
  State<GlassAppShell> createState() => _GlassAppShellState();
}

class _GlassAppShellState extends State<GlassAppShell> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: BlueBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                if (compact) {
                  return Column(
                    children: [
                      GlassMobileHeader(
                        title: widget.title,
                        maker: widget.maker,
                        onOpenProfile: widget.onOpenProfile,
                        onOpenSettings: widget.onOpenSettings,
                        onOpenSupport: widget.onOpenSupport,
                      ),
                      Expanded(child: widget.body),
                    ],
                  );
                }
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: _collapsed ? 68 : 210,
                        child: LayoutBuilder(
                          builder: (context, sidebarConstraints) =>
                              GlassSidebar(
                                destinations: widget.destinations,
                                selectedId: widget.selectedId,
                                onSelect: widget.onSelect,
                                onLogout: widget.onLogout,
                                // A animação passa por larguras intermediárias.
                                // O conteúdo só expande quando há espaço real.
                                compact: sidebarConstraints.maxWidth < 150,
                                onToggle: () =>
                                    setState(() => _collapsed = !_collapsed),
                              ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 16, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GlassDesktopHeader(
                              title: widget.title,
                              subtitle: widget.subtitle,
                              maker: widget.maker,
                              onOpenProfile: widget.onOpenProfile,
                              onOpenSettings: widget.onOpenSettings,
                              onOpenSupport: widget.onOpenSupport,
                            ),
                            const SizedBox(height: 14),
                            Expanded(child: widget.body),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: GlassSidebar(
          destinations: widget.destinations,
          selectedId: widget.selectedId,
          onSelect: (id) {
            Navigator.of(context).pop();
            widget.onSelect(id);
          },
          onLogout: widget.onLogout,
        ),
      ),
    );
  }
}
