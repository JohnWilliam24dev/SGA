import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

/// Os quatro campos do cadastro: nome, e-mail, senha e confirmação.
List<Widget> registerFields() => [
  InputField(
    name: 'nome',
    hint: 'Nome',
    validation: [
      isRequired(),
      minLength(3, message: 'Informe seu nome completo'),
    ],
  ),
  InputField(
    name: 'email',
    hint: 'E-mail',
    type: InputType.email,
    validation: [isRequired(), isEmail()],
  ),
  InputField(
    name: 'senha',
    hint: 'Senha',
    type: InputType.password,
    validation: [
      isRequired(),
      isPassword(min: 8, requireDigit: true),
    ],
  ),
  InputField(
    name: 'confirmar',
    hint: 'Confirmar senha',
    type: InputType.password,
    validation: [
      isRequired(),
      sameAs('senha', message: 'As senhas não conferem'),
    ],
  ),
];
