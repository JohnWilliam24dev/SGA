import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../View/auth/login_page.dart';
import '../../View/auth/register_page.dart';
import '../../View/welcome/welcome_page.dart';
import 'app_route.dart';
import 'main_routes.dart';

/// Entra no app (ainda sem autenticação de verdade) e limpa o histórico, para
/// o botão voltar não retornar ao login.
void _enterApp(BuildContext context, Maker maker) {
  Navigator.of(context).pushAndRemoveUntil(
    appRoute((routeContext) => buildMainScreen(routeContext, maker)),
    (route) => false,
  );
}

Widget buildWelcomeScreen(BuildContext context) {
  return WelcomePage(
    onRegister: () => Navigator.of(context).push(appRoute(buildRegisterScreen)),
    onLogin: () => Navigator.of(context).push(appRoute(buildLoginScreen)),
  );
}

Widget buildRegisterScreen(BuildContext context) {
  return RegisterPage(
    // Só front por enquanto: o Maker nasce na tela e o envio ao servidor
    // entra numa próxima etapa; por ora o cadastro já abre o app.
    onRegister: (maker) => _enterApp(context, maker),
    onGoToLogin: () =>
        Navigator.of(context).pushReplacement(appRoute(buildLoginScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

Widget buildLoginScreen(BuildContext context) {
  return LoginPage(
    // Sem autenticação ainda: qualquer login válido entra.
    onLogin: (credenciais) => _enterApp(
      context,
      Maker(
        nome: credenciais.email.split('@').first,
        email: credenciais.email,
        senha: credenciais.senha,
        aceitouTermos: true,
      ),
    ),
    onForgotPassword: () =>
        Toast.show(context, text: 'Recuperação de senha em breve.'),
    onGoToRegister: () =>
        Navigator.of(context).pushReplacement(appRoute(buildRegisterScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}
