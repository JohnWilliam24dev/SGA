import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/View/settings/settings_page.dart';

import '../support/helpers.dart';

void main() {
  testWidgets('Configurações mostra o estado do 2FA e gera novos códigos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = FakeDoisFatorRepository(SessaoStore(MemoryTokenStorage(null)));

    await tester.pumpWidget(
      sgaHome(Tela(child: SettingsPage(doisFator: repo))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Segurança'), findsOneWidget);
    expect(find.textContaining('ativada'), findsOneWidget);
    expect(find.textContaining('restantes: 8'), findsOneWidget);

    await tester.tap(find.text('Gerar novos códigos de recuperação'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).at(0), '123456');
    await tester.enterText(find.byType(EditableText).at(1), 'Senha12345');
    await tester.tap(find.text('Gerar códigos'));
    await tester.pumpAndSettle();

    expect(find.text(FakeDoisFatorRepository.codigosRecuperacao.first), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem repositório de 2FA a seção Segurança não aparece', (
    tester,
  ) async {
    await tester.pumpWidget(sgaHome(const Tela(child: SettingsPage())));
    await tester.pumpAndSettle();
    expect(find.text('Segurança'), findsNothing);
  });
}
