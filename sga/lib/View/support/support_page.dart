import 'package:flutter/material.dart';

import '../../Shared/widgets/glass_app_shell.dart';
import '../../Core/theme/sga_theme.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: SgaColors.of(context).avatar,
              child: Icon(
                Icons.support_agent_rounded,
                color: SgaColors.of(context).onPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Como podemos ajudar?',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: sgaHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Se você tiver qualquer problema com a plataforma, fale com a gente pelo WhatsApp ou peça ajuda no grupo do Discord. Vamos te orientar por lá.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.45, color: sgaMuted),
            ),
          ],
        ),
      ),
    ),
  );
}
