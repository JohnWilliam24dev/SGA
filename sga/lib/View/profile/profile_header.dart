import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' as m show Icon;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Core/theme/sga_theme.dart';
import '../../Domain/domain.dart';
import '../../Shared/widgets/glass/glass_panel.dart';

/// Título de seção da tela de perfil ("Como você trabalha", ...).
class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: SgaColors.of(context).heading,
      ),
    );
  }
}

/// Cartão do topo: avatar, nome, e-mail e o botão "Editar perfil". Em tela
/// estreita ([narrow]) o botão desce para baixo das informações.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.maker,
    required this.narrow,
    required this.onEdit,
  });

  final Maker maker;
  final bool narrow;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = SgaColors.of(context);
    final avatar = Avatar(
      initials: maker.inicial,
      diameter: 68,
      color: (_) => colors.avatar,
    );
    final edit = Button(
      text: 'Editar perfil',
      icon: Icons.edit_outlined,
      onPressed: onEdit,
    );
    final info = _info(colors);

    return GlassPanel(
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    avatar,
                    const SizedBox(width: 14),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 16),
                edit,
              ],
            )
          : Row(
              children: [
                avatar,
                const SizedBox(width: 18),
                Expanded(child: info),
                edit,
              ],
            ),
    );
  }

  Widget _info(SgaColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          maker.nomeExibicao,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.heading,
          ),
        ),
        if (maker.email.isNotEmpty) ...[
          const SizedBox(height: 8),
          _contato(colors, Icons.email_outlined, maker.email),
        ],
      ],
    );
  }

  Widget _contato(SgaColors colors, IconData icon, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        m.Icon(icon, size: 16, color: colors.avatar),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            texto,
            style: TextStyle(fontSize: 12, color: colors.muted),
          ),
        ),
      ],
    );
  }
}
