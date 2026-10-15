import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../../View/main/main_shell.dart';
import 'app_route.dart';
import 'auth_routes.dart';
import 'commission_routes.dart';

/// A área logada do app: o shell com o menu e as seções.
Widget buildMainScreen(BuildContext context, [Maker? maker]) {
  return MainShell(
    commissionRepository: commissionRepository,
    statusRepository: statusRepository,
    onOpenCommission: (commission, statusNome) => openCommissionDetail(
      context,
      commission: commission,
      statusNome: statusNome,
    ),
    onLogout: () => Navigator.of(context).pushAndRemoveUntil(
      appRoute(buildWelcomeScreen),
      (route) => false,
    ),
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
