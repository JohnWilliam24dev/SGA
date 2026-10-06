import 'package:flutter/material.dart' show AppBar, Drawer, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Shared/shared.dart';

import '../support/helpers.dart';

const _destinos = [
  NavDestination(id: 'commissions', label: 'Commissions', icon: Icons.view_kanban_outlined),
  NavDestination(id: 'clientes', label: 'Clientes', icon: Icons.people_outline),
];

Widget _app({ValueChanged<String>? onSelect, VoidCallback? onLogout}) {
  return sgaHome(
    AdaptiveDrawerScaffold(
      destinations: _destinos,
      selectedId: 'commissions',
      onSelect: onSelect ?? (_) {},
      title: 'Commissions',
      body: const Text('conteudo'),
      onLogout: onLogout,
    ),
  );
}

void _viewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('tablet e desktop', () {
    testWidgets('a navegação é uma barra lateral fixa ao lado do conteúdo', (tester) async {
      _viewport(tester, const Size(1000, 800));
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Clientes'), findsOneWidget);
      expect(find.text('conteudo'), findsOneWidget);

      // O conteúdo fica à direita da barra lateral.
      final conteudo = tester.getTopLeft(find.text('conteudo')).dx;
      expect(conteudo, greaterThanOrEqualTo(AdaptiveDrawerScaffold.sidebarWidth));
    });

    testWidgets('tocar num destino avisa a seleção', (tester) async {
      _viewport(tester, const Size(1000, 800));
      String? escolhido;
      await tester.pumpWidget(_app(onSelect: (id) => escolhido = id));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clientes'));
      expect(escolhido, 'clientes');
    });

    testWidgets('Sair aparece quando há onLogout', (tester) async {
      _viewport(tester, const Size(1000, 800));
      var saiu = false;
      await tester.pumpWidget(_app(onLogout: () => saiu = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair'));
      expect(saiu, isTrue);
    });
  });

  group('celular', () {
    testWidgets('começa sem o menu e o abre pelo botão da barra', (tester) async {
      _viewport(tester, const Size(400, 800));
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);
      expect(find.text('Clientes'), findsNothing);

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('Clientes'), findsOneWidget);
    });

    testWidgets('escolher um destino avisa e fecha o drawer', (tester) async {
      _viewport(tester, const Size(400, 800));
      String? escolhido;
      await tester.pumpWidget(_app(onSelect: (id) => escolhido = id));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clientes'));
      await tester.pumpAndSettle();

      expect(escolhido, 'clientes');
      expect(find.byType(Drawer), findsNothing);
    });
  });
}
