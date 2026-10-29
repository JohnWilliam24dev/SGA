import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter/material.dart' show Checkbox, ElevatedButton, TextField;
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_ui/easy_ui.dart' show Toggle;
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commissions_page.dart';
import 'package:sga/View/welcome/welcome_page.dart';

import 'support/fake_adapter.dart';
import 'support/helpers.dart';

/// Fluxos de ponta a ponta com o servidor falso: auth e 2FA reais (HTTP), e a
/// área logada com os dados simulados.
const _codigos = [
  'AAAAAAAAAA01', 'AAAAAAAAAA02', 'AAAAAAAAAA03', 'AAAAAAAAAA04',
  'AAAAAAAAAA05', 'AAAAAAAAAA06', 'AAAAAAAAAA07', 'AAAAAAAAAA08',
];

class _Servidor {
  _Servidor({this.contaCom2fa = false});

  /// O login pede o desafio de 2FA.
  final bool contaCom2fa;
  final rotas = <String>[];

  Future<ResponseBody> responder(RequestOptions o) async {
    final rota = '${o.method} ${o.path}';
    rotas.add(rota);
    return switch (rota) {
      'POST /auth/cadastro' => jsonBody({
          ...sessaoJson('1'), 'escopo': 'ativar2fa',
          'id': 'm1', 'nome': 'Maria Silva', 'email': 'maria@exemplo.com',
        }, 201),
      'GET /auth/2fa/estado' =>
        jsonBody({'ativo': false, 'codigosRecuperacaoRestantes': 0}, 200),
      'POST /auth/2fa/iniciar' => jsonBody({
          'segredo': 'JBSWY3DPEHPK3PXP',
          'uri': 'otpauth://totp/A-BR:maria@exemplo.com?secret=JBSWY3DPEHPK3PXP',
        }, 200),
      'POST /auth/2fa/confirmar' => jsonBody({'codigosRecuperacao': _codigos}, 200),
      'POST /auth/refresh' => jsonBody(sessaoJson('2'), 200),
      'POST /auth/login' => contaCom2fa
          ? jsonBody({
              'requer2fa': true, 'desafio': 'd1',
              'desafioExpiraEm': '2026-10-28T12:00:00.000Z',
            }, 200)
          : jsonBody(sessaoJson('1'), 200),
      'POST /auth/login/2fa' => jsonBody(
          {...sessaoJson('2'), 'codigosRecuperacaoRestantes': 7}, 200),
      _ => jsonBody({'error': 'Rota não simulada: $rota'}, 404),
    };
  }
}

SgaApp _app(_Servidor servidor, [GoogleSignInProvider? google]) {
  final storage = MemoryTokenStorage();
  final sessao = SessaoStore(storage);
  final client = clienteDe(FakeAdapter(servidor.responder), storage);
  return SgaApp(
    sessao: sessao,
    auth: HttpAuthRepository(client: client, sessao: sessao),
    doisFator: HttpDoisFatorRepository(client: client, sessao: sessao),
    google: google,
  );
}

/// Avança ~1 s sem assentar tudo (toasts de 4 s continuam na tela).
Future<void> _aguardar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _Google implements GoogleSignInProvider {
  @override
  Future<GoogleCredencial?> obter() async =>
      const GoogleCredencial(idToken: 'token-do-google');
}

void main() {
  testWidgets('cadastro → ativação do 2FA → quadro', (tester) async {
    useTallViewport(tester);
    final servidor = _Servidor();
    await tester.pumpWidget(_app(servidor));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();
    await preencherCadastro(tester);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);

    // Todo Maker novo cai na ativação do 2FA antes de entrar no app.
    expect(find.byType(CommissionsPage), findsNothing);
    expect(find.text('JBSW Y3DP EHPK 3PXP'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Ativar'));
    await _aguardar(tester);
    for (final c in _codigos) {
      expect(find.text(c), findsOneWidget);
    }
    expect(find.byType(CommissionsPage), findsNothing);

    await tester.tap(find.byWidgetPredicate((w) => w is Toggle));
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await _aguardar(tester);

    expect(find.byType(CommissionsPage), findsOneWidget);
    expect(find.text('Fila'), findsOneWidget);
    expect(servidor.rotas, containsAllInOrder([
      'POST /auth/cadastro',
      'POST /auth/2fa/iniciar',
      'POST /auth/2fa/confirmar',
      'POST /auth/refresh',
    ]));
  });

  testWidgets('login → desafio do 2FA → quadro', (tester) async {
    useTallViewport(tester);
    final servidor = _Servidor(contaCom2fa: true);
    await tester.pumpWidget(_app(servidor));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'maria@exemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'Senha12345');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);

    expect(find.text('Verificação em duas etapas'), findsOneWidget);
    expect(find.byType(CommissionsPage), findsNothing);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);

    expect(find.byType(CommissionsPage), findsOneWidget);
    expect(servidor.rotas, containsAllInOrder(['POST /auth/login', 'POST /auth/login/2fa']));
  });

  testWidgets('login sem 2FA entra direto no quadro e Sair volta ao início', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_app(_Servidor()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'maria@exemplo.com');
    await tester.enterText(find.byType(TextField).at(1), 'Senha12345');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await _aguardar(tester);
    expect(find.byType(CommissionsPage), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await _aguardar(tester);
    expect(find.byType(WelcomePage), findsOneWidget);
  });

  testWidgets('Entrar com Google abre o app', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(SgaApp(google: _Google()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar com Google'));
    await _aguardar(tester);

    expect(find.byType(CommissionsPage), findsOneWidget);
  });
}
