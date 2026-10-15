import '../../Domain/models/adicional_model.dart';
import '../../Domain/models/tipo_produto_model.dart';
import 'catalog_entries.dart';

/// Dados de exemplo, em memória, até o catálogo vir da API.
List<CatalogType> seedTypes() => [
  CatalogType(
    model: const TipoProdutoModel(
      id: 'type-ilustracao',
      nome: 'Ilustração',
      precoBase: 120,
      habilitado: true,
    ),
    additionalIds: {'add-fundo', 'add-express'},
  ),
  CatalogType(
    model: const TipoProdutoModel(
      id: 'type-emote',
      nome: 'Emote',
      precoBase: 35,
      habilitado: true,
    ),
    additionalIds: {'add-fundo'},
  ),
  CatalogType(
    model: const TipoProdutoModel(
      id: 'type-modelo',
      nome: 'Modelo 3D',
      precoBase: 450,
      habilitado: false,
    ),
    additionalIds: {'add-fundo', 'add-rig'},
    protected: true,
  ),
];

List<CatalogAdditional> seedAdditionals() => [
  CatalogAdditional(
    model: const AdicionalModel(
      id: 'add-fundo',
      nome: 'Fundo detalhado',
      descricao: 'Cenário e elementos de composição.',
      precoFixo: 40,
      habilitado: true,
    ),
  ),
  CatalogAdditional(
    model: const AdicionalModel(
      id: 'add-express',
      nome: 'Entrega expressa',
      descricao: 'Prioriza o pedido na fila de produção.',
      porcentagem: 20,
      habilitado: true,
    ),
  ),
  CatalogAdditional(
    model: const AdicionalModel(
      id: 'add-rig',
      nome: 'Rig básico',
      precoFixo: 95,
      habilitado: false,
    ),
    protected: true,
  ),
];
