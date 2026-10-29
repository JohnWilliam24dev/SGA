import 'credenciais.dart';
import 'google_credencial.dart';

/// Resultado do login com e-mail e senha.
sealed class LoginResultado {
  const LoginResultado();
}

/// Entrou: a sessão já está guardada.
final class LoginConcluido extends LoginResultado {
  const LoginConcluido();
}

/// A conta tem 2FA: falta confirmar o [desafio] com um código.
final class LoginRequer2fa extends LoginResultado {
  const LoginRequer2fa(this.desafio);

  final String desafio;
}

/// Cadastro, login e logout. Quem implementa guarda a sessão; a tela só
/// decide para onde ir.
abstract interface class AuthRepository {
  /// Cria a conta e a sessão. Todo Maker novo entra com sessão restrita,
  /// até ativar o 2FA.
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  });

  Future<LoginResultado> entrar(Credenciais credenciais);

  /// Conclui o login de uma conta com 2FA, com **um** entre [codigo] (6
  /// dígitos) e [codigoRecuperacao]. Devolve quantos códigos de recuperação
  /// restam, quando a API informa.
  Future<int?> confirmarLogin2fa({
    required String desafio,
    String? codigo,
    String? codigoRecuperacao,
  });

  /// Entra com a conta Google (`POST /auth/google`); o servidor cria a conta
  /// se ela não existir. Como no login comum, a conta pode pedir o 2FA.
  Future<LoginResultado> entrarComGoogle(GoogleCredencial credencial);

  /// Vincula a conta Google à conta já logada (`POST /auth/google/vincular`,
  /// exige sessão completa).
  Future<void> vincularGoogle(GoogleCredencial credencial);

  /// Encerra a sessão. Sai do aparelho mesmo se o servidor não responder.
  Future<void> sair();
}
