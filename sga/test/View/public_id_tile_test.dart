import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ui/easy_ui.dart';
import 'package:sga/View/profile/public_id_tile.dart';

import '../support/helpers.dart';

void main() {
  testWidgets('mostra o ID público e copia para a área de transferência', (tester) async {
    String? copiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiado = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(sgaHome(const Tela(
      child: PublicIdTile(publicId: 'b3f1c2a4-0000-4000-8000-000000000001'),
    )));
    await tester.pumpAndSettle();
    expect(find.text('b3f1c2a4-0000-4000-8000-000000000001'), findsOneWidget);

    await tester.tap(find.text('Copiar'));
    await tester.pumpAndSettle();

    expect(copiado, 'b3f1c2a4-0000-4000-8000-000000000001');
    expect(find.text('ID público copiado.'), findsOneWidget);
  });
}
