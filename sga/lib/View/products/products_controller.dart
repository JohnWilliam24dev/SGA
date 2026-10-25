import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' show FormValues;
import 'package:flutter/foundation.dart';

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';
import 'products_carga.dart';
import 'products_mobile.dart';

/// Estado da tela de Produtos: tipos, produtos, imagens recém-escolhidas, a
/// tela aberta no celular e o produto em edição (nulo quando o formulário
/// está adicionando).
class ProductsController extends ChangeNotifier with ProductsCarga {
  ProductsController({required this.produtos, required this.catalogo}) {
    carregar();
  }

  @override
  final ProdutoRepository produtos;
  @override
  final CatalogoAdminRepository catalogo;

  /// Imagens que o usuário acabou de escolher, para mostrar antes de a
  /// hospedagem devolver a URL.
  final previews = <String, Uint8List>{};

  ProductsMobileView view = ProductsMobileView.menu;
  ProdutoModel? editing;
  bool _vivo = true;

  /// Trocar a chave do formulário recria os campos (e limpa a imagem).
  int formVersion = 0;

  @override
  void dispose() {
    _vivo = false;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_vivo) super.notifyListeners();
  }

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

  /// Salva o formulário: cadastra um produto novo (com a imagem) ou edita os
  /// dados do que está em edição (a imagem não muda). Devolve o motivo se
  /// não deu certo.
  Future<String?> salvar(FormValues values) async {
    final atual = editing;
    final imagem = values.get<Uint8List>('imagem');
    if (atual == null && imagem == null) {
      return 'Selecione uma imagem para o produto.';
    }
    final erroImagem = atual == null ? erroDaImagem(imagem!) : null;
    if (erroImagem != null) return erroImagem;
    final nome = values['nome']!.trim();
    final tipo = values['tipo']!;
    final descricao = values['descricao']?.trim() ?? '';
    try {
      if (atual == null) {
        final criado = await produtos.criar(NovoProduto(
          nome: nome,
          tipoProdutoId: tipo,
          descricao: descricao.isEmpty ? null : descricao,
          imagem: imagem!,
        ));
        products = [criado, ...products];
        total++;
        previews[criado.id] = imagem;
      } else {
        final novo = await produtos.atualizar(
          atual.id,
          nome: nome,
          tipoProdutoId: tipo,
          descricao: descricao.isEmpty ? null : descricao,
          limparDescricao: descricao.isEmpty && (atual.descricao ?? '').isNotEmpty,
        );
        products = [for (final p in products) p.id == atual.id ? novo : p];
      }
    } catch (e) {
      return mensagemDeErro(e, 'Não foi possível salvar o produto.');
    }
    abrir(ProductsMobileView.catalog);
    return null;
  }
}
