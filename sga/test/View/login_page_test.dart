import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/auth/login_page.dart';

import '../support/helpers.dart';

Widget _login({
  ValueChanged<Credenciais>? onLogin,
  VoidCallback? onForgotPassword,
  Future<void> Function()? onGoogle,
}) {
  return sgaHome(
    LoginPage(
      onLogin: onLogin ?? (_) {},
      onForgotPassword: onForgotPassword ?? () {},
      onGoToRegister: () {},
      onBack: () {},
      onGoogle: onGoogle,
    ),
  );
}

void main() {
  testWidgets('enviar vazio revela os erros e não faz login', (tester) async {
    useTallViewport(tester);
    Credenciais? recebido;
    await tester.pumpWidget(_login(onLogin: (c) => recebido = c));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsNWidgets(2));
    expect(recebido, isNull);
  });

  testWidgets('e-mail inválido mostra a mensagem', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_login());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'maria');
    await tester.pump();
    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('dados válidos entregam as credenciais', (tester) async {
    useTallViewport(tester);
    Credenciais? recebido;
    await tester.pumpWidget(_login(onLogin: (c) => recebido = c));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'maria@exemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'senha1234');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
      recebido,
      const Credenciais(email: 'maria@exemplo.com', senha: 'senha1234'),
    );
  });

  testWidgets('Esqueci a senha está lá e chama o callback', (tester) async {
    useTallViewport(tester);
    var chamado = false;
    await tester.pumpWidget(_login(onForgotPassword: () => chamado = true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Esqueci a senha'));
    expect(chamado, isTrue);
  });

  testWidgets('sem provedor do Google, o botão não aparece', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_login());
    await tester.pumpAndSettle();
    expect(find.text('Entrar com Google'), findsNothing);
  });

  testWidgets('com provedor, o botão do Google chama onGoogle', (tester) async {
    useTallViewport(tester);
    var chamou = 0;
    await tester.pumpWidget(_login(onGoogle: () async => chamou++));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar com Google'));
    await tester.pump();

    expect(chamou, 1);
  });
}
