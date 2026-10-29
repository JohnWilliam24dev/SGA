import 'package:flutter/foundation.dart' show immutable;

/// Prova de identidade que o Google entrega ao app (o `idToken`), mais o
/// `nonce` quando o app o usou. É isso que o servidor valida.
@immutable
class GoogleCredencial {
  const GoogleCredencial({required this.idToken, this.nonce});

  final String idToken;
  final String? nonce;

  // O token é uma credencial: fica de fora do `toString`.
  @override
  String toString() => 'GoogleCredencial()';
}

/// Abre o login do Google no aparelho e devolve a credencial, ou `null` se a
/// pessoa desistiu. A implementação real (plugin `google_sign_in`, com os
/// client IDs do projeto) entra no app; sem ela o botão do Google não
/// aparece.
abstract interface class GoogleSignInProvider {
  Future<GoogleCredencial?> obter();
}
