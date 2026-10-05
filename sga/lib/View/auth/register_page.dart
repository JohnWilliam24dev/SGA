import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/shared.dart';

/// Tela de cadastro: nome, e-mail, senha, confirmação e aceite dos termos.
/// Quando tudo está válido, entrega um [Maker] por [onRegister].
///
/// Só front por enquanto: nada é enviado a servidor.
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
    // O FormGroup só valida os campos de texto; o aceite dos termos é daqui.
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
              variant: ButtonVariant.ghost,
              onPressed: widget.onBack,
            ),
          ),
          const FadeIn(child: SgaLogo(size: 60)),
          FadeIn(
            delay: const Duration(milliseconds: 150),
            child: Card(
              child: Div(
                width: 100.pct,
                children: [
                  const Label(type: LabelType.title, text: 'Cadastre-se'),
                  const Label(
                    type: LabelType.caption,
                    text: 'Crie sua conta para organizar a sua arte.',
                  ),
                  FormGroup(
                    width: 100.pct,
                    children: [
                      InputField(
                        name: 'nome',
                        hint: 'Nome',
                        validation: [
                          isRequired(),
                          minLength(3, message: 'Informe seu nome completo'),
                        ],
                      ),
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
                        validation: [isRequired(), isPassword(min: 8, requireDigit: true)],
                      ),
                      InputField(
                        name: 'confirmar',
                        hint: 'Confirmar senha',
                        type: InputType.password,
                        validation: [
                          isRequired(),
                          sameAs('senha', message: 'As senhas não conferem'),
                        ],
                      ),
                      _termos(),
                      Button(text: 'Criar conta', expanded: true, onSubmit: _enviar),
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
                const Label(type: LabelType.caption, text: 'Já tem conta?'),
                Button(
                  text: 'Entrar',
                  variant: ButtonVariant.ghost,
                  onPressed: widget.onGoToLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _termos() {
    return Div(
      gap: 0.px,
      children: [
        Div(
          direction: LayoutDirection.horizontal,
          align: Alignment.centerLeft,
          gap: 4.px,
          children: [
            Toggle(
              value: _aceitouTermos,
              onChanged: (aceitou) => setState(() {
                _aceitouTermos = aceitou;
                if (aceitou) _termosPendentes = false;
              }),
            ),
            LayoutItem(
              size: 1.fr,
              child: const Label(
                type: LabelType.caption,
                text: 'Li e aceito os Termos de Uso',
              ),
            ),
          ],
        ),
        if (_termosPendentes)
          const Label(
            type: LabelType.error,
            text: 'Você precisa aceitar os termos de uso.',
          ),
      ],
    );
  }
}
