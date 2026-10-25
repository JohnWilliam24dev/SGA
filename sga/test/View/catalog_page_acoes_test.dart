import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/catalog/catalog_page.dart';

import '../support/helpers.dart';

class _Repo extends FakeCatalogoAdminRepository {
  _Repo({this.recusa = false, this.falhaAoListar = false});

  final bool recusa;
  final bool falhaAoListar;
  final habilitados = <String, bool>{};

  @override
  Future<List<TipoCatalogado>> listarTipos() async {
    if (falhaAoListar) throw const CatalogoRegraException('Servidor fora do ar');
    return super.listarTipos();
  }

  @override
  Future<void> definirTipoHabilitado(String id, bool habilitado) async {
    if (recusa) throw const CatalogoRegraException('Não pode desabilitar agora');
    habilitados[id] = habilitado;
    return super.definirTipoHabilitado(id, habilitado);
  }
}

Widget _pagina(CatalogoAdminRepository repo) =>
    sgaHome(Scaffold(body: CatalogPage(repository: repo)));

Future<void> _avancar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('o interruptor grava no repositório', (tester) async {
    useTallViewport(tester);
    final repo = _Repo();
    await tester.pumpWidget(_pagina(repo));
    await _avancar(tester);

    await tester.tap(find.byType(Switch).first); // Ilustração, habilitada
    await _avancar(tester);

    expect(repo.habilitados, {'type-ilustracao': false});
    expect(find.text('Desabilitado'), findsNWidgets(2));
  });

  testWidgets('se o servidor recusar, o interruptor volta e avisa', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_pagina(_Repo(recusa: true)));
    await _avancar(tester);

    await tester.tap(find.byType(Switch).first);
    await _avancar(tester);

    expect(find.text('Não pode desabilitar agora'), findsOneWidget);
    expect(find.text('Desabilitado'), findsOneWidget); // só o Modelo 3D, como antes
  });

  testWidgets('falha ao carregar mostra o erro e Tentar de novo', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_pagina(_Repo(falhaAoListar: true)));
    await _avancar(tester);

    expect(find.text('Servidor fora do ar'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text('Novo tipo'), findsNothing);
  });
}
