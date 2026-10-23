import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'sessao_tokens.dart';

/// Renova a sessão com `POST /auth/refresh`.
///
/// O refresh token é de uso único: se duas chamadas renovassem ao mesmo
/// tempo, a segunda queimaria a sessão. Por isso chamadas simultâneas
/// compartilham a mesma renovação.
class TokenRefresher {
  TokenRefresher({required Dio dio, required TokenStorage storage})
      : _dio = dio,
        _storage = storage;

  /// Dio próprio, sem interceptors (evita laço de 401 dentro do refresh).
  final Dio _dio;
  final TokenStorage _storage;
  Future<SessaoTokens>? _emCurso;

  /// Chamado quando a sessão não tem mais volta (refresh recusado): o app
  /// deve voltar ao login.
  void Function()? onSessaoEncerrada;

  Future<SessaoTokens> renovar() =>
      _emCurso ??= _executar().whenComplete(() => _emCurso = null);

  Future<SessaoTokens> _executar() async {
    final atual = await _storage.ler();
    if (atual == null) throw ApiException.sessaoExpirada();
    try {
      final r = await _dio.post<dynamic>(
        '/auth/refresh',
        data: {'refreshToken': atual.refreshToken},
      );
      final novo = SessaoTokens.fromJson(
        Map<String, dynamic>.from(r.data as Map),
      );
      await _storage.salvar(novo);
      return novo;
    } on DioException catch (e) {
      final erro = ApiException.deDio(e);
      if (_transitorio(erro)) throw erro; // mantém a sessão: pode ser a rede
      await encerrar();
      throw ApiException.sessaoExpirada();
    }
  }

  /// Apaga a sessão guardada e avisa o app.
  Future<void> encerrar() async {
    await _storage.limpar();
    onSessaoEncerrada?.call();
  }

  bool _transitorio(ApiException e) =>
      e.tipo == ApiErroTipo.conexao ||
      e.tipo == ApiErroTipo.servidor ||
      e.tipo == ApiErroTipo.limite;
}
