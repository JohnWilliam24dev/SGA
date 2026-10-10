import 'package:flutter/material.dart' show ElevatedButton, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/View/auth/login_page.dart';
import 'package:sga/View/auth/register_page.dart';
import 'package:sga/View/commissions/commission_detail_page.dart';
import 'package:sga/View/commissions/commissions_page.dart';
import 'package:sga/View/welcome/welcome_page.dart';

import 'support/helpers.dart';

void main() {
  testWidgets('começa na tela inicial', (tester) async {
    await tester.pumpWidget(const SgaApp());
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('Cadastre-se leva ao cadastro', (tester) async {
    await tester.pumpWidget(const SgaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('Login leva ao login e Voltar retorna', (tester) async {
    await tester.pumpWidget(const SgaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('login válido abre o app em Commissions e Sair volta ao início', (
    tester,
  ) async {
    useTallViewport(tester);
    await tester.pumpWidget(const SgaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'maria@exemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'senha1234');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.byType(CommissionsPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('Fila'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets(
    'tocar num card abre o detalhe em modal e fechar retorna ao quadro',
    (tester) async {
      useTallViewport(tester);
      await tester.pumpWidget(const SgaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'maria@exemplo.com');
      await tester.enterText(find.byType(TextField).at(1), 'senha1234');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Marina Costa'));
      await tester.pumpAndSettle();

      expect(find.byType(CommissionDetailPage), findsOneWidget);
      expect(find.text('Ainda não fechado'), findsOneWidget);

      await tester.tap(find.byTooltip('Fechar detalhes'));
      await tester.pumpAndSettle();
      expect(find.byType(CommissionDetailPage), findsNothing);
      expect(find.byType(CommissionsPage), findsOneWidget);
    },
  );
}
