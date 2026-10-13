import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/View/products/products_page.dart';

import '../support/helpers.dart';

Widget _page(Widget child) => sgaHome(Tela(child: child));

void main() {
  testWidgets('no celular, cadastro e catálogo aparecem empilhados', (
    tester,
  ) async {
    useMobileViewport(tester);

    await tester.pumpWidget(_page(const ProductsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Produto'), findsOneWidget);
    expect(find.text('Salvar Produto'), findsOneWidget);
    expect(find.text('Meus Produtos'), findsOneWidget);
    expect(find.text('Modelo 3D Vroid completo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('salvar vazio revela os erros e não adiciona produto', (
    tester,
  ) async {
    useMobileViewport(tester);

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
