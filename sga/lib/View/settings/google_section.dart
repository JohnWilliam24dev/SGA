import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/erros.dart';

/// Conta Google: vincula a conta Google à conta atual, para entrar pelos dois
/// caminhos. [onVincular] devolve `false` quando a pessoa desiste.
class GoogleSection extends StatelessWidget {
  const GoogleSection({super.key, required this.onVincular});

  final Future<bool> Function() onVincular;

  Future<void> _vincular(BuildContext context) async {
    try {
      final vinculou = await onVincular();
      if (vinculou && context.mounted) {
        Toast.show(context, text: 'Conta Google vinculada.', type: ToastType.success);
      }
    } catch (e) {
      if (context.mounted) {
        Toast.error(
          context,
          text: mensagemDeErro(e, 'Não foi possível vincular a conta Google.'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Div(
      width: 100.pct,
      children: [
        const Label(type: LabelType.title, text: 'Conta Google'),
        const Label(
          type: LabelType.caption,
          text: 'Vincule sua conta Google para também poder entrar com ela.',
        ),
        Button(
          text: 'Vincular conta Google',
          variant: ButtonVariant.outline,
          onPressed: () => _vincular(context),
        ),
      ],
    );
  }
}
