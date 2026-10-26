/// Tamanho máximo do campo "faço e não faço" na API.
const limiteEscopoTexto = 2000;

const _cabecalhoFaz = 'Faço:';
const _cabecalhoNaoFaz = 'Não faço:';

/// A API guarda "faço e não faço" num texto só (`facoENaoFaco`); o app o
/// mostra como duas listas. O texto sai assim, legível também onde a API o
/// exibir como está:
///
/// ```
/// Faço:
/// - Ilustração digital
///
/// Não faço:
/// - Imitar o estilo de outro artista
/// ```
String codificarEscopo(List<String> faz, List<String> naoFaz) {
  String bloco(String titulo, List<String> itens) =>
      itens.isEmpty ? '' : '$titulo\n${itens.map((i) => '- $i').join('\n')}';
  return [
    bloco(_cabecalhoFaz, faz),
    bloco(_cabecalhoNaoFaz, naoFaz),
  ].where((b) => b.isNotEmpty).join('\n\n');
}

/// Lê o texto da API de volta em duas listas. Um texto que não segue o
/// formato acima (escrito em outro lugar) não se perde: vira um item único
/// de "faço".
({List<String> faz, List<String> naoFaz}) decodificarEscopo(String? texto) {
  final limpo = (texto ?? '').trim();
  if (limpo.isEmpty) return (faz: <String>[], naoFaz: <String>[]);
  final faz = <String>[];
  final naoFaz = <String>[];
  List<String>? atual;
  var estruturado = false;
  for (final linha in limpo.split('\n').map((l) => l.trim())) {
    if (linha == _cabecalhoFaz) {
      atual = faz;
      estruturado = true;
    } else if (linha == _cabecalhoNaoFaz) {
      atual = naoFaz;
      estruturado = true;
    } else if (atual != null && linha.startsWith('- ')) {
      atual.add(linha.substring(2).trim());
    }
  }
  return estruturado ? (faz: faz, naoFaz: naoFaz) : (faz: [limpo], naoFaz: <String>[]);
}
