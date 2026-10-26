import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

void main() {
  test('codifica as duas listas num texto legível', () {
    expect(
      codificarEscopo(['Ilustração', 'Emotes'], ['Imitar estilo']),
      'Faço:\n- Ilustração\n- Emotes\n\nNão faço:\n- Imitar estilo',
    );
  });

  test('lista vazia não deixa cabeçalho solto', () {
    expect(codificarEscopo(['A'], []), 'Faço:\n- A');
    expect(codificarEscopo([], ['B']), 'Não faço:\n- B');
    expect(codificarEscopo([], []), '');
  });

  test('decodificar desfaz o que codificar fez', () {
    final texto = codificarEscopo(['A', 'B C'], ['D']);
    final r = decodificarEscopo(texto);
    expect((r.faz, r.naoFaz), (['A', 'B C'], ['D']));
  });

  test('só uma das listas também volta certo', () {
    final r = decodificarEscopo(codificarEscopo([], ['Só isto']));
    expect((r.faz, r.naoFaz), (<String>[], ['Só isto']));
  });

  test('texto vazio ou nulo dá listas vazias', () {
    expect(decodificarEscopo(null).faz, isEmpty);
    expect(decodificarEscopo('  \n ').naoFaz, isEmpty);
  });

  test('texto livre escrito em outro lugar não se perde: vira um item de faço', () {
    final r = decodificarEscopo('Faço retratos e não faço NSFW');
    expect((r.faz, r.naoFaz), (['Faço retratos e não faço NSFW'], <String>[]));
  });

  test('o limite é o da API', () => expect(limiteEscopoTexto, 2000));
}
