import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Size, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/View/products/products_page.dart';

import '../support/helpers.dart';

Widget _page(Widget child) => sgaHome(Tela(child: child));

void main() {
  testWidgets('produtos no mobile separa cadastro e catálogo', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_page(const ProductsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Produto'), findsOneWidget);
    expect(find.text('Meus produtos'), findsOneWidget);

    await tester.tap(find.text('Adicionar Produto'));
    await tester.pumpAndSettle();

    expect(find.text('Tipo do produto'), findsOneWidget);
    expect(find.text('Imagem do produto'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar para produtos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meus produtos'));
    await tester.pumpAndSettle();

    expect(find.text('Modelo 3D Vroid completo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
