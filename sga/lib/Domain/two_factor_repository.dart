import 'package:flutter/foundation.dart' show immutable;

/// Dados para configurar o aplicativo autenticador.
@immutable
class DoisFatorInicio {
  const DoisFatorInicio({required this.segredo, required this.uri});

  /// Chave em texto, para digitar quando não dá para escanear o QR.
  final String segredo;

  /// `otpauth://`, o conteúdo do QR code.
  final String uri;

  @override
  bool operator ==(Object other) =>
      other is DoisFatorInicio && other.segredo == segredo && other.uri == uri;

  @override
  int get hashCode => Object.hash(segredo, uri);

  // O segredo fica de fora de propósito: não vaza em logs.
  @override
  String toString() => 'DoisFatorInicio()';
}

/// Ativação do segundo fator (TOTP).
abstract interface class DoisFatorRepository {
  /// Começa a ativação. Devolve `null` se a conta já tem 2FA ativo.
  Future<DoisFatorInicio?> iniciar();

  /// Confirma o código de 6 dígitos e devolve os códigos de recuperação.
  /// Eles só aparecem **desta vez**: quem chama precisa exibi-los.
  Future<List<String>> confirmar(String codigo);

  /// Troca a sessão restrita pela completa. Chamar depois de o usuário ter
  /// guardado os códigos de recuperação.
  Future<void> concluirAtivacao();
}
