import 'package:flutter/foundation.dart' show immutable;

/// Uma página de uma lista paginada da API (`{ itens, total, temMais }`).
@immutable
class Pagina<T> {
  const Pagina({required this.itens, required this.total, required this.temMais});

  final List<T> itens;

  /// Quantos itens existem no total (não só nesta página).
  final int total;
  final bool temMais;
}
