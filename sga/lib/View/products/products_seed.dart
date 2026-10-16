import '../../Domain/domain.dart';

/// Tipos de exemplo do portfólio, em memória, até a API.
List<TipoProdutoModel> seedProductTypes() => const [
  TipoProdutoModel(id: 'tipo-3d', nome: 'Modelo 3D', precoBase: 450, habilitado: true),
  TipoProdutoModel(id: 'tipo-ilustracao', nome: 'Ilustração 2D', precoBase: 120, habilitado: true),
  TipoProdutoModel(id: 'tipo-emote', nome: 'Emotes', precoBase: 150, habilitado: true),
];

/// Produtos de exemplo do portfólio.
List<ProdutoModel> seedProducts() => [
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
