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

  // Trocar essa chave recria o formulário e limpa todos os campos (inclusive
  // a imagem) depois de salvar um produto.
  int _formVersion = 0;

  Future<Uint8List?> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    return image.readAsBytes();
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
    });
    Toast.show(context, text: 'Produto adicionado.', type: ToastType.success);
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
            key: ValueKey(_formVersion),
            onSubmit: _save,
            children: [
              InputField(
                name: 'nome',
                hint: 'Nome do produto',
                validation: [isRequired()],
              ),
              Select<String>.single(
                name: 'tipo',
                hint: 'Tipo',
                options: [
                  for (final t in _types) SelectOption(t.id, t.nome),
                ],
                onChanged: (_) {},
                validation: [isRequired()],
              ),
              const InputField(
                name: 'descricao',
                hint: 'Descrição opcional',
                minLines: 3,
                maxLines: 3,
              ),
              ImageField(
                name: 'imagem',
                label: 'Imagem',
                hint: 'Toque para selecionar imagem',
                onPick: _pickImage,
                validation: [isRequired(message: 'Selecione uma imagem')],
              ),
              const Button(text: 'Salvar Produto', expanded: true),
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
            const EmptyState(title: 'Nenhum produto cadastrado.')
          else
            Grid.fit(
              minCellWidth: 180,
              children: [
                for (final p in _products) _produtoCard(p),
              ],
            ),
        ],
      ),
    );
  }

  Widget _produtoCard(ProdutoModel p) {
    final tipo = _types.firstWhere((t) => t.id == p.tipoProdutoId).nome;
    final preview = _previews[p.id];
    return Card(
      paddingSteps: 1,
      child: Div(
        gap: 8.px,
        children: [
          SizedBox(
            height: 120,
            width: double.infinity,
            child: preview != null
                ? Picture(bytes: preview, radius: 8)
                : const Center(child: Icon(Icons.inventory_2_outlined, size: 40)),
          ),
          Label(text: p.nome),
          Label(text: tipo, type: LabelType.caption),
        ],
      ),
    );
  }
}
