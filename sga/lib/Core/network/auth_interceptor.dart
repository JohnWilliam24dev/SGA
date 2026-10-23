import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'sessao_tokens.dart';
import 'token_refresher.dart';

/// Põe o `Authorization: Bearer` nas chamadas e, ao receber 401, renova a
/// sessão uma única vez e repete a chamada.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage storage,
    required TokenRefresher refresher,
  })  : _dio = dio,
        _storage = storage,
        _refresher = refresher;

  /// `extra` que marca uma chamada pública (sem token).
  static const semAuth = 'semAuth';
  static const _repetida = 'repetida';

  final Dio _dio;
  final TokenStorage _storage;
  final TokenRefresher _refresher;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[semAuth] != true) {
      final tokens = await _storage.ler();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final usado = req.headers['Authorization'];
    // Só renova se a chamada levava token e ainda não foi repetida.
    if (err.response?.statusCode != 401 ||
        usado == null ||
        req.extra[_repetida] == true) {
      return handler.next(err);
    }
    try {
      handler.resolve(await _repetir(req, await _tokensValidos(usado)));
    } on ApiException catch (e) {
      handler.reject(DioException(requestOptions: req, error: e));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Se outra chamada já renovou enquanto esta voava, usa o token novo sem
  /// renovar de novo.
  Future<SessaoTokens> _tokensValidos(Object usado) async {
    final atual = await _storage.ler();
    if (atual == null) throw ApiException.sessaoExpirada();
    if ('Bearer ${atual.accessToken}' != usado) return atual;
    return _refresher.renovar();
  }

  Future<Response<dynamic>> _repetir(RequestOptions req, SessaoTokens t) {
    req.headers['Authorization'] = 'Bearer ${t.accessToken}';
    req.extra[_repetida] = true;
    final dados = req.data;
    if (dados is FormData) req.data = dados.clone(); // o corpo já foi lido
    return _dio.fetch<dynamic>(req);
  }
}
