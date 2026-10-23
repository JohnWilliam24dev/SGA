import 'package:flutter/foundation.dart' show kReleaseMode;

/// URL informada no build: `--dart-define=API_BASE_URL=https://...`.
const _urlInformada = String.fromEnvironment('API_BASE_URL');

/// Endereço e tempos limite do cliente HTTP. Nenhuma URL fica fixa no código
/// de produção: ela vem do `--dart-define` do build.
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 60),
  });

  /// Padrão só para desenvolvimento (API rodando na própria máquina). No
  /// emulador Android, passe `--dart-define=API_BASE_URL=http://10.0.2.2:3000`.
  static const urlDesenvolvimento = 'http://localhost:3000';

  /// Lê o ambiente do build. Em release, sem `API_BASE_URL` o app falha alto
  /// em vez de apontar para o lugar errado.
  factory ApiConfig.ambiente() {
    if (_urlInformada.isNotEmpty) return ApiConfig(baseUrl: _urlInformada);
    if (kReleaseMode) {
      throw StateError(
        'API_BASE_URL não definida. Gere o build com '
        '--dart-define=API_BASE_URL=https://seu-servidor',
      );
    }
    return const ApiConfig(baseUrl: urlDesenvolvimento);
  }

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Teto de envio: cobre o upload de imagem (até 4 MB).
  final Duration sendTimeout;
}
