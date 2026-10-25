import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

final _png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
final _jpg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00]);
final _webp = Uint8List.fromList([...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits]);

void main() {
  test('reconhece PNG, JPEG e WebP pelos bytes', () {
    expect(mimeDaImagem(_png), 'image/png');
    expect(mimeDaImagem(_jpg), 'image/jpeg');
    expect(mimeDaImagem(_webp), 'image/webp');
    expect(mimeDaImagem(Uint8List.fromList([1, 2, 3])), isNull);
    expect(mimeDaImagem(Uint8List(0)), isNull);
  });

  test('extensão de cada tipo', () {
    expect(extensaoDaImagem('image/png'), 'png');
    expect(extensaoDaImagem('image/webp'), 'webp');
    expect(extensaoDaImagem('image/jpeg'), 'jpg');
  });

  test('imagem válida não tem erro', () => expect(erroDaImagem(_png), isNull));

  test('formato desconhecido é recusado', () {
    expect(erroDaImagem(Uint8List.fromList([1, 2, 3, 4])), contains('PNG, JPG ou WebP'));
  });

  test('passou de 4 MB é recusada, 4 MB exatos passam', () {
    Uint8List com(int tamanho) => Uint8List(tamanho)..setAll(0, _png);
    expect(erroDaImagem(com(limiteImagemBytes)), isNull);
    expect(erroDaImagem(com(limiteImagemBytes + 1)), contains('4 MB'));
  });
}
