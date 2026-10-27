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

/// Situação do 2FA da conta (`GET /auth/2fa/estado`).
@immutable
class DoisFatorEstado {
  const DoisFatorEstado({
    required this.ativo,
    required this.codigosRecuperacaoRestantes,
  });

  final bool ativo;
  final int codigosRecuperacaoRestantes;
}

/// Ativação e gestão do segundo fator (TOTP).
abstract interface class DoisFatorRepository {
  /// Começa a ativação. Devolve `null` se a conta já tem 2FA ativo.
  Future<DoisFatorInicio?> iniciar();

  /// Confirma o código de 6 dígitos e devolve os códigos de recuperação.
  /// Eles só aparecem **desta vez**: quem chama precisa exibi-los.
  Future<List<String>> confirmar(String codigo);

  /// Se o 2FA está ativo e quantos códigos de recuperação ainda valem.
  Future<DoisFatorEstado> estado();

  /// Gera um lote novo de códigos (o anterior deixa de valer). Pede o
  /// [codigo] do autenticador e a [senha] (a API só exige em conta com
  /// senha). Os códigos só aparecem **desta vez**.
  Future<List<String>> regenerarCodigos({required String codigo, String? senha});

  /// Troca a sessão restrita pela completa. Chamar depois de o usuário ter
  /// guardado os códigos de recuperação.
  Future<void> concluirAtivacao();
}
