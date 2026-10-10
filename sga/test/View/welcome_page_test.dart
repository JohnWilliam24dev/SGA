import 'package:flutter_test/flutter_test.dart';
import 'package:sga/View/welcome/welcome_page.dart';

import '../support/helpers.dart';

void main() {
  testWidgets('mostra a marca e os dois botões', (tester) async {
    await tester.pumpWidget(
      sgaHome(WelcomePage(onRegister: () {}, onLogin: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('SGA'), findsOneWidget);
    expect(find.text('Sistema de Gerenciamento Artístico'), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('cada botão chama o seu callback', (tester) async {
    var cadastro = 0;
    var login = 0;
    await tester.pumpWidget(
      sgaHome(
        WelcomePage(onRegister: () => cadastro++, onLogin: () => login++),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastre-se'));
    await tester.tap(find.text('Login'));
    expect(cadastro, 1);
    expect(login, 1);
  });
}
