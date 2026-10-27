import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/profile/maker_profile_page.dart';

import '../support/helpers.dart';

const _maker = Maker(
  nome: 'joao',
  email: 'joao@gmail.com',
  aceitouTermos: true,
);

Future<void> _avancar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('mostra identidade, o que faz e não faz e os termos', (
    tester,
  ) async {
    useTallViewport(tester);
    await tester.pumpWidget(
      sgaHome(MakerProfilePage(maker: _maker, onMakerChanged: (_) {})),
    );
    await _avancar(tester);

    expect(find.text('joao'), findsOneWidget);
    expect(find.text('joao@gmail.com'), findsOneWidget);
    expect(find.text('Como você trabalha'), findsOneWidget);
    expect(find.text('Eu faço'), findsOneWidget);
    expect(find.text('Eu não faço'), findsOneWidget);
    expect(find.text('Capas de álbum'), findsOneWidget);
    expect(find.text('Termos de serviço'), findsOneWidget);
  });

  testWidgets('Cancelar no Editar perfil fecha sem salvar', (tester) async {
    useTallViewport(tester);
    var mudou = false;
    await tester.pumpWidget(
      sgaHome(MakerProfilePage(maker: _maker, onMakerChanged: (_) => mudou = true)),
    );
    await _avancar(tester);

    await tester.tap(find.text('Editar perfil'));
    await _avancar(tester);
    expect(find.text('Nome completo'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await _avancar(tester);

    expect(find.text('Nome completo'), findsNothing);
    expect(find.text('Campo obrigatório'), findsNothing);
    expect(mudou, isFalse);
  });

  testWidgets('o lápis abre o editor e adicionar um item guarda no Maker', (
    tester,
  ) async {
    useTallViewport(tester);
    Maker? salvo;
    await tester.pumpWidget(
      sgaHome(MakerProfilePage(maker: _maker, onMakerChanged: (m) => salvo = m)),
    );
    await _avancar(tester);

    await tester.tap(find.byTooltip('Editar lista').first);
    await _avancar(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Novo item'),
      'Aquarela',
    );
    await tester.tap(find.text('Adicionar'));
    await _avancar(tester);

    expect(salvo?.faz, contains('Aquarela'));
    expect(find.text('Aquarela'), findsWidgets);
  });
}
