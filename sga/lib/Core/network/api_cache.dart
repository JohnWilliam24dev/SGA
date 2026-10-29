/// Guarda por pouco tempo as respostas de leitura, para não pedir de novo ao
/// servidor o que o app acabou de receber.
///
/// - Dentro da [validade], a mesma leitura devolve o que já está guardado.
/// - Leituras idênticas ao mesmo tempo viram uma só chamada.
/// - Só respostas de sucesso entram; erro nunca fica guardado.
/// - [limpar] esvazia tudo e invalida as leituras em andamento (nenhuma delas
///   é guardada depois), para não servir dado velho após uma escrita.
///
/// Os valores guardados são o JSON decodificado e são compartilhados: quem
/// lê não deve alterá-los (os mappers copiam antes de mexer).
class ApiCache {
  ApiCache({
    this.validade = const Duration(minutes: 1),
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now;

  final Duration validade;
  final DateTime Function() _agora;
  final _guardado = <String, ({DateTime em, dynamic valor})>{};
  final _emVoo = <String, Future<dynamic>>{};
  int _geracao = 0;

  /// Devolve o guardado (ou a leitura em andamento) ou chama [buscar]. Com
  /// [ignorar], busca de novo e atualiza o que estava guardado.
  Future<dynamic> obter(
    String chave,
    Future<dynamic> Function() buscar, {
    bool ignorar = false,
  }) {
    if (!ignorar) {
      final entrada = _guardado[chave];
      if (entrada != null && _agora().difference(entrada.em) < validade) {
        return Future<dynamic>.value(entrada.valor);
      }
      final emVoo = _emVoo[chave];
      if (emVoo != null) return emVoo;
    }
    final geracao = _geracao;
    final futuro = buscar();
    _emVoo[chave] = futuro;
    return futuro
        .then((valor) {
          if (geracao == _geracao) {
            _guardado[chave] = (em: _agora(), valor: valor);
          }
          return valor;
        })
        .whenComplete(() {
          if (identical(_emVoo[chave], futuro)) _emVoo.remove(chave);
        });
  }

  /// Esvazia o cache (escrita feita, sessão trocada ou encerrada).
  void limpar() {
    _guardado.clear();
    _emVoo.clear();
    _geracao++;
  }
}
