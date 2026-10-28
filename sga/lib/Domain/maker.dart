import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Quem usa o SGA para criar e gerenciar a sua arte (o artista).
///
/// Reúne só o que a API guarda (nome, termos e "faço e não faço") mais o
/// e-mail da sessão, que o servidor não devolve no perfil; ver
/// [MakerRepository].
@immutable
class Maker {
  const Maker({
    required this.nome,
    required this.email,
    required this.aceitouTermos,
    this.faz = const [],
    this.naoFaz = const [],
    this.termosServico = '',
  });

  final String nome;
  final String email;
  final bool aceitouTermos;
  final List<String> faz;
  final List<String> naoFaz;
  final String termosServico;

  /// Nome mostrado no app (hoje, o próprio nome).
  String get nomeExibicao => nome;

  String get inicial =>
      nome.trim().isEmpty ? '?' : nome.trim()[0].toUpperCase();

  Maker copyWith({
    String? nome,
    String? email,
    bool? aceitouTermos,
    List<String>? faz,
    List<String>? naoFaz,
    String? termosServico,
  }) => Maker(
    nome: nome ?? this.nome,
    email: email ?? this.email,
    aceitouTermos: aceitouTermos ?? this.aceitouTermos,
    faz: faz ?? this.faz,
    naoFaz: naoFaz ?? this.naoFaz,
    termosServico: termosServico ?? this.termosServico,
  );

  @override
  bool operator ==(Object other) {
    return other is Maker &&
        other.nome == nome &&
        other.email == email &&
        other.aceitouTermos == aceitouTermos &&
        listEquals(other.faz, faz) &&
        listEquals(other.naoFaz, naoFaz) &&
        other.termosServico == termosServico;
  }

  @override
  int get hashCode => Object.hash(
    nome,
    email,
    aceitouTermos,
    Object.hashAll(faz),
    Object.hashAll(naoFaz),
    termosServico,
  );

  // O Maker não guarda senha: ela só existe no [Cadastro] e no login.
  @override
  String toString() => 'Maker(nome: $nome, email: $email)';
}
