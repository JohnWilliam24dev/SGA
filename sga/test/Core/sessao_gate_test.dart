import 'package:flutter/material.dart' show ElevatedButton, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/View/auth/two_factor_page.dart';
import 'package:sga/View/auth/two_factor_setup_page.dart';
import 'package:sga/View/commissions/commissions_page.dart';
import 'package:sga/View/welcome/welcome_page.dart';

import '../support/fake_adapter.dart';
import '../support/fake_auth_2fa.dart';
import '../support/helpers.dart';

/// Avança ~1 s sem esperar tudo assentar, para o toast (4 s) continuar na tela.
Future<void> _aguardar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _entrarComSenha(WidgetTester tester) async {
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), 'maria@exemplo.com');
  await tester.enterText(find.byType(TextField).at(1), 'senha1234');
  await tester.pump();
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sessão completa guardada abre direto o app', (tester) async {
    useTallViewport(tester);
    final sessao = SessaoStore(MemoryTokenStorage(tokensA1));
    await tester.pumpWidget(SgaApp(sessao: sessao, auth: Auth2fa(sessao)));
    await tester.pumpAndSettle();

    expect(find.byType(CommissionsPage), findsOneWidget);
    expect(find.byType(WelcomePage), findsNothing);
  });

  testWidgets('sessão restrita leva à tela de ativar o 2FA e Sair desloga', (
    tester,
  ) async {
    useTallViewport(tester);
    final sessao = SessaoStore(MemoryTokenStorage(tokensRestrita));
    await tester.pumpWidget(SgaApp(sessao: sessao, auth: Auth2fa(sessao)));
    await tester.pumpAndSettle();
    expect(find.byType(TwoFactorSetupPage), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('login com 2FA pede o código, recusa o errado e entra com o certo', (
    tester,
  ) async {
    useTallViewport(tester);
    final sessao = SessaoStore(MemoryTokenStorage());
    await tester.pumpWidget(SgaApp(sessao: sessao, auth: Auth2fa(sessao)));
    await tester.pumpAndSettle();

    await _entrarComSenha(tester);
    expect(find.byType(TwoFactorPage), findsOneWidget);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);
    expect(find.text('Código inválido'), findsOneWidget);
    expect(find.byType(CommissionsPage), findsNothing);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);

    expect(find.byType(CommissionsPage), findsOneWidget);
    expect(find.byType(TwoFactorPage), findsNothing);
  });

  testWidgets('poucos códigos de recuperação geram um aviso ao entrar', (
    tester,
  ) async {
    useTallViewport(tester);
    final sessao = SessaoStore(MemoryTokenStorage());
    await tester.pumpWidget(
      SgaApp(sessao: sessao, auth: Auth2fa(sessao, restantes: 1)),
    );
    await tester.pumpAndSettle();
    await _entrarComSenha(tester);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);

    expect(find.text('Resta só 1 código de recuperação.'), findsOneWidget);
  });

  testWidgets('sessão que expira volta ao início, mesmo no detalhe', (
    tester,
  ) async {
    useTallViewport(tester);
    final sessao = SessaoStore(MemoryTokenStorage(tokensA1));
    await tester.pumpWidget(SgaApp(sessao: sessao, auth: Auth2fa(sessao)));
    await tester.pumpAndSettle();
    expect(find.byType(CommissionsPage), findsOneWidget);

    await sessao.encerrar(); // o que o refresh recusado faz
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
    expect(find.byType(CommissionsPage), findsNothing);
  });
}
