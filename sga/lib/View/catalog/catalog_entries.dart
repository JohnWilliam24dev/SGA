import '../../Domain/models/adicional_model.dart';
import '../../Domain/models/tipo_produto_model.dart';

/// Um tipo de produto na lista, com os adicionais vinculados. Se ele já foi
/// usado em pedidos ou no portfólio, o servidor recusa a exclusão (o
/// caminho é desabilitá-lo).
class CatalogType {
  CatalogType({required this.model, required this.additionalIds});

  TipoProdutoModel model;
  final Set<String> additionalIds;
}

/// Um adicional na lista.
class CatalogAdditional {
  CatalogAdditional({required this.model});

  AdicionalModel model;
}

TipoProdutoModel typeWithEnabled(TipoProdutoModel model, bool value) =>
    TipoProdutoModel(
      id: model.id,
      nome: model.nome,
      precoBase: model.precoBase,
      habilitado: value,
    );

AdicionalModel additionalWithEnabled(AdicionalModel model, bool value) =>
    AdicionalModel(
      id: model.id,
      nome: model.nome,
      descricao: model.descricao,
      precoFixo: model.precoFixo,
      porcentagem: model.porcentagem,
      habilitado: value,
    );
