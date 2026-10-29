import 'dart:async';

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
    this.onGoogle,
  });

  /// Pode ser assíncrono: o botão mostra o carregamento até terminar e
  /// exibe a mensagem de uma `UserFacingException` lançada daqui.
  final FutureOr<void> Function(Credenciais) onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onGoToRegister;
  final VoidCallback onBack;

  /// Entrar com a conta Google; sem ele, o botão não aparece. Quem chama
  /// cuida dos próprios avisos de erro.
  final Future<void> Function()? onGoogle;

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
              onPressed: onBack,
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
                      InputField(
                        name: 'email',
                        hint: 'E-mail',
                        type: InputType.email,
                        validation: [isRequired(), isEmail()],
                      ),
                      InputField(
                        name: 'senha',
                        hint: 'Senha',
                        type: InputType.password,
                        validation: [isRequired(), maxLength(128)],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Button(
              text: 'Esqueci a senha',
              variant: ButtonVariant.link,
              onPressed: onForgotPassword,
            ),
                      ),
                      Button(
                        text: 'Entrar',
                        expanded: true,
                        onSubmit: (values) => onLogin(
                          Credenciais(
                            email: values['email']!.trim(),
                            senha: values['senha']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (onGoogle != null) ...[
                    const Label(type: LabelType.caption, text: 'ou'),
                    Button(
                      text: 'Entrar com Google',
                      variant: ButtonVariant.outline,
                      expanded: true,
                      onPressed: () => unawaited(onGoogle!()),
                    ),
                  ],
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
                Button(
              text: 'Cadastre-se',
              variant: ButtonVariant.link,
              onPressed: onGoToRegister,
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
