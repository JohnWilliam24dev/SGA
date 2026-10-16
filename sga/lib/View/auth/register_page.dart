import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';
import 'register_fields.dart';
import 'terms_toggle.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    required this.onRegister,
    required this.onGoToLogin,
    required this.onBack,
  });

  final ValueChanged<Maker> onRegister;
  final VoidCallback onGoToLogin;
  final VoidCallback onBack;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _aceitouTermos = false;
  bool _termosPendentes = false;

  void _enviar(FormValues values) {
    if (!_aceitouTermos) {
      setState(() => _termosPendentes = true);
      return;
    }
    widget.onRegister(
      Maker(
        nome: values['nome']!.trim(),
        email: values['email']!.trim(),
        senha: values['senha']!,
        aceitouTermos: true,
      ),
    );
  }

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
                  const Label(type: LabelType.title, text: 'Crie sua conta'),
                  const Label(
                    type: LabelType.caption,
                    text: 'Crie sua conta para organizar a sua arte.',
                  ),
                  FormGroup(
                    width: 100.pct,
                    children: [
                      ...registerFields(),
                      TermsToggle(
                        accepted: _aceitouTermos,
                        pending: _termosPendentes,
                        onChanged: (aceitou) => setState(() {
                          _aceitouTermos = aceitou;
                          if (aceitou) _termosPendentes = false;
                        }),
                      ),
                      Button(
                        text: 'Criar conta',
                        expanded: true,
                        onSubmit: _enviar,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Reveal(
            delay: const Duration(milliseconds: 300),
            child: Div(
              align: Alignment.center,
              gap: 0.px,
              children: [
                const Label(type: LabelType.caption, text: 'Já tem conta?'),
                Button(
                  text: 'Entrar',
                  variant: ButtonVariant.link,
                  onPressed: widget.onGoToLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
