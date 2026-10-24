import '../../Core/network/network.dart';
import '../../Domain/domain.dart';

/// Auth simulada (testes e desenvolvimento sem servidor): qualquer login
/// válido entra e o cadastro já abre o app com sessão completa.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._sessao);

  static const _tokens = SessaoTokens(
    accessToken: 'fake',
    refreshToken: 'fake',
    makerId: 'fake',
    escopo: 'completo',
  );

  final SessaoStore _sessao;

  @override
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) => _sessao.iniciar(_tokens, nome: nome, email: email);

  @override
  Future<LoginResultado> entrar(Credenciais credenciais) async {
    await _sessao.iniciar(
      _tokens,
      nome: credenciais.email.split('@').first,
      email: credenciais.email,
    );
    return const LoginConcluido();
  }

  @override
  Future<int?> confirmarLogin2fa({
    required String desafio,
    String? codigo,
    String? codigoRecuperacao,
  }) async {
    await _sessao.iniciar(_tokens);
    return null;
  }

  @override
  Future<void> sair() => _sessao.encerrar();
}
