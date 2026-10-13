import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/shared.dart';

/// Tela inicial do SGA: marca, pulso animado e as duas portas de entrada,
/// Cadastre-se e Login. Não conhece as próximas telas: avisa por callbacks.
class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onRegister,
    required this.onLogin,
  });

  final VoidCallback onRegister;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Div(
        width: 100.pct,
        align: Alignment.center,
        gap: 14.px,
        children: [
          const Reveal(child: SgaLogo()),
          const Reveal(
            delay: Duration(milliseconds: 150),
            child: Label(
              type: LabelType.title,
              text: 'SGA',
              textAlign: TextAlign.center,
            ),
          ),
          const Reveal(
            delay: Duration(milliseconds: 250),
            child: Label(
              text: 'Sistema de Gerenciamento Artístico',
              textAlign: TextAlign.center,
            ),
          ),
          const Reveal(
            delay: Duration(milliseconds: 350),
            child: PulseLine(),
          ),
          const Reveal(
            delay: Duration(milliseconds: 600),
            child: Label(
              type: LabelType.caption,
              text: 'Sua arte, sua agenda e seus clientes em um só lugar.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Reveal(
            delay: const Duration(milliseconds: 750),
            child: Div(
              width: 100.pct,
              gap: 12.px,
              children: [
                Button(
                  'Cadastre-se',
                  expanded: true,
                  onPressed: onRegister,
                ),
                Button(
                  'Login',
                  variant: ButtonVariant.link,
                  onPressed: onLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
