import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/View/catalog/catalog_page.dart';

import '../support/helpers.dart';

Future<void> _avancar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('mostra os tipos com preço, vinculados e o interruptor', (
    tester,
  ) async {
    useTallViewport(tester);
    await tester.pumpWidget(sgaHome(const CatalogPage()));
    await _avancar(tester);

    expect(find.text('Tipos de produtos'), findsWidgets);
    expect(find.text('Ilustração'), findsOneWidget);
    expect(find.text('2 vinculados'), findsOneWidget);
    expect(find.text('1 vinculado'), findsOneWidget);
    expect(find.text('Novo tipo'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(3));
    expect(find.text('Desabilitado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a aba Adicionais mostra valor fixo e porcentagem', (
    tester,
  ) async {
    useTallViewport(tester);
    await tester.pumpWidget(sgaHome(const CatalogPage()));
    await _avancar(tester);

    await tester.tap(find.text('Adicionais').first);
    await _avancar(tester);

    expect(find.text('Fundo detalhado'), findsOneWidget);
    expect(find.text('20% do preço base'), findsOneWidget);
    expect(find.text('Novo adicional'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Novo tipo abre o editor e Cancelar fecha sem criar', (
    tester,
  ) async {
    useTallViewport(tester);
    await tester.pumpWidget(sgaHome(const CatalogPage()));
    await _avancar(tester);

    await tester.tap(find.text('Novo tipo'));
    await _avancar(tester);
    expect(find.text('Novo tipo de produto'), findsOneWidget);
    expect(find.text('Adicionais vinculados'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await _avancar(tester);

    expect(find.text('Novo tipo de produto'), findsNothing);
    expect(find.text('Ilustração'), findsOneWidget);
  });

  testWidgets('tipo já usado não é excluído e avisa o motivo', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(sgaHome(const CatalogPage()));
    await _avancar(tester);

    await tester.tap(find.byTooltip('Excluir').last);
    await _avancar(tester);
    await tester.tap(find.text('Excluir'));
    await _avancar(tester);

    expect(find.textContaining('Este tipo já foi usado'), findsOneWidget);
    expect(find.text('Modelo 3D'), findsOneWidget);
  });
}
