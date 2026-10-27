import 'package:flutter/material.dart' hide Icon, Card, Badge, Divider;
import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/profile/maker_profile_page.dart';

import '../support/helpers.dart';

const _maker = Maker(nome: 'joao', email: 'joao@gmail.com', aceitouTermos: true);

class _Repo implements MakerRepository {
  _Repo({this.locais = const [], this.falha});

  final List<String> locais;
  final String? falha;
  final salvos = <({Maker anterior, Maker novo})>[];

  @override
  Future<Maker> carregar(String makerId) => throw UnimplementedError();

  @override
  Future<List<String>> salvar(String makerId, {required Maker anterior, required Maker novo}) async {
    if (falha != null) throw const CommissionRegraException('Servidor recusou');
    salvos.add((anterior: anterior, novo: novo));
    return locais;
  }
}

Widget _pagina(_Repo repo, [ValueChanged<Maker>? aoMudar]) => sgaHome(
      Scaffold(
        body: MakerProfilePage(maker: _maker, onMakerChanged: aoMudar ?? (_) {}, repository: repo, makerId: 'm1'),
      ),
    );

Future<void> _avancar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _adicionarItem(WidgetTester tester, String item) async {
  await tester.tap(find.byTooltip('Editar lista').first);
  await _avancar(tester);
  await tester.enterText(find.widgetWithText(TextField, 'Novo item'), item);
  await tester.tap(find.text('Adicionar'));
  await _avancar(tester);
}

void main() {
  testWidgets('editar uma lista grava no servidor na hora', (tester) async {
    useTallViewport(tester);
    final repo = _Repo();
    await tester.pumpWidget(_pagina(repo));
    await _avancar(tester);

    await _adicionarItem(tester, 'Aquarela');

    expect(repo.salvos, hasLength(1));
    expect(repo.salvos.single.novo.faz, contains('Aquarela'));
    expect(repo.salvos.single.anterior.faz, isEmpty);
    expect(find.text('Perfil salvo.'), findsOneWidget);
  });

  testWidgets('os termos só são gravados depois de uma pausa na digitação', (tester) async {
    useTallViewport(tester);
    final repo = _Repo();
    await tester.pumpWidget(_pagina(repo));
    await _avancar(tester);

    await tester.enterText(find.byType(TextField), 'Pago');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'Pago antes');
    await tester.pump(const Duration(milliseconds: 500));
    expect(repo.salvos, isEmpty); // ainda digitando

    await tester.pump(const Duration(seconds: 1));

    expect(repo.salvos, hasLength(1));
    expect(repo.salvos.single.novo.termosServico, 'Pago antes');
  });

  testWidgets('campo que o servidor não guarda vira aviso', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_pagina(_Repo(locais: const ['telefone'])));
    await _avancar(tester);

    await _adicionarItem(tester, 'Aquarela');

    expect(find.textContaining('Ainda só vale nesta sessão'), findsOneWidget);
    expect(find.textContaining('telefone'), findsOneWidget);
  });

  testWidgets('falha ao gravar mostra a mensagem do servidor', (tester) async {
    useTallViewport(tester);
    await tester.pumpWidget(_pagina(_Repo(falha: 'x')));
    await _avancar(tester);

    await _adicionarItem(tester, 'Aquarela');

    expect(find.text('Servidor recusou'), findsOneWidget);
  });

  testWidgets('lista que estoura 2.000 caracteres é recusada e não grava', (tester) async {
    useTallViewport(tester);
    final repo = _Repo();
    await tester.pumpWidget(_pagina(repo));
    await _avancar(tester);

    await _adicionarItem(tester, 'x' * 2100);

    expect(repo.salvos, isEmpty);
    expect(find.textContaining('2.000 caracteres'), findsOneWidget);
  });
}
