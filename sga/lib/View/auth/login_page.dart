import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onGoToRegister,
    required this.onBack,
  });

  final ValueChanged<Credenciais> onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoToRegister;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Div(
        width: 100.pct,
        align: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Button.link(
              onPressed: onBack,
              child: const Label(text: 'Voltar'),
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
                  const Label(type: LabelType.title, text: 'Acesse sua conta'),
                  const Label(
                    type: LabelType.caption,
                    text: 'Acesse sua conta para continuar.',
                  ),
                  FormGroup(
                    width: 100.pct,
                    children: [
                      const InputField(
                        name: 'email',
                        hint: 'E-mail',
                        type: InputType.email,
                        validation: [isRequired(), isEmail()],
                      ),
                      const InputField(
                        name: 'senha',
                        hint: 'Senha',
                        type: InputType.password,
                        validation: [isRequired()],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Button.link(
                          onPressed: onForgotPassword,
                          child: const Label(text: 'Esqueci a senha'),
                        ),
                      ),
                      Button(
                        expanded: true,
                        onSubmit: (values) => onLogin(
                          Credenciais(
                            email: values['email']!.trim(),
                            senha: values['senha']!,
                          ),
                        ),
                        child: const Label(text: 'Entrar'),
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
                const Label(
                  type: LabelType.caption,
                  text: 'Ainda não tem conta?',
                ),
                Button.link(
                  onPressed: onGoToRegister,
                  child: const Label(text: 'Cadastre-se'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
