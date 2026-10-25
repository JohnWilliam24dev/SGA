import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' show Size, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/products/products_page.dart';

import '../support/helpers.dart';

ProdutoModel _p(String id, String nome) => ProdutoModel(
      id: id, nome: nome, imagemUrl: '', tipoProdutoId: 'type-ilustracao',
    );

/// Portfólio com 3 produtos no total, mas só o primeiro na primeira página.
class _Paginado extends FakeProdutoRepository {
  _Paginado({this.falha});

  final String? falha;
  final offsets = <int>[];

  @override
  Future<Pagina<ProdutoModel>> listar({int offset = 0}) async {
    if (falha != null) throw ProdutoRegraException(falha!);
    offsets.add(offset);
    return offset == 0
        ? Pagina(itens: [_p('p1', 'Arte Um')], total: 3, temMais: true)
        : Pagina(itens: [_p('p2', 'Arte Dois'), _p('p3', 'Arte Três')], total: 3, temMais: false);
  }
}

Widget _page(FakeProdutoRepository repo) => sgaHome(Tela(child: ProductsPage(produtos: repo)));

void _viewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Carregar mais junta a próxima página e some quando acaba', (tester) async {
    _viewport(tester);
    final repo = _Paginado();
    await tester.pumpWidget(_page(repo));
    await tester.pumpAndSettle();

    expect(find.text('Carregar mais (2)'), findsOneWidget);
    expect(find.text('Arte Dois'), findsNothing);

    await tester.tap(find.text('Carregar mais (2)'));
    await tester.pumpAndSettle();

    expect(repo.offsets, [0, 1]);
    expect(find.text('Arte Dois'), findsOneWidget);
    expect(find.text('Arte Três'), findsOneWidget);
    expect(find.textContaining('Carregar mais'), findsNothing);
  });

  testWidgets('falha ao carregar mostra o erro e Tentar de novo', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_page(_Paginado(falha: 'Portfólio indisponível')));
    await tester.pumpAndSettle();

    expect(find.text('Portfólio indisponível'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text('Salvar Produto'), findsNothing);
  });

  testWidgets('ao editar, o campo de imagem some (a API não troca a imagem)', (tester) async {
    _viewport(tester);
    await tester.pumpWidget(_page(FakeProdutoRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Imagem do produto'), findsOneWidget);

    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('Salvar alterações'), findsOneWidget);
    expect(find.text('Imagem do produto'), findsNothing);
  });
}
