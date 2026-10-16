import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/widgets.dart' hide Icon;
import 'package:image_picker/image_picker.dart';

import '../../Domain/domain.dart';
import 'product_catalog.dart';
import 'product_form.dart';
import 'products_controller.dart';
import 'products_mobile.dart';
import 'products_mobile_section.dart';

/// Produtos do portfólio: formulário para adicionar (ou editar) e a grade dos
/// já cadastrados. No celular, um menu leva a cada uma das duas partes.
///
/// "Editar" num cartão leva o produto para o formulário, já preenchido; no
/// celular isso abre a tela do formulário.
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _controller = ProductsController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<Uint8List?> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return image?.readAsBytes();
  }

  void _save(FormValues values) {
    final adicionando = _controller.editing == null;
    final aviso = _controller.salvar(values);
    if (aviso != null) {
      Toast.show(context, text: aviso, type: ToastType.warning);
      return;
    }
    Toast.show(
      context,
      text: adicionando ? 'Produto adicionado.' : 'Produto atualizado.',
      type: ToastType.success,
    );
  }

  void _editar(ProdutoModel produto) {
    _controller.editar(produto);
    // No desktop o formulário fica no topo da página.
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => LayoutBuilder(builder: _layout),
    );
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final c = _controller;
    final editando = c.editing;
    final form = ProductForm(
      key: ValueKey(c.formVersion),
      types: c.types,
      initial: editando,
      initialPreview: editando == null ? null : c.previews[editando.id],
      onPickImage: _pickImage,
      onSave: _save,
      onCancel: editando == null ? null : c.cancelarEdicao,
    );
    final catalog = ProductCatalog(
      products: c.products,
      types: c.types,
      previews: c.previews,
      onEdit: _editar,
    );

    final width = constraints.maxWidth;
    final Widget corpo;
    if (Breakpoints.standard.sizeFor(width) == ScreenSize.mobile) {
      corpo = switch (c.view) {
        ProductsMobileView.menu => ProductsMobileMenu(
          onAddProduct: () => c.abrir(ProductsMobileView.form),
          onMyProducts: () => c.irPara(ProductsMobileView.catalog),
        ),
        ProductsMobileView.form => ProductsMobileSection(
          title: editando == null ? 'Adicionar produto' : 'Editar produto',
          onBack: () => c.abrir(ProductsMobileView.menu),
          child: form,
        ),
        ProductsMobileView.catalog => ProductsMobileSection(
          title: 'Meus produtos',
          onBack: () => c.irPara(ProductsMobileView.menu),
          child: catalog,
        ),
      };
    } else if (width < 880) {
      corpo = Column(children: [form, const SizedBox(height: 14), catalog]);
    } else {
      corpo = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: form),
          const SizedBox(width: 14),
          Expanded(flex: 6, child: catalog),
        ],
      );
    }
    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [corpo],
      ),
    );
  }
}
