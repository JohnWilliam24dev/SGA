import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show TextButton;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';

/// Tela de login: e-mail, senha e o link "Esqueci a senha" (ainda sem
/// função). Sem estado: o `FormGroup` cuida dos campos e o botão de envio
/// valida tudo. Entrega os dados por [onLogin].
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
            child: TextButton(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF063C68),
              ),
              child: const Text('Voltar'),
            ),
          ),
          const FadeIn(child: SgaLogo(size: 54)),
          FadeIn(
            delay: const Duration(milliseconds: 150),
            child: GlassPanel(
              padding: const EdgeInsets.all(24),
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
                        validation: [isRequired()],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF075A9F),
                          ),
                          child: const Text('Esqueci a senha'),
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
                ],
              ),
            ),
          ),
          FadeIn(
            delay: const Duration(milliseconds: 300),
            child: Div(
              align: Alignment.center,
              gap: 0.px,
              children: [
                const Label(
                  type: LabelType.caption,
                  text: 'Ainda não tem conta?',
                ),
                TextButton(
                  onPressed: onGoToRegister,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF053A68),
                  ),
                  child: const Text('Cadastre-se'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
