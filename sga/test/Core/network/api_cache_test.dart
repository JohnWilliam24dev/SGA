import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Core/core.dart';

void main() {
  late DateTime agora;
  late ApiCache cache;
  var chamadas = 0;

  Future<dynamic> busca() async => 'v${++chamadas}';

  setUp(() {
    agora = DateTime(2026, 10, 28, 12);
    chamadas = 0;
    cache = ApiCache(agora: () => agora);
  });

  test('dentro de 1 minuto devolve o guardado sem buscar de novo', () async {
    expect(await cache.obter('k', busca), 'v1');
    agora = agora.add(const Duration(seconds: 59));
    expect(await cache.obter('k', busca), 'v1');
    expect(chamadas, 1);
  });

  test('passado 1 minuto busca de novo', () async {
    await cache.obter('k', busca);
    agora = agora.add(const Duration(minutes: 1));
    expect(await cache.obter('k', busca), 'v2');
    expect(chamadas, 2);
  });

  test('chaves diferentes não se misturam', () async {
    expect(await cache.obter('a', busca), 'v1');
    expect(await cache.obter('b', busca), 'v2');
  });

  test('leituras iguais ao mesmo tempo viram uma só chamada', () async {
    final r = await Future.wait([
      cache.obter('k', busca),
      cache.obter('k', busca),
      cache.obter('k', busca),
    ]);
    expect(r, ['v1', 'v1', 'v1']);
    expect(chamadas, 1);
  });

  test('ignorar busca de novo e atualiza o guardado', () async {
    await cache.obter('k', busca);
    expect(await cache.obter('k', busca, ignorar: true), 'v2');
    expect(await cache.obter('k', busca), 'v2');
    expect(chamadas, 2);
  });

  test('limpar esvazia o guardado', () async {
    await cache.obter('k', busca);
    cache.limpar();
    expect(await cache.obter('k', busca), 'v2');
  });

  test('leitura em andamento quando limpa não é guardada (seria dado velho)', () async {
    final lenta = cache.obter('k', () async {
      await Future<void>.delayed(Duration.zero);
      return 'velho';
    });
    cache.limpar();
    expect(await lenta, 'velho');
    expect(await cache.obter('k', busca), 'v1');
  });

  test('erro não fica guardado', () async {
    await expectLater(
      cache.obter('k', () async => throw StateError('falhou')),
      throwsStateError,
    );
    expect(await cache.obter('k', busca), 'v1');
  });
}
