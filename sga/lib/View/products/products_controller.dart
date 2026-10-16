import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' show FormValues;
import 'package:flutter/foundation.dart';

import '../../Domain/domain.dart';
import 'products_mobile.dart';
import 'products_seed.dart';

/// Estado da tela de Produtos: tipos, produtos, imagens, a tela aberta no
/// celular e o produto em edição (nulo quando o formulário está adicionando).
class ProductsController extends ChangeNotifier {
  final types = seedProductTypes();
  final products = seedProducts();
  final previews = <String, Uint8List>{};

  ProductsMobileView view = ProductsMobileView.menu;
  ProdutoModel? editing;

  /// Trocar a chave do formulário recria os campos (e limpa a imagem).
  int formVersion = 0;

  /// Abre [nova] tela (no celular) e deixa o formulário no modo "adicionar".
  void abrir(ProductsMobileView nova) {
    editing = null;
    formVersion++;
    view = nova;
    notifyListeners();
  }

  /// Leva o [produto] para o formulário, já preenchido.
  void editar(ProdutoModel produto) {
    editing = produto;
    formVersion++;
    view = ProductsMobileView.form;
    notifyListeners();
  }

  /// Sai da edição sem salvar, mantendo a tela em que estava.
  void cancelarEdicao() => abrir(view);

  void irPara(ProductsMobileView nova) {
    view = nova;
    notifyListeners();
  }

  /// Salva o formulário: adiciona um produto novo ou atualiza o que está em
  /// edição. Devolve um aviso se faltar algo (a imagem, ao adicionar).
  String? salvar(FormValues values) {
    final atual = editing;
    final imagem = values.get<Uint8List>('imagem');
    if (atual == null && imagem == null) {
      return 'Selecione uma imagem para o produto.';
    }
    final id = atual?.id ?? 'prod-${DateTime.now().millisecondsSinceEpoch}';
    final descricao = values['descricao']?.trim() ?? '';
    final produto = ProdutoModel(
      id: id,
      nome: values['nome']!.trim(),
      tipoProdutoId: values['tipo']!,
      descricao: descricao.isEmpty ? null : descricao,
      imagemUrl: atual?.imagemUrl ?? '',
    );
    if (atual == null) {
      products.insert(0, produto);
    } else {
      products[products.indexWhere((p) => p.id == id)] = produto;
    }
    // Sem escolher outra imagem ao editar, fica a que já existia.
    if (imagem != null) previews[id] = imagem;
    abrir(ProductsMobileView.catalog);
    return null;
  }
}
