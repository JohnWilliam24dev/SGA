import 'dart:async';

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/shared.dart';

/// Segundo passo do login de quem tem 2FA: o código de 6 dígitos do
/// aplicativo autenticador ou, se o celular não estiver à mão, um código de
/// recuperação.
class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key, required this.onSubmit, required this.onBack});

  /// Recebe o código digitado e se ele é de recuperação.
  final FutureOr<void> Function(String codigo, bool recuperacao) onSubmit;
  final VoidCallback onBack;

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  bool _recuperacao = false;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Div(
        width: 100.pct,
        align: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Button(
              text: 'Voltar',
              variant: ButtonVariant.link,
              onPressed: widget.onBack,
            ),
          ),
          const Reveal(child: SgaLogo(size: 54)),
          Reveal(
            delay: const Duration(milliseconds: 150),
            child: Card(
              variant: CardVariant.glass,
              child: Div(
                width: 100.pct,
                children: [
                  const Label(
                    type: LabelType.title,
                    text: 'Verificação em duas etapas',
                  ),
                  Label(
                    type: LabelType.caption,
                    text: _recuperacao
                        ? 'Digite um dos seus códigos de recuperação.'
                        : 'Digite o código de 6 dígitos do seu aplicativo autenticador.',
                  ),
                  FormGroup(
                    width: 100.pct,
                    children: [
                      InputField(
                        key: ValueKey(_recuperacao),
                        name: 'codigo',
                        hint: _recuperacao ? 'Código de recuperação' : 'Código de 6 dígitos',
                        autofocus: true,
                        validation: [
                          isRequired(),
                          if (!_recuperacao)
                            matches(RegExp(r'^\d{6}$'), message: 'Digite os 6 dígitos'),
                        ],
                      ),
                      Button(
                        text: 'Confirmar',
                        expanded: true,
                        onSubmit: (values) =>
                            widget.onSubmit(values['codigo']!.trim(), _recuperacao),
                      ),
                      Button(
                        text: _recuperacao
                            ? 'Usar o código do aplicativo'
                            : 'Usar um código de recuperação',
                        variant: ButtonVariant.link,
                        onPressed: () => setState(() => _recuperacao = !_recuperacao),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
