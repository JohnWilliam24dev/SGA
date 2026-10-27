import 'package:flutter/foundation.dart' show immutable;

/// Dados informados na tela de login.
@immutable
class Credenciais {
  const Credenciais({required this.email, required this.senha});

  final String email;
  final String senha;

  @override
  bool operator ==(Object other) {
    return other is Credenciais && other.email == email && other.senha == senha;
  }

  @override
  int get hashCode => Object.hash(email, senha);

  // A senha fica de fora de propósito: não vaza em logs.
  @override
  String toString() => 'Credenciais(email: $email)';
}

/// Dados informados na tela de cadastro. A senha vive só aqui, até o envio:
/// o `Maker` (o artista) nunca a carrega.
@immutable
class Cadastro {
  const Cadastro({required this.nome, required this.email, required this.senha});

  final String nome;
  final String email;
  final String senha;

  @override
  bool operator ==(Object other) =>
      other is Cadastro &&
      other.nome == nome &&
      other.email == email &&
      other.senha == senha;

  @override
  int get hashCode => Object.hash(nome, email, senha);

  // A senha fica de fora de propósito: não vaza em logs.
  @override
  String toString() => 'Cadastro(nome: $nome, email: $email)';
}
