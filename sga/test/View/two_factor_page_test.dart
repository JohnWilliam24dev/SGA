import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/View/auth/two_factor_page.dart';

import '../support/helpers.dart';

Widget _pagina(void Function(String, bool) onSubmit) =>
    sgaHome(TwoFactorPage(onSubmit: onSubmit, onBack: () {}));

void main() {
  testWidgets('enviar vazio mostra o erro e não confirma', (tester) async {
    useTallViewport(tester);
    String? recebido;
    await tester.pumpWidget(_pagina((c, _) => recebido = c));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
    expect(recebido, isNull);
  });

  testWidgets('código com menos de 6 dígitos é recusado', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_pagina((_, _) {}));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '12345');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Digite os 6 dígitos'), findsOneWidget);
  });

  testWidgets('código de 6 dígitos é entregue como código do app', (tester) async {
    useTallViewport(tester);
    (String, bool)? recebido;
    await tester.pumpWidget(_pagina((c, r) => recebido = (c, r)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), ' 123456 ');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(recebido, ('123456', false));
  });

  testWidgets('alternar aceita código de recuperação', (tester) async {
    useTallViewport(tester);
    (String, bool)? recebido;
    await tester.pumpWidget(_pagina((c, r) => recebido = (c, r)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usar um código de recuperação'));
    await tester.pumpAndSettle();
    expect(find.text('Usar o código do aplicativo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ABCDEF123456');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(recebido, ('ABCDEF123456', true));
  });
}
