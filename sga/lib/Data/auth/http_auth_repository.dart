import '../../Core/network/network.dart';
import '../../Domain/domain.dart';

Map<String, dynamic> _mapa(Object? json) =>
    Map<String, dynamic>.from(json as Map);

/// Auth na API real: `/auth/cadastro`, `/auth/login`, `/auth/login/2fa`,
/// `/auth/google` e `/auth/logout` são públicas (sem Bearer); só
/// `/auth/google/vincular` exige a sessão.
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
    return _aposLogin(json, email: credenciais.email);
  }

  /// Resposta de login: sessão pronta ou desafio de 2FA.
  Future<LoginResultado> _aposLogin(
    Map<String, dynamic> json, {
    String? email,
  }) async {
    if (json['requer2fa'] == true) {
      return LoginRequer2fa(json['desafio'] as String);
    }
    await _sessao.iniciar(SessaoTokens.fromJson(json), email: email);
    return const LoginConcluido();
  }

  Map<String, Object> _corpoGoogle(GoogleCredencial c) => {
    'idToken': c.idToken,
    if (c.nonce != null) 'nonce': c.nonce!,
  };

  @override
  Future<LoginResultado> entrarComGoogle(GoogleCredencial credencial) async {
    final json = _mapa(
      await _client.post(
        '/auth/google',
        corpo: _corpoGoogle(credencial),
        autenticado: false,
      ),
    );
    return _aposLogin(json);
  }

  @override
  Future<void> vincularGoogle(GoogleCredencial credencial) async {
    await _client.post('/auth/google/vincular', corpo: _corpoGoogle(credencial));
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
