import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Size, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/View/products/products_page.dart';

import '../support/helpers.dart';

Widget _page(Widget child) => sgaHome(Tela(child: child));

void _useDesktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('no desktop, cadastro e catálogo aparecem lado a lado', (
    tester,
  ) async {
    _useDesktopViewport(tester);

    await tester.pumpWidget(_page(const ProductsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar produto'), findsOneWidget);
    expect(find.text('Salvar Produto'), findsOneWidget);
    expect(find.text('Meus produtos'), findsOneWidget);
    expect(find.text('Modelo 3D Vroid completo'), findsOneWidget);
    expect(find.text('Editar'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('no celular, um menu leva ao cadastro e volta', (tester) async {
    useMobileViewport(tester);

    await tester.pumpWidget(_page(const ProductsPage()));
    await tester.pumpAndSettle();
    expect(find.text('O que você gostaria de fazer?'), findsOneWidget);
    expect(find.text('Salvar Produto'), findsNothing);

    await tester.tap(find.text('Adicionar Produto'));
    await tester.pumpAndSettle();
    expect(find.text('Salvar Produto'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar para produtos'));
    await tester.pumpAndSettle();
    expect(find.text('O que você gostaria de fazer?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no celular, o menu abre Meus produtos', (tester) async {
    useMobileViewport(tester);

    await tester.pumpWidget(_page(const ProductsPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus produtos'));
    await tester.pumpAndSettle();

    expect(find.text('Modelo 3D Vroid completo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('salvar vazio revela os erros e não adiciona produto', (
    tester,
  ) async {
    _useDesktopViewport(tester);

    await tester.pumpWidget(_page(const ProductsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar Produto'));
    await tester.pumpAndSettle();

    // Nome e tipo obrigatórios; a imagem tem a própria mensagem.
    expect(find.text('Campo obrigatório'), findsNWidgets(2));
    expect(find.text('Selecione uma imagem'), findsOneWidget);
    expect(find.text('Produto adicionado.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
