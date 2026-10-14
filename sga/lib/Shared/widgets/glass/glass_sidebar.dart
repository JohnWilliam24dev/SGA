import 'package:flutter/material.dart';

import '../../../Core/theme/sga_theme.dart';
import 'glass_destination.dart';
import 'glass_panel.dart';
import 'glass_side_item.dart';

class GlassSidebar extends StatelessWidget {
  const GlassSidebar({
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
            GlassSideItem(
              item: item,
              selected: item.id == selectedId,
              compact: compact,
              onTap: () => onSelect(item.id),
            ),
          const Spacer(),
          GlassSideItem(
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
