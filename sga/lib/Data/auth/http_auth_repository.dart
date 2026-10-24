import '../../Core/network/network.dart';
import '../../Domain/domain.dart';

Map<String, dynamic> _mapa(Object? json) =>
    Map<String, dynamic>.from(json as Map);

/// Auth na API real: `/auth/cadastro`, `/auth/login`, `/auth/login/2fa` e
/// `/auth/logout`. Todas são rotas públicas (sem Bearer).
class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository({required ApiClient client, required SessaoStore sessao})
      : _client = client,
        _sessao = sessao;

  final ApiClient _client;
  final SessaoStore _sessao;

  @override
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final json = _mapa(
      await _client.post(
        '/auth/cadastro',
        corpo: {'nome': nome, 'email': email, 'senha': senha},
        autenticado: false,
      ),
    );
    await _sessao.iniciar(
      SessaoTokens.fromJson(json),
      nome: json['nome'] as String? ?? nome,
      email: json['email'] as String? ?? email,
    );
  }

  @override
  Future<LoginResultado> entrar(Credenciais credenciais) async {
    final json = _mapa(
      await _client.post(
        '/auth/login',
        corpo: {'email': credenciais.email, 'senha': credenciais.senha},
        autenticado: false,
      ),
    );
    if (json['requer2fa'] == true) {
      return LoginRequer2fa(json['desafio'] as String);
    }
    await _sessao.iniciar(
      SessaoTokens.fromJson(json),
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
    assert(
      (codigo == null) != (codigoRecuperacao == null),
      'Informe um código ou um código de recuperação, nunca os dois.',
    );
    final json = _mapa(
      await _client.post(
        '/auth/login/2fa',
        corpo: {
          'desafio': desafio,
          if (codigo != null) 'codigo': codigo,
          if (codigoRecuperacao != null) 'codigoRecuperacao': codigoRecuperacao,
        },
        autenticado: false,
      ),
    );
    final restantes = json['codigosRecuperacaoRestantes'] as int?;
    await _sessao.iniciar(
      SessaoTokens.fromJson(json),
      codigosRestantes: restantes,
    );
    return restantes;
  }

  @override
  Future<void> sair() async {
    final refresh = _sessao.refreshToken;
    try {
      if (refresh != null) {
        await _client.post(
          '/auth/logout',
          corpo: {'refreshToken': refresh},
          autenticado: false,
        );
      }
    } on ApiException {
      // Sem rede ou token já inválido: sai do aparelho mesmo assim.
    } finally {
      await _sessao.encerrar();
    }
  }
}
