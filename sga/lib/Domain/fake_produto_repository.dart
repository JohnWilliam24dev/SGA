import 'mock/produtos_seed.dart';
import 'models/models.dart';
import 'pagina.dart';
import 'produto_repository.dart';

/// Portfólio simulado em memória (testes e demo). Sem hospedagem de
/// imagem: o produto criado fica com `imagemUrl` vazio.
class FakeProdutoRepository implements ProdutoRepository {
  FakeProdutoRepository({List<ProdutoModel>? produtos})
      : _produtos = [...produtos ?? produtosDeExemplo()];

  final List<ProdutoModel> _produtos;
  int _proximoId = 1;

  @override
  Future<Pagina<ProdutoModel>> listar({int offset = 0}) async {
    final itens = _produtos.skip(offset).take(50).toList();
    final fim = offset + itens.length;
    return Pagina(itens: itens, total: _produtos.length, temMais: fim < _produtos.length);
  }

  @override
  Future<ProdutoModel> criar(NovoProduto novo) async {
    final produto = ProdutoModel(
      id: 'produto-novo-${_proximoId++}',
      nome: novo.nome,
      imagemUrl: '',
      tipoProdutoId: novo.tipoProdutoId,
      descricao: novo.descricao,
    );
    _produtos.insert(0, produto);
    return produto;
  }

  @override
  Future<ProdutoModel> atualizar(
    String id, {
    required String nome,
    required String tipoProdutoId,
    String? descricao,
    bool limparDescricao = false,
  }) async {
    final i = _produtos.indexWhere((p) => p.id == id);
    if (i == -1) throw const ProdutoRegraException('Produto não encontrado.');
    final antes = _produtos[i];
    return _produtos[i] = ProdutoModel(
      id: id,
      nome: nome,
      imagemUrl: antes.imagemUrl,
      tipoProdutoId: tipoProdutoId,
      descricao: limparDescricao ? null : descricao ?? antes.descricao,
    );
  }

  @override
  Future<void> excluir(String id) async => _produtos.removeWhere((p) => p.id == id);
}
