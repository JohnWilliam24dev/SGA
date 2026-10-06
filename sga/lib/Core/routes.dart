import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart' hide Icon;

import '../Domain/domain.dart';
import '../View/auth/login_page.dart';
import '../View/auth/register_page.dart';
import '../View/main/main_shell.dart';
import '../View/welcome/welcome_page.dart';

/// Dados de commissions simulados em memória (até a integração com o banco).
/// Um só repositório para o app todo, para o quadro lembrar as mudanças
/// enquanto o app estiver aberto.
final CommissionRepository _commissionRepository = FakeCommissionRepository();

/// Navegação do SGA. As telas não se conhecem: cada uma recebe daqui os
/// callbacks para ir à próxima.
Route<void> _route(WidgetBuilder builder) {
  return MaterialPageRoute<void>(builder: builder);
}

/// Entra no app (ainda sem autenticação de verdade) e limpa o histórico, para
/// o botão voltar não retornar ao login.
void _enterApp(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    _route(buildMainScreen),
    (route) => false,
  );
}

Widget buildWelcomeScreen(BuildContext context) {
  return WelcomePage(
    onRegister: () => Navigator.of(context).push(_route(buildRegisterScreen)),
    onLogin: () => Navigator.of(context).push(_route(buildLoginScreen)),
  );
}

Widget buildRegisterScreen(BuildContext context) {
  return RegisterPage(
    // Só front por enquanto: o Maker nasce na tela e o envio ao servidor
    // entra numa próxima etapa; por ora o cadastro já abre o app.
    onRegister: (maker) => _enterApp(context),
    onGoToLogin: () =>
        Navigator.of(context).pushReplacement(_route(buildLoginScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

Widget buildLoginScreen(BuildContext context) {
  return LoginPage(
    // Sem autenticação ainda: qualquer login válido entra.
    onLogin: (credenciais) => _enterApp(context),
    onForgotPassword: () => Toast.show(
      context,
      text: 'Recuperação de senha em breve.',
    ),
    onGoToRegister: () =>
        Navigator.of(context).pushReplacement(_route(buildRegisterScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

Widget buildMainScreen(BuildContext context) {
  return MainShell(
    commissionRepository: _commissionRepository,
    onLogout: () => Navigator.of(context).pushAndRemoveUntil(
      _route(buildWelcomeScreen),
      (route) => false,
    ),
  );
}
