import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../View/auth/two_factor_pending_page.dart';
import '../network/network.dart';
import '../routes.dart';
import 'auth_scope.dart';

/// Raiz de navegação: decide a tela pelo estado da sessão. Sem sessão, a
/// boas-vindas; sessão restrita, a ativação do 2FA; sessão completa, o app.
/// Quando o estado muda (login, logout, sessão expirada) fecha as telas
/// empilhadas por cima, para o botão voltar nunca levar a um estado velho.
class SessaoGate extends StatefulWidget {
  const SessaoGate({super.key});

  @override
  State<SessaoGate> createState() => _SessaoGateState();
}

class _SessaoGateState extends State<SessaoGate> {
  late final AuthScope _escopo = AuthScope.of(context);
  late SessaoEstado _anterior = _escopo.sessao.estado;

  @override
  void initState() {
    super.initState();
    _escopo.sessao.addListener(_aoMudar);
    _escopo.sessao.carregar();
  }

  @override
  void dispose() {
    _escopo.sessao.removeListener(_aoMudar);
    super.dispose();
  }

  void _aoMudar() {
    final atual = _escopo.sessao.estado;
    final mudou = atual != _anterior;
    _anterior = atual;
    if (!mudou || !mounted) return;
    Navigator.of(context).popUntil((rota) => rota.isFirst);
    final restantes = _escopo.sessao.consumirCodigosRestantes();
    if (atual == SessaoEstado.logada && restantes != null && restantes <= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Toast.show(context, text: avisoCodigos(restantes), type: ToastType.warning);
        }
      });
    }
  }

  Maker get _maker => Maker(
        nome: _escopo.sessao.nome ?? 'Maker',
        email: _escopo.sessao.email ?? '',
        senha: '',
        aceitouTermos: true,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _escopo.sessao,
      builder: (context, _) => switch (_escopo.sessao.estado) {
        SessaoEstado.carregando => const SizedBox.shrink(),
        SessaoEstado.deslogado => Builder(builder: buildWelcomeScreen),
        SessaoEstado.restrita => TwoFactorPendingPage(
            onLogout: () => _escopo.auth.sair(),
          ),
        SessaoEstado.logada => Builder(
            builder: (context) => buildMainScreen(context, _maker),
          ),
      },
    );
  }
}

/// Texto do aviso quando acabam os códigos de recuperação.
String avisoCodigos(int restantes) => switch (restantes) {
      0 => 'Você usou o último código de recuperação.',
      1 => 'Resta só 1 código de recuperação.',
      _ => 'Restam só $restantes códigos de recuperação.',
    };
