/// Os dados de sessão que a API devolve (`SessaoResposta`) e que o app
/// precisa guardar para falar com ela.
class SessaoTokens {
  const SessaoTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.makerId,
    required this.escopo,
  });

  factory SessaoTokens.fromJson(Map<String, dynamic> json) => SessaoTokens(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        makerId: json['makerId'] as String,
        escopo: json['escopo'] as String,
      );

  final String accessToken;

  /// Opaco e de uso único: cada renovação devolve um novo.
  final String refreshToken;
  final String makerId;

  /// `completo` ou `ativar2fa` (sessão restrita ao fluxo do 2FA).
  final String escopo;

  bool get restrita => escopo != 'completo';

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'makerId': makerId,
        'escopo': escopo,
      };
}

/// Onde a sessão fica guardada entre execuções do app.
abstract interface class TokenStorage {
  Future<SessaoTokens?> ler();
  Future<void> salvar(SessaoTokens tokens);
  Future<void> limpar();
}

/// Versão em memória, para os testes.
class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this._tokens]);

  SessaoTokens? _tokens;

  @override
  Future<SessaoTokens?> ler() async => _tokens;

  @override
  Future<void> salvar(SessaoTokens tokens) async => _tokens = tokens;

  @override
  Future<void> limpar() async => _tokens = null;
}
