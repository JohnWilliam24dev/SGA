import 'package:flutter/foundation.dart' show Listenable;

import 'commission_column.dart';
import 'models/models.dart';
import 'nova_commission.dart';
import 'pagina.dart';

/// De onde vem o quadro de commissions. Hoje é simulado em memória; quando o
/// banco entrar, basta uma nova implementação desta interface.
///
/// Avisa os ouvintes quando uma commission é criada ou editada (não ao
/// mover), para o quadro se atualizar sozinho.
abstract interface class CommissionRepository implements Listenable {
  /// Colunas do quadro, cada uma com seus resumos, na ordem de exibição.
  Future<List<CommissionColumn>> carregarQuadro();

  /// Próxima página dos pedidos de uma coluna (a API traz 50 por vez).
  /// [offset] é quantos pedidos a tela já tem nela.
  Future<Pagina<CommissionResumoModel>> carregarMais(
    String statusId, {
    required int offset,
  });

  /// Dados completos de uma commission, para a tela de detalhe. Falha se o
  /// [commissionId] não existir.
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId);

  /// Registra a nova posição de uma commission. [paraIndice] segue a mesma
  /// regra de [moverCommission].
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  });

  /// Quantas commissions estão no status [statusId]. Serve à regra de que uma
  /// coluna com commissions não pode ser excluída.
  Future<int> contarPorStatus(String statusId);

  /// Cria um pedido na coluna inicial, no fim da fila.
  Future<CommissionDetalhadaModel> criar(NovaCommission nova);

  /// Troca os adicionais do pedido e acerta o valor simulado. Recusa se o
  /// orçamento não puder mais ser alterado.
  Future<void> salvarAdicionais(
    String commissionId,
    List<CommissionAdicionalModel> adicionais,
  );

  /// Fecha o orçamento em [valor]: a partir daqui ele não muda mais e
  /// substitui o valor simulado no card.
  Future<void> fecharOrcamento(String commissionId, double valor);

  /// Se o orçamento ainda pode ser editado: falso quando já foi fechado ou
  /// quando o pedido está em coluna Concluído ou Cancelado.
  Future<bool> orcamentoEditavel(String commissionId);
}
