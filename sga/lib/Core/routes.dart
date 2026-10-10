import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart'
    show Dialog, MaterialPageRoute, showDialog;
import 'package:flutter/widgets.dart' hide Icon;

import '../Domain/domain.dart';
import '../View/auth/login_page.dart';
import '../View/auth/register_page.dart';
import '../View/commissions/commission_detail_page.dart';
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
void _enterApp(BuildContext context, Maker maker) {
  Navigator.of(context).pushAndRemoveUntil(
    _route((routeContext) => buildMainScreen(routeContext, maker)),
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
    onRegister: (maker) => _enterApp(context, maker),
    onGoToLogin: () =>
        Navigator.of(context).pushReplacement(_route(buildLoginScreen)),
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
        Navigator.of(context).pushReplacement(_route(buildRegisterScreen)),
    onBack: () => Navigator.of(context).pop(),
  );
}

Widget buildMainScreen(BuildContext context, [Maker? maker]) {
  return MainShell(
    commissionRepository: _commissionRepository,
    onOpenCommission: (commission, statusNome) => _openCommissionDetail(
      context,
      commission: commission,
      statusNome: statusNome,
    ),
    onLogout: () =>
        Navigator.of(context)
            .pushAndRemoveUntil(_route(buildWelcomeScreen), (route) => false),
    maker:
        maker ??
        const Maker(
          nome: 'Maker',
          email: 'maker@sga.app',
          senha: '',
          aceitouTermos: true,
        ),
  );
}

/// No desktop o pedido é uma nota sobre o quadro; no celular, onde não há
/// espaço para as duas coisas, continua sendo uma página própria.
void _openCommissionDetail(
  BuildContext context, {
  required CommissionResumoModel commission,
  required String statusNome,
}) {
  final mobile = MediaQuery.sizeOf(context).width < 760;
  if (mobile) {
    Navigator.of(context).push(
      _route(
        (_) => buildCommissionDetailScreen(
          commission: commission,
          statusNome: statusNome,
        ),
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0x00000000),
      insetPadding: const EdgeInsets.all(24),
      child: buildCommissionDetailScreen(
        commission: commission,
        statusNome: statusNome,
        compact: true,
        onBack: () => Navigator.of(dialogContext).pop(),
      ),
    ),
  );
}

Widget buildCommissionDetailScreen({
  required CommissionResumoModel commission,
  required String statusNome,
  bool compact = false,
  VoidCallback? onBack,
}) {
  return Builder(
    builder: (context) => CommissionDetailPage(
      repository: _commissionRepository,
      commission: commission,
      statusNome: statusNome,
      compact: compact,
      onBack: onBack ?? () => Navigator.of(context).pop(),
    ),
  );
}
