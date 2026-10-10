import 'dart:ui';

import 'package:flutter/material.dart';

import '../../Domain/maker.dart';
import '../../Core/theme/sga_theme.dart';

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
          const Positioned.fill(child: _BlueBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                if (compact) {
                  return Column(
                    children: [
                      _MobileHeader(
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
                              _GlassSidebar(
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
                            _DesktopHeader(
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
        child: _GlassSidebar(
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

class GlassDestination {
  const GlassDestination(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.panel.withValues(alpha: .90),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.panelBorder.withValues(alpha: .70),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x240058A8),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class _GlassSidebar extends StatelessWidget {
  const _GlassSidebar({
    required this.destinations,
    required this.selectedId,
    required this.onSelect,
    required this.onLogout,
    this.compact = false,
    this.onToggle,
  });
  final List<GlassDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onLogout;
  final bool compact;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: GlassPanel(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 18),
            child: compact
                ? IconButton(
                    tooltip: 'Expandir menu',
                    onPressed: onToggle,
                    icon: Icon(
                      Icons.menu_open_rounded,
                      color: SgaColors.of(context).text,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MENU',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            color: sgaMuted,
                          ),
                        ),
                      ),
                      if (onToggle != null)
                        IconButton(
                          tooltip: 'Recolher menu',
                          onPressed: onToggle,
                          icon: Icon(
                            Icons.menu_open_rounded,
                            color: sgaOnSurface,
                          ),
                        ),
                    ],
                  ),
          ),
          for (final item in destinations)
            _SideItem(
              item: item,
              selected: item.id == selectedId,
              compact: compact,
              onTap: () => onSelect(item.id),
            ),
          const Spacer(),
          _SideItem(
            item: const GlassDestination(
              'logout',
              'Sair',
              Icons.logout_rounded,
            ),
            selected: false,
            compact: compact,
            onTap: onLogout,
          ),
        ],
      ),
    ),
  );
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.item,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });
  final GlassDestination item;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Tooltip(
      message: compact ? item.label : '',
      child: Material(
        color: selected
            ? SgaColors.of(context).selectedNavigation
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: sgaOnSurface),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sgaOnSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.title,
    required this.subtitle,
    required this.maker,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onOpenSupport,
  });
  final String title;
  final String subtitle;
  final Maker maker;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSupport;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 25,
                height: 1,
                fontWeight: FontWeight.w800,
                color: sgaHeading,
              ),
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: TextStyle(fontSize: 12, color: sgaMuted)),
          ],
        ),
      ),
      PopupMenuButton<_MakerMenuAction>(
        tooltip: 'Menu do perfil',
        offset: const Offset(0, 48),
        constraints: const BoxConstraints(minWidth: 150, maxWidth: 170),
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        onSelected: (action) {
          if (action == _MakerMenuAction.profile) onOpenProfile();
          if (action == _MakerMenuAction.settings) onOpenSettings();
          if (action == _MakerMenuAction.support) onOpenSupport();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: _MakerMenuAction.profile, child: Text('Perfil')),
          PopupMenuItem(
            value: _MakerMenuAction.settings,
            child: Text('Configurações'),
          ),
          PopupMenuItem(
            value: _MakerMenuAction.support,
            child: Text('Suporte'),
          ),
        ],
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MakerAvatar(maker: maker, size: 30),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maker.nomeExibicao,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: sgaOnSurface,
                    ),
                  ),
                  Text(
                    'Meu perfil',
                    style: TextStyle(fontSize: 9, color: sgaMuted),
                  ),
                ],
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: sgaMuted,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

enum _MakerMenuAction { profile, settings, support }

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({
    required this.title,
    required this.maker,
    required this.onOpenProfile,
    required this.onOpenSettings,
    required this.onOpenSupport,
  });
  final String title;
  final Maker maker;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSupport;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
    child: Row(
      children: [
        Builder(
          builder: (innerContext) => IconButton(
            onPressed: () => Scaffold.of(innerContext).openDrawer(),
            icon: Icon(Icons.menu_rounded, color: sgaHeading),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: sgaHeading,
            ),
          ),
        ),
        PopupMenuButton<_MakerMenuAction>(
          tooltip: 'Menu do perfil',
          offset: const Offset(0, 44),
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 170),
          menuPadding: const EdgeInsets.symmetric(vertical: 4),
          onSelected: (action) {
            if (action == _MakerMenuAction.profile) onOpenProfile();
            if (action == _MakerMenuAction.settings) onOpenSettings();
            if (action == _MakerMenuAction.support) onOpenSupport();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _MakerMenuAction.profile,
              child: Text('Perfil'),
            ),
            PopupMenuItem(
              value: _MakerMenuAction.settings,
              child: Text('Configurações'),
            ),
            PopupMenuItem(
              value: _MakerMenuAction.support,
              child: Text('Suporte'),
            ),
          ],
          child: _MakerAvatar(maker: maker, size: 34),
        ),
      ],
    ),
  );
}

class _MakerAvatar extends StatelessWidget {
  const _MakerAvatar({required this.maker, required this.size});
  final Maker maker;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: SgaColors.of(context).avatar,
      shape: BoxShape.circle,
    ),
    child: Text(
      maker.inicial,
      style: TextStyle(
        fontSize: size * .42,
        fontWeight: FontWeight.w800,
        color: SgaColors.of(context).onPrimary,
      ),
    ),
  );
}

class _BlueBackdrop extends StatelessWidget {
  const _BlueBackdrop();
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BlueBackdropPainter(
      dark: Theme.of(context).brightness == Brightness.dark,
    ),
  );
}

class _BlueBackdropPainter extends CustomPainter {
  const _BlueBackdropPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (dark ? const Color(0xFF168DEE) : Colors.white).withValues(
        alpha: .20,
      );
    canvas.drawCircle(Offset(-20, size.height * .96), size.width * .23, paint);
    canvas.drawCircle(
      Offset(size.width * .89, size.height * .44),
      size.width * .18,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * .56, -40),
      size.width * .17,
      Paint()..color = Colors.white.withValues(alpha: .08),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
