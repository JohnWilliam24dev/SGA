import '../../Domain/domain.dart';

/// Tudo que o detalhe precisa para desenhar e editar um pedido: os dados
/// completos, se o orçamento ainda aceita edição e o que o tipo do pedido
/// oferece (preço base e adicionais), quando o catálogo o conhece.
class DetailData {
  const DetailData({
    required this.detalhe,
    required this.editavel,
    required this.reabrivel,
    required this.opcao,
  });

  final CommissionDetalhadaModel detalhe;
  final bool editavel;

  /// Orçamento fechado que ainda pode ser reaberto.
  final bool reabrivel;
  final OpcaoDeTipo? opcao;

  static Future<DetailData> carregar(
    CommissionRepository repository,
    CatalogoRepository catalogo,
    String commissionId,
  ) async {
    final detalhe = await repository.carregarDetalhe(commissionId);
    final editavel = await repository.orcamentoEditavel(commissionId);
    final reabrivel = await repository.orcamentoReabrivel(commissionId);
    final opcoes = await catalogo.carregarOpcoes();
    final achadas = opcoes.where((o) => o.tipo.id == detalhe.tipoProdutoId);
    return DetailData(
      detalhe: detalhe,
      editavel: editavel,
      reabrivel: reabrivel,
      opcao: achadas.isEmpty ? null : achadas.first,
    );
  }

  /// Versão local, na hora, com os adicionais trocados e o valor simulado
  /// acertado (a mesma conta do repositório).
  DetailData comAdicionais(List<CommissionAdicionalModel> novos) {
    final atual = detalhe.precoSimulado;
    final preco = atual == null
        ? null
        : atual -
            somaDosAdicionais(detalhe.adicionais) +
            somaDosAdicionais(novos);
    return DetailData(
      detalhe: detalhe.copyWith(
        precoSimulado:
            preco == null ? null : arredondarCentavos(preco < 0 ? 0 : preco),
        adicionais: novos,
      ),
      editavel: editavel,
      reabrivel: reabrivel,
      opcao: opcao,
    );
  }
}
