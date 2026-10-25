import 'package:flutter/foundation.dart' show immutable;

import 'models/models.dart';

/// Regra do catálogo recusada (ex.: excluir um tipo que já foi usado em
/// pedidos). Na API chega como 400/409; a tela mostra a [mensagem] como está.
class CatalogoRegraException implements Exception {
  const CatalogoRegraException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Um tipo de produto com os ids dos adicionais que ele oferece.
@immutable
class TipoCatalogado {
  const TipoCatalogado({required this.tipo, required this.adicionalIds});

  final TipoProdutoModel tipo;
  final Set<String> adicionalIds;
}

/// Cadastro do catálogo do Maker: tipos de produto e adicionais. Quem
/// monta pedidos usa o [CatalogoRepository]; aqui é a administração.
///
/// Toda operação recusada pelas regras falha com [CatalogoRegraException].
abstract interface class CatalogoAdminRepository {
  Future<List<TipoCatalogado>> listarTipos();

  Future<List<AdicionalModel>> listarAdicionais();

  /// Cria (sem [id]) ou atualiza um tipo e troca os adicionais vinculados.
  Future<TipoCatalogado> salvarTipo({
    String? id,
    required String nome,
    required double precoBase,
    required bool habilitado,
    required Set<String> adicionalIds,
  });

  Future<void> definirTipoHabilitado(String id, bool habilitado);

  /// Falha se o tipo já foi usado em pedido ou no portfólio (nesse caso o
  /// caminho é desabilitá-lo).
  Future<void> excluirTipo(String id);

  /// Cria (sem [id]) ou atualiza um adicional. Informe **um** entre
  /// [precoFixo] e [porcentagem]: informar um troca a regra de preço.
  Future<AdicionalModel> salvarAdicional({
    String? id,
    required String nome,
    String? descricao,
    double? precoFixo,
    double? porcentagem,
    required bool habilitado,
  });

  Future<void> definirAdicionalHabilitado(String id, bool habilitado);

  /// Falha se o adicional já foi usado em um pedido.
  Future<void> excluirAdicional(String id);
}
