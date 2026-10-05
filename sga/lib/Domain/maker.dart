import 'package:flutter/foundation.dart' show immutable;

/// Quem usa o SGA para criar e gerenciar a sua arte (o artista).
///
/// Por enquanto é só o que o formulário de cadastro coleta; a conexão com
/// o servidor entra depois.
@immutable
class Maker {
  const Maker({
    required this.nome,
    required this.email,
    required this.senha,
    required this.aceitouTermos,
  });

  final String nome;
  final String email;
  final String senha;
  final bool aceitouTermos;

  @override
  bool operator ==(Object other) {
    return other is Maker &&
        other.nome == nome &&
        other.email == email &&
        other.senha == senha &&
        other.aceitouTermos == aceitouTermos;
  }

  @override
  int get hashCode => Object.hash(nome, email, senha, aceitouTermos);

  // A senha fica de fora de propósito: não vaza em logs.
  @override
  String toString() => 'Maker(nome: $nome, email: $email)';
}
