import 'dart:typed_data';

import 'models/models.dart';
import 'pagina.dart';

/// Regra do portfólio recusada pelo servidor (400/409); a tela mostra a
/// [mensagem] como está.
class ProdutoRegraException implements Exception {
  const ProdutoRegraException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Dados para cadastrar um produto. A [imagem] é obrigatória e já deve ter
/// passado por `erroDaImagem`.
class NovoProduto {
  const NovoProduto({
    required this.nome,
    required this.tipoProdutoId,
    required this.imagem,
    this.descricao,
  });

  final String nome;
  final String tipoProdutoId;
  final String? descricao;
  final Uint8List imagem;
}

/// Portfólio do Maker (a API traz 50 por vez, mais novos primeiro).
abstract interface class ProdutoRepository {
  /// [offset] é quantos produtos a tela já tem.
  Future<Pagina<ProdutoModel>> listar({int offset = 0});

  Future<ProdutoModel> criar(NovoProduto novo);

  /// Edita os dados; a imagem de um produto **não** muda (a API não troca).
  /// Com [limparDescricao], apaga a descrição que existia.
  Future<ProdutoModel> atualizar(
    String id, {
    required String nome,
    required String tipoProdutoId,
    String? descricao,
    bool limparDescricao = false,
  });

  Future<void> excluir(String id);
}
