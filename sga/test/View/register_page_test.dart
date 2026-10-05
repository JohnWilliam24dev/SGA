import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/auth/register_page.dart';

import '../support/helpers.dart';

Widget _cadastro({ValueChanged<Maker>? onRegister}) {
  return sgaHome(
    RegisterPage(
      onRegister: onRegister ?? (_) {},
      onGoToLogin: () {},
      onBack: () {},
    ),
  );
}

void main() {
  testWidgets('enviar vazio revela os erros dos quatro campos', (tester) async {
    useTallViewport(tester);
    Maker? recebido;
    await tester.pumpWidget(_cadastro(onRegister: (m) => recebido = m));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsNWidgets(4));
    expect(recebido, isNull);
  });

  testWidgets('confirmação diferente da senha mostra erro', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_cadastro());
    await tester.pumpAndSettle();

    await preencherCadastro(tester, confirmar: 'Outra1234');
    expect(find.text('As senhas não conferem'), findsOneWidget);
  });

  testWidgets('sem aceitar os termos não cadastra e avisa', (tester) async {
    useTallViewport(tester);
    Maker? recebido;
    await tester.pumpWidget(_cadastro(onRegister: (m) => recebido = m));
    await tester.pumpAndSettle();

    await preencherCadastro(tester);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(recebido, isNull);
    expect(find.text('Você precisa aceitar os termos de uso.'), findsOneWidget);
  });

  testWidgets('tudo válido e termos aceitos entregam o Maker', (tester) async {
    useTallViewport(tester);
    Maker? recebido;
    await tester.pumpWidget(_cadastro(onRegister: (m) => recebido = m));
    await tester.pumpAndSettle();

    await preencherCadastro(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(
      recebido,
      const Maker(
        nome: 'Maria Silva',
        email: 'maria@exemplo.com',
        senha: 'Senha1234',
        aceitouTermos: true,
      ),
    );
    expect(find.text('Você precisa aceitar os termos de uso.'), findsNothing);
  });
}
