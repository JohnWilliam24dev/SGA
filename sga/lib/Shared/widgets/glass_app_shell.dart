import 'dart:ui';

import 'package:flutter/material.dart';

import 'sga_logo.dart';

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
  });

  final List<GlassDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final String title;
  final String subtitle;
  final Widget body;
  final VoidCallback onLogout;

  @override
  State<GlassAppShell> createState() => _GlassAppShellState();
}

class _GlassAppShellState extends State<GlassAppShell> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF249EF5),
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
                      _MobileHeader(title: widget.title),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .84),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: .70)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x240058A8),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
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
                    icon: const Icon(
                      Icons.menu_open_rounded,
                      color: Color(0xFF16354C),
                    ),
                  )
                : Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'MENU',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF31526B),
                          ),
                        ),
                      ),
                      if (onToggle != null)
                        IconButton(
                          tooltip: 'Recolher menu',
                          onPressed: onToggle,
                          icon: const Icon(
                            Icons.menu_open_rounded,
                            color: Color(0xFF16354C),
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
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: const Color(0xFF16354C)),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF16354C),
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
  const _DesktopHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Color(0xFF09243A),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF164765)),
            ),
          ],
        ),
      ),
      GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SgaLogo(size: 30),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sistema de',
                  style: TextStyle(fontSize: 9, color: Color(0xFF16354C)),
                ),
                Text(
                  'Gerenciamento Artístico',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16354C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
    child: Row(
      children: [
        Builder(
          builder: (innerContext) => IconButton(
            onPressed: () => Scaffold.of(innerContext).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF09243A)),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF09243A),
            ),
          ),
        ),
        const SgaLogo(size: 34),
      ],
    ),
  );
}

class _BlueBackdrop extends StatelessWidget {
  const _BlueBackdrop();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BlueBackdropPainter());
}

class _BlueBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .20);
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
