import 'package:flutter/foundation.dart';

import 'sessao_tokens.dart';

enum SessaoEstado { carregando, deslogado, restrita, logada }

/// Estado observável da sessão. O armazenamento ([TokenStorage]) é a fonte
/// da verdade: depois de qualquer operação de auth (inclusive a renovação
/// automática do token) o store relê dele via [sincronizar].
class SessaoStore extends ChangeNotifier {
  SessaoStore(this._storage);

  final TokenStorage _storage;
  SessaoEstado _estado = SessaoEstado.carregando;
  SessaoTokens? _tokens;

  /// Dados só para exibição, não persistidos: valem na sessão em que o
  /// usuário entrou, até o perfil vir da API.
  String? nome;
  String? email;

  /// Quantos códigos de recuperação restam após entrar com 2FA. Quem exibe
  /// o aviso lê e zera ([consumirCodigosRestantes]).
  int? _codigosRestantes;

  SessaoEstado get estado => _estado;
  String? get makerId => _tokens?.makerId;
  String? get refreshToken => _tokens?.refreshToken;

  /// Restaura a sessão guardada (início do app).
  Future<void> carregar() => sincronizar();

  Future<void> sincronizar() async {
    _tokens = await _storage.ler();
    final t = _tokens;
    _estado = switch (t) {
      null => SessaoEstado.deslogado,
      SessaoTokens(restrita: true) => SessaoEstado.restrita,
      _ => SessaoEstado.logada,
    };
    if (t == null) nome = email = null;
    notifyListeners();
  }

  Future<void> iniciar(
    SessaoTokens tokens, {
    String? nome,
    String? email,
    int? codigosRestantes,
  }) async {
    await _storage.salvar(tokens);
    this.nome = nome;
    this.email = email;
    _codigosRestantes = codigosRestantes;
    await sincronizar();
  }

  /// Apaga a sessão guardada (logout ou sessão expirada).
  Future<void> encerrar() async {
    await _storage.limpar();
    await sincronizar();
  }

  int? consumirCodigosRestantes() {
    final n = _codigosRestantes;
    _codigosRestantes = null;
    return n;
  }
}
