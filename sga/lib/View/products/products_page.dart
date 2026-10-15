import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart' hide Icon;
import 'package:flutter/widgets.dart' hide Icon;
import 'package:image_picker/image_picker.dart';

import '../../Domain/domain.dart';
import 'product_catalog.dart';
import 'product_form.dart';
import 'products_mobile.dart';
import 'products_mobile_section.dart';

/// Produtos do portfólio: formulário para adicionar e a grade dos já
/// cadastrados. No celular, um menu leva a cada uma das duas partes.
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _types = const [
    TipoProdutoModel(id: 'tipo-3d', nome: 'Modelo 3D', precoBase: 450, habilitado: true),
    TipoProdutoModel(id: 'tipo-ilustracao', nome: 'Ilustração 2D', precoBase: 120, habilitado: true),
    TipoProdutoModel(id: 'tipo-emote', nome: 'Emotes', precoBase: 150, habilitado: true),
  ];

  final _products = <ProdutoModel>[
    const ProdutoModel(
      id: 'produto-1',
      nome: 'Modelo 3D Vroid completo',
      imagemUrl: '',
      tipoProdutoId: 'tipo-3d',
      descricao: 'Modelo para portfólio',
    ),
    const ProdutoModel(
      id: 'produto-2',
      nome: 'Ilustração 2D (busto)',
      imagemUrl: '',
      tipoProdutoId: 'tipo-ilustracao',
    ),
  ];

  final _previews = <String, Uint8List>{};
  ProductsMobileView _view = ProductsMobileView.menu;
  // Trocar a chave recria o formulário e limpa os campos (e a imagem).
  int _formVersion = 0;

  Future<Uint8List?> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return image?.readAsBytes();
  }

  void _save(FormValues values) {
    final imagem = values.get<Uint8List>('imagem');
    if (imagem == null) {
      Toast.show(
        context,
        text: 'Selecione uma imagem para o produto.',
        type: ToastType.warning,
      );
      return;
    }
    final id = 'prod-${DateTime.now().millisecondsSinceEpoch}';
    final descricao = values['descricao']?.trim() ?? '';
    setState(() {
      _products.insert(
        0,
        ProdutoModel(
          id: id,
          nome: values['nome']!.trim(),
          tipoProdutoId: values['tipo']!,
          descricao: descricao.isEmpty ? null : descricao,
          imagemUrl: '',
        ),
      );
      _previews[id] = imagem;
      _formVersion++;
      _view = ProductsMobileView.catalog;
    });
    Toast.show(context, text: 'Produto adicionado.', type: ToastType.success);
  }

  void _editar(ProdutoModel produto) =>
      Toast.show(context, text: 'Edição de produto em breve.');

  @override
  Widget build(BuildContext context) {
    final form = ProductForm(
      key: ValueKey(_formVersion),
      types: _types,
      onPickImage: _pickImage,
      onSave: _save,
    );
    final catalog = ProductCatalog(
      products: _products,
      types: _types,
      previews: _previews,
      onEdit: _editar,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mobile =
            Breakpoints.standard.sizeFor(width) == ScreenSize.mobile;
        void ir(ProductsMobileView v) => setState(() => _view = v);

        final Widget corpo;
        if (mobile) {
          corpo = switch (_view) {
            ProductsMobileView.menu => ProductsMobileMenu(
              onAddProduct: () => ir(ProductsMobileView.form),
              onMyProducts: () => ir(ProductsMobileView.catalog),
            ),
            ProductsMobileView.form => ProductsMobileSection(
              title: 'Adicionar produto',
              onBack: () => ir(ProductsMobileView.menu),
              child: form,
            ),
            ProductsMobileView.catalog => ProductsMobileSection(
              title: 'Meus produtos',
              onBack: () => ir(ProductsMobileView.menu),
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
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [corpo],
          ),
        );
      },
    );
  }
}
