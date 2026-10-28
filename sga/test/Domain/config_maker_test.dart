import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

void main() {
  test('o padrão é catálogo com valores visíveis', () {
    const c = ConfigMakerModel();
    expect(c.modalidade, ModalidadePedido.catalogo);
    expect(c.exibirValores, isTrue);
  });

  test('exibirValores exige catálogo ligado, mas a preferência é guardada', () {
    final manual = const ConfigMakerModel().copyWith(usaCatalogo: false);
    expect(manual.exibirValorSimulado, isTrue);
    expect(manual.exibirValores, isFalse);
    expect(manual.copyWith(usaCatalogo: true).exibirValores, isTrue);
  });

  test('fake grava só o informado', () async {
    final repo = FakeConfigMakerRepository(latencia: Duration.zero);
    await repo.salvar(exibirValorSimulado: false);
    final c = await repo.salvar(usaCatalogo: false);
    expect((c.usaCatalogo, c.exibirValorSimulado), (false, false));
    expect(await repo.carregar(), c);
  });
}
