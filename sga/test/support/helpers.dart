import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Core/core.dart';

/// Monta [home] dentro de um EasyApp com o tema e o pack do SGA.
Widget sgaHome(Widget home) {
  return EasyApp(theme: sgaTheme, stylePack: sgaPack, home: home);
}

/// Viewport alta o bastante para o formulário de cadastro caber sem rolar.
void useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> preencherCadastro(
  WidgetTester tester, {
  String nome = 'Maria Silva',
  String email = 'maria@exemplo.com',
  String senha = 'Senha1234',
  String confirmar = 'Senha1234',
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nome);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), senha);
  await tester.enterText(campos.at(3), confirmar);
  await tester.pump();
}
