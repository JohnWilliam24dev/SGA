import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'sessao_tokens.dart';

/// Guarda a sessão no armazenamento seguro do aparelho (Keychain/Keystore).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _chave = 'sga.sessao';

  final FlutterSecureStorage _storage;

  @override
  Future<SessaoTokens?> ler() async {
    final bruto = await _storage.read(key: _chave);
    if (bruto == null) return null;
    try {
      return SessaoTokens.fromJson(jsonDecode(bruto) as Map<String, dynamic>);
    } catch (_) {
      // Conteúdo corrompido: melhor pedir login de novo do que travar.
      await limpar();
      return null;
    }
  }

  @override
  Future<void> salvar(SessaoTokens tokens) =>
      _storage.write(key: _chave, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> limpar() => _storage.delete(key: _chave);
}
