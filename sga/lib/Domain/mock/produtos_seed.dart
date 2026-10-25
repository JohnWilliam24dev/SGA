import '../models/models.dart';

/// Produtos de exemplo do portfólio simulado (ligados aos tipos de
/// `tiposDeExemplo`).
List<ProdutoModel> produtosDeExemplo() => const [
  ProdutoModel(
    id: 'produto-1',
    nome: 'Modelo 3D Vroid completo',
    imagemUrl: '',
    tipoProdutoId: 'type-modelo',
    descricao: 'Modelo para portfólio',
  ),
  ProdutoModel(
    id: 'produto-2',
    nome: 'Ilustração 2D (busto)',
    imagemUrl: '',
    tipoProdutoId: 'type-ilustracao',
  ),
];
