import 'package:flutter/material.dart';

import '../../../Domain/maker.dart';
import '../../../Core/theme/sga_theme.dart';
import 'maker_avatar.dart';
import 'maker_menu_action.dart';

class GlassMobileHeader extends StatelessWidget {
  const GlassMobileHeader({
    super.key,
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
        PopupMenuButton<MakerMenuAction>(
          tooltip: 'Menu do perfil',
          offset: const Offset(0, 44),
          constraints: const BoxConstraints(minWidth: 150, maxWidth: 170),
          menuPadding: const EdgeInsets.symmetric(vertical: 4),
          onSelected: (action) {
            if (action == MakerMenuAction.profile) onOpenProfile();
            if (action == MakerMenuAction.settings) onOpenSettings();
            if (action == MakerMenuAction.support) onOpenSupport();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: MakerMenuAction.profile,
              child: Text('Perfil'),
            ),
            PopupMenuItem(
              value: MakerMenuAction.settings,
              child: Text('Configurações'),
            ),
            PopupMenuItem(
              value: MakerMenuAction.support,
              child: Text('Suporte'),
            ),
          ],
          child: MakerAvatar(maker: maker, size: 34),
        ),
      ],
    ),
  );
}
