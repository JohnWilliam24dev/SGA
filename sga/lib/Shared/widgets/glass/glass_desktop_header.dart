import 'package:flutter/material.dart';

import '../../../Domain/maker.dart';
import '../../../Core/theme/sga_theme.dart';
import 'glass_panel.dart';
import 'maker_avatar.dart';
import 'maker_menu_action.dart';

class GlassDesktopHeader extends StatelessWidget {
  const GlassDesktopHeader({
    super.key,
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
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: SgaColors.of(context).onBackdropMuted,
              ),
            ),
          ],
        ),
      ),
      PopupMenuButton<MakerMenuAction>(
        tooltip: 'Menu do perfil',
        offset: const Offset(0, 48),
        constraints: const BoxConstraints(minWidth: 150, maxWidth: 170),
        menuPadding: const EdgeInsets.symmetric(vertical: 4),
        onSelected: (action) {
          if (action == MakerMenuAction.profile) onOpenProfile();
          if (action == MakerMenuAction.settings) onOpenSettings();
          if (action == MakerMenuAction.support) onOpenSupport();
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: MakerMenuAction.profile, child: Text('Perfil')),
          PopupMenuItem(
            value: MakerMenuAction.settings,
            child: Text('Configurações'),
          ),
          PopupMenuItem(
            value: MakerMenuAction.support,
            child: Text('Suporte'),
          ),
        ],
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MakerAvatar(maker: maker, size: 30),
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
