import 'package:sga/Core/core.dart';
import 'package:sga/Domain/domain.dart';

import 'fake_adapter.dart';

/// Auth de teste: o login pede 2FA e o código 123456 conclui.
class Auth2fa implements AuthRepository {
  Auth2fa(this.sessao, {this.restantes});

  final SessaoStore sessao;
  final int? restantes;

  @override
  Future<LoginResultado> entrar(Credenciais c) async =>
      const LoginRequer2fa('desafio-1');

  @override
  Future<int?> confirmarLogin2fa({
    required String desafio,
    String? codigo,
    String? codigoRecuperacao,
  }) async {
    if (codigo != '123456') {
      throw const ApiException(
        tipo: ApiErroTipo.sessaoExpirada,
        mensagem: 'Código inválido',
      );
    }
    await sessao.iniciar(tokensA1, codigosRestantes: restantes);
    return restantes;
  }

  @override
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {}

  @override
  Future<void> sair() => sessao.encerrar();
}
