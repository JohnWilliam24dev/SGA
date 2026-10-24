import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/shared.dart';

/// Tela de quem entrou com sessão restrita: a conta ainda não tem 2FA e o
/// servidor só libera o resto do app depois de ativá-lo. O fluxo de
/// ativação (QR e códigos de recuperação) entra no lugar desta tela.
class TwoFactorPendingPage extends StatelessWidget {
  const TwoFactorPendingPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Div(
        width: 100.pct,
        align: Alignment.center,
        children: [
          const Reveal(child: SgaLogo(size: 54)),
          Card(
            variant: CardVariant.glass,
            child: Div(
              width: 100.pct,
              children: [
                const Label(
                  type: LabelType.title,
                  text: 'Ative a verificação em duas etapas',
                ),
                const Label(
                  type: LabelType.caption,
                  text: 'Para proteger sua conta, é preciso ativar a verificação '
                      'em duas etapas antes de usar o SGA. Esta etapa chega em breve.',
                ),
                Button(text: 'Sair', expanded: true, onPressed: onLogout),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
