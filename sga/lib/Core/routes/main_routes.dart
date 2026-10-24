import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../View/main/main_shell.dart';
import '../app/auth_scope.dart';
import 'app_route.dart';
import 'commission_routes.dart';

/// A área logada do app: o shell com o menu e as seções. O logout só
/// encerra a sessão; o `SessaoGate` volta para a tela inicial.
Widget buildMainScreen(BuildContext context, [Maker? maker]) {
  return MainShell(
    commissionRepository: commissionRepository,
    statusRepository: statusRepository,
    catalogoRepository: catalogoRepository,
    onOpenCommission: (commission, statusNome) => openCommissionDetail(
      context,
      commission: commission,
      statusNome: statusNome,
    ),
    onLogout: () => unawaited(AuthScope.of(context).auth.sair()),
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
