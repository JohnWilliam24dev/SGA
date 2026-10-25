import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';

/// Carga da tela de Produtos: os tipos (para o seletor) e o portfólio, que a
/// API traz 50 por vez, mais novos primeiro.
mixin ProductsCarga on ChangeNotifier {
  ProdutoRepository get produtos;
  CatalogoAdminRepository get catalogo;

  List<TipoProdutoModel> types = [];
  List<ProdutoModel> products = [];
  int total = 0;
  bool temMais = false;
  bool carregando = true;
  bool carregandoMais = false;

  /// Motivo de a carga inicial ter falhado (a tela mostra "Tentar de novo").
  String? falha;

  int get restantes => (total - products.length).clamp(0, total);

  Future<void> carregar() async {
    carregando = true;
    falha = null;
    notifyListeners();
    try {
      final tipos = await catalogo.listarTipos();
      final pagina = await produtos.listar();
      types = [for (final t in tipos) t.tipo];
      products = pagina.itens;
      total = pagina.total;
      temMais = pagina.temMais;
    } catch (e) {
      falha = mensagemDeErro(e, 'Não foi possível carregar os produtos.');
    }
    carregando = false;
    notifyListeners();
  }

  /// Junta a próxima página ao fim da grade; devolve o motivo se falhou.
  Future<String?> carregarMais() async {
    if (!temMais || carregandoMais) return null;
    carregandoMais = true;
    notifyListeners();
    try {
      final pagina = await produtos.listar(offset: products.length);
      final ids = {for (final p in products) p.id};
      products = [...products, ...pagina.itens.where((p) => !ids.contains(p.id))];
      total = pagina.total;
      temMais = pagina.temMais;
      return null;
    } catch (e) {
      return mensagemDeErro(e, 'Não foi possível carregar mais produtos.');
    } finally {
      carregandoMais = false;
      notifyListeners();
    }
  }
}
