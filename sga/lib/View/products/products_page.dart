import 'dart:typed_data';

import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;
import 'package:image_picker/image_picker.dart';

import '../../Domain/domain.dart';

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
  Uint8List? _selectedImage;

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (mounted) setState(() => _selectedImage = bytes);
  }

  void _save(FormValues values) {
    if (_selectedImage == null) {
      Toast.show(text: 'Selecione uma imagem para o produto.');
      return;
    }
    final id = 'prod-${DateTime.now().millisecondsSinceEpoch}';
    setState(() {
      _products.insert(
        0,
        ProdutoModel(
          id: id,
          nome: values['nome'],
          tipoProdutoId: values['tipo'],
          descricao: values['descricao'],
          imagemUrl: '',
        ),
      );
      _previews[id] = _selectedImage!;
      _selectedImage = null;
    });
    Toast.show(text: 'Produto adicionado.');
  }

  @override
  Widget build(BuildContext context) {
    return Div(
      fill: true,
      scrollable: true,
      children: [
        Responsive(
          mobile: Div(
            children: [
              _buildForm(),
              _buildCatalog(),
            ],
          ),
          desktop: Div(
            direction: LayoutDirection.horizontal,
            children: [
              LayoutItem(size: 4.fr, child: _buildForm()),
              LayoutItem(size: 6.fr, child: _buildCatalog()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Card(
      child: Div(
        children: [
          const Label(type: LabelType.title, text: 'Adicionar Produto'),
          FormGroup(
            onSubmit: _save,
            children: (context) => [
              const InputField(name: 'nome', hint: 'Nome do produto', validation: [isRequired()]),
              Select<String>(
                name: 'tipo',
                hint: 'Tipo',
                options: _types
                    .map((t) => Option(id: t.id, label: t.nome))
                    .toList(),
                validation: [isRequired()],
              ),
              const InputField(name: 'descricao', hint: 'Descrição opcional', maxLines: 3),
              Div(
                gap: 4.px,
                children: [
                  const Label(text: 'Imagem', type: LabelType.caption),
                  ImageField(
                    value: _selectedImage,
                    onChanged: (v) => setState(() => _selectedImage = v as Uint8List?),
                    label: 'Toque para selecionar imagem',
                  ),
                ],
              ),
              const Button(text: 'Salvar Produto', expanded: true, submit: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog() {
    return Card(
      child: Div(
        children: [
          const Label(type: LabelType.title, text: 'Meus Produtos'),
          if (_products.isEmpty)
            const EmptyState(label: 'Nenhum produto cadastrado.')
          else
            Grid.fit(
              minCellWidth: 180,
              children: _products.map((p) {
                final type = _types.firstWhere((t) => t.id == p.tipoProdutoId).nome;
                return Card(
                  padding: 8.px.all,
                  child: Div(
                    gap: 8.px,
                    children: [
                      Picture(
                        source: _previews[p.id],
                        placeholder: Icons.inventory_2_outlined,
                      ),
                      Label(text: p.nome, type: LabelType.body),
                      Label(text: type, type: LabelType.caption),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
