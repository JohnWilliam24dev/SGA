import '../../Domain/domain.dart';

/// Fecha o orçamento e leva o pedido ao topo da primeira coluna de
/// Concluído. O servidor só deixa concluir com o orçamento fechado, por isso
/// a ordem. Se o move falhar, o orçamento fica fechado e o motivo (a
/// mensagem do servidor) sobe como [CommissionRegraException].
Future<void> fecharEConcluir(
  CommissionRepository repository,
  String commissionId,
  double valor,
) async {
  final colunas = await repository.carregarQuadro();
  final destino = colunas
      .where((c) => c.tipo == StatusTipo.concluido)
      .firstOrNull;
  if (destino == null) {
    throw const CommissionRegraException(
      'Crie uma coluna do tipo Concluído para concluir o pedido.',
    );
  }
  await repository.fecharOrcamento(commissionId, valor);
  await repository.mover(
    commissionId: commissionId,
    paraColunaId: destino.id,
    paraIndice: 0,
  );
}
