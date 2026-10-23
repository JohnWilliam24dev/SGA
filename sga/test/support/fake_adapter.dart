import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sga/Core/core.dart';

/// Servidor falso para os testes de rede: [responder] decide cada resposta.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.responder);

  final Future<ResponseBody> Function(RequestOptions options) responder;
  final List<RequestOptions> chamadas = [];

  int contar(String caminho) =>
      chamadas.where((c) => c.path == caminho).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    chamadas.add(options);
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(
  Object? corpo,
  int status, {
  Map<String, List<String>> headers = const {},
}) =>
    ResponseBody.fromString(
      corpo == null ? '' : jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );

const tokensA1 = SessaoTokens(
  accessToken: 'a1',
  refreshToken: 'r1',
  makerId: 'm1',
  escopo: 'completo',
);

Map<String, dynamic> sessaoJson(String n) => {
      'makerId': 'm1',
      'accessToken': 'a$n',
      'refreshToken': 'r$n',
      'tokenType': 'Bearer',
      'expiresIn': 900,
      'escopo': 'completo',
    };

ApiClient clienteDe(FakeAdapter adapter, TokenStorage storage) => ApiClient(
      config: const ApiConfig(baseUrl: 'http://api.teste/'),
      storage: storage,
      adapter: adapter,
    );

Matcher apiErro(ApiErroTipo tipo) =>
    throwsA(isA<ApiException>().having((e) => e.tipo, 'tipo', tipo));
