import '../catalogo_admin_repository.dart';
import '../models/models.dart';

/// Tipos de exemplo do catálogo simulado.
List<TipoCatalogado> tiposDeExemplo() => [
  const TipoCatalogado(
    tipo: TipoProdutoModel(
      id: 'type-ilustracao',
      nome: 'Ilustração',
      precoBase: 120,
      habilitado: true,
    ),
    adicionalIds: {'add-fundo', 'add-express'},
  ),
  const TipoCatalogado(
    tipo: TipoProdutoModel(
      id: 'type-emote',
      nome: 'Emote',
      precoBase: 35,
      habilitado: true,
    ),
    adicionalIds: {'add-fundo'},
  ),
  const TipoCatalogado(
    tipo: TipoProdutoModel(
      id: 'type-modelo',
      nome: 'Modelo 3D',
      precoBase: 450,
      habilitado: false,
    ),
    adicionalIds: {'add-fundo', 'add-rig'},
  ),
];

/// Adicionais de exemplo do catálogo simulado.
List<AdicionalModel> adicionaisDeExemplo() => [
  const AdicionalModel(
    id: 'add-fundo',
    nome: 'Fundo detalhado',
    descricao: 'Cenário e elementos de composição.',
    precoFixo: 40,
    habilitado: true,
  ),
  const AdicionalModel(
    id: 'add-express',
    nome: 'Entrega expressa',
    descricao: 'Prioriza o pedido na fila de produção.',
    porcentagem: 20,
    habilitado: true,
  ),
  const AdicionalModel(
    id: 'add-rig',
    nome: 'Rig básico',
    precoFixo: 95,
    habilitado: false,
  ),
];

/// Já usados em pedidos ou no portfólio: só podem ser desabilitados.
const tiposEmUsoDeExemplo = {'type-modelo'};
const adicionaisEmUsoDeExemplo = {'add-rig'};
