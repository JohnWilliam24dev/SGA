import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Quem usa o SGA para criar e gerenciar a sua arte (o artista).
///
/// Reúne o cadastro e as informações públicas usadas na contratação. A
/// persistência remota continua sendo uma próxima etapa.
@immutable
class Maker {
  const Maker({
    required this.nome,
    required this.email,
    required this.senha,
    required this.aceitouTermos,
    this.nomeArtistico = '',
    this.biografia = '',
    this.telefone = '',
    this.cidade = '',
    this.estado = '',
    this.instagram = '',
    this.portfolio = '',
    this.faz = const [],
    this.naoFaz = const [],
    this.termosServico = '',
  });

  final String nome;
  final String email;
  final String senha;
  final bool aceitouTermos;
  final String nomeArtistico;
  final String biografia;
  final String telefone;
  final String cidade;
  final String estado;
  final String instagram;
  final String portfolio;
  final List<String> faz;
  final List<String> naoFaz;
  final String termosServico;

  String get nomeExibicao =>
      nomeArtistico.trim().isEmpty ? nome : nomeArtistico.trim();

  String get inicial =>
      nomeExibicao.trim().isEmpty ? '?' : nomeExibicao.trim()[0].toUpperCase();

  Maker copyWith({
    String? nome,
    String? email,
    String? senha,
    bool? aceitouTermos,
    String? nomeArtistico,
    String? biografia,
    String? telefone,
    String? cidade,
    String? estado,
    String? instagram,
    String? portfolio,
    List<String>? faz,
    List<String>? naoFaz,
    String? termosServico,
  }) => Maker(
    nome: nome ?? this.nome,
    email: email ?? this.email,
    senha: senha ?? this.senha,
    aceitouTermos: aceitouTermos ?? this.aceitouTermos,
    nomeArtistico: nomeArtistico ?? this.nomeArtistico,
    biografia: biografia ?? this.biografia,
    telefone: telefone ?? this.telefone,
    cidade: cidade ?? this.cidade,
    estado: estado ?? this.estado,
    instagram: instagram ?? this.instagram,
    portfolio: portfolio ?? this.portfolio,
    faz: faz ?? this.faz,
    naoFaz: naoFaz ?? this.naoFaz,
    termosServico: termosServico ?? this.termosServico,
  );

  @override
  bool operator ==(Object other) {
    return other is Maker &&
        other.nome == nome &&
        other.email == email &&
        other.senha == senha &&
        other.aceitouTermos == aceitouTermos &&
        other.nomeArtistico == nomeArtistico &&
        other.biografia == biografia &&
        other.telefone == telefone &&
        other.cidade == cidade &&
        other.estado == estado &&
        other.instagram == instagram &&
        other.portfolio == portfolio &&
        listEquals(other.faz, faz) &&
        listEquals(other.naoFaz, naoFaz) &&
        other.termosServico == termosServico;
  }

  @override
  int get hashCode => Object.hash(
    nome,
    email,
    senha,
    aceitouTermos,
    nomeArtistico,
    biografia,
    telefone,
    cidade,
    estado,
    instagram,
    portfolio,
    Object.hashAll(faz),
    Object.hashAll(naoFaz),
    termosServico,
  );

  // A senha fica de fora de propósito: não vaza em logs.
  @override
  String toString() => 'Maker(nome: $nome, email: $email)';
}
