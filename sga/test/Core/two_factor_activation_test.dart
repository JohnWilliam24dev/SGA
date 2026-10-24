import 'package:easy_ui/easy_ui.dart' show Toggle, UserFacingException;
import 'package:flutter/material.dart' show TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/auth/two_factor_setup_page.dart';
import 'package:sga/View/commissions/commissions_page.dart';

import '../support/fake_adapter.dart';
import '../support/fake_auth_2fa.dart';
import '../support/helpers.dart';

/// Avança ~1 s sem assentar tudo, para o toast (4 s) continuar na tela.
Future<void> _aguardar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<SessaoStore> _abrir(WidgetTester tester) async {
  useTallViewport(tester);
  final sessao = SessaoStore(MemoryTokenStorage(tokensRestrita));
  await tester.pumpWidget(SgaApp(sessao: sessao, auth: Auth2fa(sessao)));
  await tester.pumpAndSettle();
  return sessao;
}

void main() {
  testWidgets('mostra o QR e a chave agrupada', (tester) async {
    await _abrir(tester);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('JBSW Y3DP EHPK 3PXP'), findsOneWidget);
  });

  testWidgets('código errado mostra a mensagem e não revela os códigos', (
    tester,
  ) async {
    await _abrir(tester);
    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.text('Ativar'));
    await _aguardar(tester);

    expect(find.text('Código inválido'), findsOneWidget);
    expect(find.text('Guarde seus códigos de recuperação'), findsNothing);
  });

  testWidgets('ativar mostra os 8 códigos e só abre o app depois de guardá-los', (
    tester,
  ) async {
    await _abrir(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Ativar'));
    await _aguardar(tester);

    for (final c in FakeDoisFatorRepository.codigosRecuperacao) {
      expect(find.text(c), findsOneWidget);
    }
    expect(find.byType(CommissionsPage), findsNothing);

    await tester.tap(find.text('Continuar'));
    await tester.pump();
    expect(find.text('Confirme que guardou os códigos.'), findsOneWidget);
    expect(find.byType(CommissionsPage), findsNothing);

    await tester.tap(find.byType(Toggle));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await _aguardar(tester);

    expect(find.byType(CommissionsPage), findsOneWidget);
  });

  testWidgets('conta que já tem 2FA só pede para continuar', (tester) async {
    useTallViewport(tester);
    var concluiu = false;
    await tester.pumpWidget(sgaHome(TwoFactorSetupPage(
      onCarregar: () async => null,
      onConfirmar: (_) async => [],
      onConcluir: () async => concluiu = true,
      onLogout: () {},
    )));
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsNothing);
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    expect(concluiu, isTrue);
  });

  testWidgets('falha ao carregar mostra o erro e Tentar de novo recarrega', (
    tester,
  ) async {
    useTallViewport(tester);
    var chamadas = 0;
    await tester.pumpWidget(sgaHome(TwoFactorSetupPage(
      onCarregar: () async {
        if (++chamadas == 1) throw const UserFacingException('Sem conexão');
        return const DoisFatorInicio(segredo: 'ABCD', uri: 'otpauth://x');
      },
      onConfirmar: (_) async => [],
      onConcluir: () async {},
      onLogout: () {},
    )));
    await tester.pumpAndSettle();
    expect(find.text('Sem conexão'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(chamadas, 2);
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
