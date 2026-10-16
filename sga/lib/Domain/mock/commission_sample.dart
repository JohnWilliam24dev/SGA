import '../models/models.dart';

/// Monta uma commission de exemplo com os campos que mudam de uma para
/// outra; o resto (token, imagem de referência, id do tipo) é derivado.
CommissionDetalhadaModel commissionSample({
  required String id,
  required String status,
  required int posicao,
  required String cliente,
  required String tipo,
  required double precoSimulado,
  double? orcamentoFinal,
  required String contato,
  String? email,
  required int dia,
  required String descricao,
  required List<CommissionAdicionalModel> adicionais,
}) {
  return CommissionDetalhadaModel(
    id: id,
    token: 'tok-$id',
    nomeCliente: cliente,
    tipoProdutoNome: tipo,
    precoSimulado: precoSimulado,
    orcamentoFinal: orcamentoFinal,
    posicao: posicao,
    criadoEm: DateTime.utc(2026, 9, dia, 14, 30),
    statusId: status,
    tipoProdutoId: 'tp-${tipo.toLowerCase().replaceAll(' ', '-')}',
    contato: contato,
    descricao: descricao,
    imagemRefUrl: 'https://exemplo.com/referencias/$id.png',
    email: email,
    adicionais: adicionais,
  );
}
