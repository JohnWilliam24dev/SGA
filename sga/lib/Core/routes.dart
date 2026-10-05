import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart' hide Icon;

import '../View/auth/login_page.dart';
import '../View/auth/register_page.dart';
import '../View/welcome/welcome_page.dart';

/// Navegação do SGA. As telas não se conhecem: cada uma recebe daqui os
/// callbacks para ir à próxima.
Route<void> _route(WidgetBuilder builder) {
  return MaterialPageRoute<void>(builder: builder);
}

Widget buildWelcomeScreen(BuildContext context) {
  return WelcomePage(
    onRegister: () => Navigator.of(context).push(_route(buildRegisterScreen)),
    onLogin: () => Navigator.of(context).push(_route(buildLoginScreen)),
  );
}

Widget buildRegisterScreen(BuildContext context) {
  return RegisterPage(
    // Só front por enquanto: o Maker nasce aqui e o envio ao servidor entra
    // numa próxima etapa.
    onRegister: (maker) => Toast.show(
      context,
      text: 'Cadastro de ${maker.nome} recebido. Ainda sem integração com o servidor.',
      type: ToastType.success,
    ),
    onGoToLogin: () =>
        Navigator.of(context).pushReplacement(_route(buildLoginScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

Widget buildLoginScreen(BuildContext context) {
  return LoginPage(
    onLogin: (credenciais) => Toast.show(
      context,
      text: 'Login de ${credenciais.email} recebido. A autenticação ainda não está conectada.',
    ),
    onForgotPassword: () => Toast.show(
      context,
      text: 'Recuperação de senha em breve.',
    ),
    onGoToRegister: () =>
        Navigator.of(context).pushReplacement(_route(buildRegisterScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}
