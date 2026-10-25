import 'dart:typed_data';

/// Tamanho máximo da imagem de um produto (o servidor recusa acima disso).
const limiteImagemBytes = 4 * 1024 * 1024;

/// Tipo da imagem pelos primeiros bytes (PNG, JPEG ou WebP), ou `null` se
/// não for um desses. O servidor também confere os bytes, não o nome.
String? mimeDaImagem(Uint8List b) {
  if (b.length >= 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
    return 'image/png';
  }
  if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
    return 'image/jpeg';
  }
  final riff = b.length >= 12 &&
      String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
      String.fromCharCodes(b.sublist(8, 12)) == 'WEBP';
  return riff ? 'image/webp' : null;
}

/// Motivo de a imagem não servir, ou `null` se está tudo certo.
String? erroDaImagem(Uint8List bytes) {
  if (bytes.length > limiteImagemBytes) return 'A imagem passa de 4 MB.';
  if (mimeDaImagem(bytes) == null) return 'Use uma imagem PNG, JPG ou WebP.';
  return null;
}

/// Extensão de arquivo para o [mime] devolvido por [mimeDaImagem].
String extensaoDaImagem(String mime) => switch (mime) {
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
