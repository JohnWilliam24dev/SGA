import 'package:flutter/material.dart';

import '../../../Core/theme/sga_theme.dart';
import 'glass_destination.dart';

class GlassSideItem extends StatelessWidget {
  const GlassSideItem({
    super.key,
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
