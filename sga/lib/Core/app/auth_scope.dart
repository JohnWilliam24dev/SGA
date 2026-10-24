import 'package:flutter/widgets.dart';

import '../../Domain/domain.dart';
import '../network/network.dart';

/// Entrega a sessão e os repositórios de auth e de 2FA a qualquer rota, sem passar
/// parâmetro de tela em tela. Fica acima do Navigator.
class AuthScope extends InheritedWidget {
  const AuthScope({
    super.key,
    required this.auth,
    required this.sessao,
    required this.doisFator,
    required super.child,
  });

  final AuthRepository auth;
  final DoisFatorRepository doisFator;
  final SessaoStore sessao;

  /// Os dois objetos não mudam durante a vida do app, então quem lê não
  /// precisa ser reconstruído (por isso não registra dependência).
  static AuthScope of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope não encontrado acima desta rota.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AuthScope old) => false;
}
