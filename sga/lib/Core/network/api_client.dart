import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'sessao_tokens.dart';
import 'token_refresher.dart';

/// Camada única de rede do app: monta a URL, injeta o token, renova a
/// sessão no 401 e devolve o JSON já decodificado (`null` no 204). Toda
/// falha sai como [ApiException].
///
/// Para enviar arquivo, passe um `FormData` do dio como `corpo`.
class ApiClient {
  ApiClient._(this._dio, this._refresher);

  factory ApiClient({
    required ApiConfig config,
    required TokenStorage storage,
    HttpClientAdapter? adapter, // para os testes
  }) {
    final dio = _novoDio(config, adapter);
    final refresher = TokenRefresher(
      dio: _novoDio(config, adapter),
      storage: storage,
    );
    dio.interceptors.add(
      AuthInterceptor(dio: dio, storage: storage, refresher: refresher),
    );
    return ApiClient._(dio, refresher);
  }

  final Dio _dio;
  final TokenRefresher _refresher;

  /// Chamado quando a renovação falha de vez e a sessão é apagada.
  set onSessaoEncerrada(void Function()? ao) =>
      _refresher.onSessaoEncerrada = ao;

  /// Renova a sessão agora (mesma trava do 401: nunca duas renovações ao
  /// mesmo tempo). Serve, por exemplo, para liberar o escopo completo logo
  /// depois de ativar o 2FA. Falha com [ApiException].
  Future<void> renovarSessao() => _refresher.renovar();

  Future<dynamic> get(
    String caminho, {
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) =>
      _enviar('GET', caminho, query: query, autenticado: autenticado);

  Future<dynamic> post(
    String caminho, {
    Object? corpo,
    bool autenticado = true,
  }) =>
      _enviar('POST', caminho, corpo: corpo, autenticado: autenticado);

  Future<dynamic> patch(String caminho, {Object? corpo}) =>
      _enviar('PATCH', caminho, corpo: corpo);

  Future<dynamic> put(String caminho, {Object? corpo}) =>
      _enviar('PUT', caminho, corpo: corpo);

  Future<dynamic> delete(String caminho) => _enviar('DELETE', caminho);

  Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Object? corpo,
    Map<String, dynamic>? query,
    bool autenticado = true,
  }) async {
    try {
      final r = await _dio.request<dynamic>(
        caminho,
        data: corpo,
        queryParameters: query,
        options: Options(
          method: metodo,
          extra: {if (!autenticado) AuthInterceptor.semAuth: true},
        ),
      );
      final dados = r.data;
      return dados is String && dados.isEmpty ? null : dados;
    } on DioException catch (e) {
      throw ApiException.deDio(e);
    }
  }

  static Dio _novoDio(ApiConfig c, HttpClientAdapter? adapter) {
    final dio = Dio(
      BaseOptions(
        baseUrl: c.baseUrl.replaceAll(RegExp(r'/+$'), ''),
        connectTimeout: c.connectTimeout,
        receiveTimeout: c.receiveTimeout,
        sendTimeout: c.sendTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    if (adapter != null) dio.httpClientAdapter = adapter;
    return dio;
  }
}
