import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ui/easy_ui.dart';
import 'package:sga/Core/network/network.dart';
import 'package:sga/View/settings/settings_page.dart';

import '../support/helpers.dart';

void main() {
  void telaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('vincular conta Google chama o callback e confirma', (tester) async {
    telaAlta(tester);
    var chamou = 0;
    await tester.pumpWidget(sgaHome(Tela(
      child: SettingsPage(onVincularGoogle: () async => ++chamou > 0),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vincular conta Google'));
    await tester.pumpAndSettle();

    expect(chamou, 1);
    expect(find.text('Conta Google vinculada.'), findsOneWidget);
  });

  testWidgets('desistir do Google não mostra aviso nem erro', (tester) async {
    telaAlta(tester);
    await tester.pumpWidget(sgaHome(Tela(
      child: SettingsPage(onVincularGoogle: () async => false),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vincular conta Google'));
    await tester.pumpAndSettle();

    expect(find.text('Conta Google vinculada.'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('erro da API aparece com a mensagem do servidor', (tester) async {
    telaAlta(tester);
    await tester.pumpWidget(sgaHome(Tela(
      child: SettingsPage(
        onVincularGoogle: () async => throw const ApiException(
          tipo: ApiErroTipo.conflito,
          status: 409,
          mensagem: 'Esta conta Google já está vinculada a outro usuário.',
        ),
      ),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Vincular conta Google'));
    await tester.pumpAndSettle();

    expect(find.textContaining('já está vinculada'), findsOneWidget);
  });

  testWidgets('sem callback, a seção Conta Google não aparece', (tester) async {
    await tester.pumpWidget(sgaHome(const Tela(child: SettingsPage())));
    await tester.pumpAndSettle();
    expect(find.text('Conta Google'), findsNothing);
  });
}
