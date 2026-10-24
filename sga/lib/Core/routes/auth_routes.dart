import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../View/auth/login_page.dart';
import '../../View/auth/register_page.dart';
import '../../View/auth/two_factor_page.dart';
import '../../View/welcome/welcome_page.dart';
import '../app/auth_scope.dart';
import '../network/network.dart';
import 'app_route.dart';

/// Roda uma ação de auth e troca o erro da API por uma mensagem que o botão
/// do formulário sabe exibir. Ao dar certo a sessão muda e o `SessaoGate`
/// leva para a tela certa: aqui ninguém navega para dentro do app.
Future<void> _comMensagem(Future<void> Function() acao) async {
  try {
    await acao();
  } on ApiException catch (e) {
    throw UserFacingException(e.mensagemParaUsuario);
  }
}

Widget buildWelcomeScreen(BuildContext context) {
  return WelcomePage(
    onRegister: () => Navigator.of(context).push(appRoute(buildRegisterScreen)),
    onLogin: () => Navigator.of(context).push(appRoute(buildLoginScreen)),
  );
}

Widget buildRegisterScreen(BuildContext context) {
  final auth = AuthScope.of(context).auth;
  return RegisterPage(
    onRegister: (maker) => _comMensagem(
      () => auth.cadastrar(
        nome: maker.nome,
        email: maker.email,
        senha: maker.senha,
      ),
    ),
    onGoToLogin: () =>
        Navigator.of(context).pushReplacement(appRoute(buildLoginScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

Widget buildLoginScreen(BuildContext context) {
  final auth = AuthScope.of(context).auth;
  return LoginPage(
    onLogin: (credenciais) => _comMensagem(() async {
      final resultado = await auth.entrar(credenciais);
      if (resultado is LoginRequer2fa && context.mounted) {
        Navigator.of(context).push(
          appRoute((_) => buildTwoFactorScreen(context, resultado.desafio)),
        );
      }
    }),
    onForgotPassword: () =>
        Toast.show(context, text: 'Recuperação de senha em breve.'),
    onGoToRegister: () =>
        Navigator.of(context).pushReplacement(appRoute(buildRegisterScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

/// Segundo passo do login, aberto por cima do login quando a conta tem 2FA.
Widget buildTwoFactorScreen(BuildContext context, String desafio) {
  final auth = AuthScope.of(context).auth;
  return TwoFactorPage(
    onSubmit: (codigo, recuperacao) => _comMensagem(
      () => auth.confirmarLogin2fa(
        desafio: desafio,
        codigo: recuperacao ? null : codigo,
        codigoRecuperacao: recuperacao ? codigo : null,
      ),
    ),
    onBack: () => Navigator.of(context).pop(),
  );
}
