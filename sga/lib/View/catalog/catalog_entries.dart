import '../../Domain/models/adicional_model.dart';
import '../../Domain/models/tipo_produto_model.dart';

/// Um tipo de produto na lista, com os adicionais vinculados. [protected]
/// marca o tipo que já foi usado em pedidos ou no portfólio: só pode ser
/// desabilitado, não excluído.
class CatalogType {
  CatalogType({
    required this.model,
    required this.additionalIds,
    this.protected = false,
  });

  TipoProdutoModel model;
  final Set<String> additionalIds;
  final bool protected;
}

/// Um adicional na lista. [protected] vale como em [CatalogType].
class CatalogAdditional {
  CatalogAdditional({required this.model, this.protected = false});

  AdicionalModel model;
  final bool protected;
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
