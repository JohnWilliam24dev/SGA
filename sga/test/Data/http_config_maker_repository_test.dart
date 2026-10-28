import 'package:dio/dio.dart' show RequestOptions, ResponseBody;
import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';
import 'package:sga/Data/data.dart';
import 'package:sga/Domain/domain.dart';

import '../support/fake_adapter.dart';

({HttpConfigMakerRepository repo, FakeAdapter adapter}) _montar(
  Future<ResponseBody> Function(RequestOptions) responder,
) {
  final adapter = FakeAdapter(responder);
  final client = clienteDe(adapter, MemoryTokenStorage(tokensA1));
  return (repo: HttpConfigMakerRepository(client), adapter: adapter);
}

void main() {
  test('carregar lê as duas chaves de GET /config-maker', () async {
    final t = _montar((_) async =>
        jsonBody({'usaCatalogo': false, 'exibirValorSimulado': true}, 200));

    final c = await t.repo.carregar();

    expect(t.adapter.chamadas.single.path, '/config-maker');
    expect((c.usaCatalogo, c.exibirValorSimulado), (false, true));
    expect(c.modalidade, ModalidadePedido.manual);
    expect(c.exibirValores, isFalse);
  });

  test('salvar manda só o que mudou e devolve o estado final', () async {
    final t = _montar((_) async =>
        jsonBody({'usaCatalogo': true, 'exibirValorSimulado': false}, 200));

    final c = await t.repo.salvar(exibirValorSimulado: false);

    final req = t.adapter.chamadas.single;
    expect((req.method, req.path), ('PATCH', '/config-maker'));
    expect(Map<String, dynamic>.from(req.data as Map), {'exibirValorSimulado': false});
    expect((c.usaCatalogo, c.exibirValorSimulado), (true, false));
    expect(c.exibirValores, isFalse);
  });

  test('400 do servidor chega com a mensagem dele', () async {
    final t = _montar((_) async => jsonBody({'error': 'Informe ao menos um campo.'}, 400));
    await expectLater(
      t.repo.salvar(),
      throwsA(isA<ApiException>().having((e) => e.mensagem, 'mensagem', 'Informe ao menos um campo.')),
    );
  });
}
