import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/main/main_shell.dart';

import '../support/helpers.dart';

void main() {
  testWidgets('trocar várias vezes entre desktop e celular não dá erro', (
    tester,
  ) async {
    final repo = FakeCommissionRepository(latencia: Duration.zero);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(1400, 800);

    await tester.pumpWidget(
      sgaHome(
        MainShell(
          commissionRepository: repo,
          statusRepository: repo.statusRepository,
          onOpenCommission: (_, _) {},
          onLogout: () {},
          maker: const Maker(
            nome: 'Joao',
            email: 'joao@exemplo.com',
            senha: 'x',
            aceitouTermos: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Passa pelos dois breakpoints: o do shell (760) e o do quadro.
    for (final largura in [500.0, 1400.0, 820.0, 400.0, 900.0, 1200.0, 450.0]) {
      tester.view.physicalSize = Size(largura, 800);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'largura $largura');
      expect(find.text('Marina Costa'), findsOneWidget, reason: 'largura $largura');
    }
  });
}
