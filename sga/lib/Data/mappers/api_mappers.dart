import '../../Domain/domain.dart';

/// Tradução do JSON da API para os models do domínio. Aqui moram as
/// diferenças de contrato: dinheiro em texto (`"120.00"`), objetos aninhados
/// (`status`, `tipoProduto`) e nomes diferentes.

Map<String, dynamic> mapaDe(Object? json) =>
    Map<String, dynamic>.from(json as Map);

List<Map<String, dynamic>> listaDe(Object? json) =>
    [for (final item in json as List) mapaDe(item)];

/// A API manda dinheiro como texto de 2 casas; aceita número também.
double dinheiro(Object? valor) =>
    valor is num ? valor.toDouble() : double.parse(valor as String);

double? dinheiroOuNulo(Object? valor) =>
    valor == null ? null : dinheiro(valor);

/// Cartão do quadro (`tipoProduto` aqui é só o nome).
CommissionResumoModel resumoDeApi(Map<String, dynamic> j) {
  return CommissionResumoModel(
    id: j['id'] as String,
    token: j['token'] as String,
    nomeCliente: j['nomeCliente'] as String,
    tipoProdutoNome: j['tipoProduto'] as String,
    precoSimulado: dinheiro(j['precoSimulado']),
    orcamentoFinal: dinheiroOuNulo(j['orcamentoFinal']),
    posicao: j['posicao'] as int,
    criadoEm: DateTime.parse(j['criadoEm'] as String),
  );
}

CommissionAdicionalModel adicionalDeApi(Map<String, dynamic> j) {
  return CommissionAdicionalModel(
    adicionalId: j['adicionalId'] as String,
    nome: j['nome'] as String,
    quantidade: j['quantidade'] as int,
    descricaoCliente: j['descricaoCliente'] as String?,
    valorUnitario: dinheiro(j['valorUnitario']),
  );
}

/// Detalhe: `status` e `tipoProduto` vêm aninhados e são achatados.
CommissionDetalhadaModel detalheDeApi(Map<String, dynamic> j) {
  final resumo = resumoDeApi({
    ...j,
    // No detalhe `tipoProduto` é um objeto; o resumo quer só o nome.
    'tipoProduto': mapaDe(j['tipoProduto'])['nome'],
  });
  return CommissionDetalhadaModel(
    id: resumo.id,
    token: resumo.token,
    nomeCliente: resumo.nomeCliente,
    tipoProdutoNome: resumo.tipoProdutoNome,
    precoSimulado: resumo.precoSimulado,
    orcamentoFinal: resumo.orcamentoFinal,
    posicao: resumo.posicao,
    criadoEm: resumo.criadoEm,
    statusId: mapaDe(j['status'])['id'] as String,
    tipoProdutoId: mapaDe(j['tipoProduto'])['id'] as String,
    contato: j['contato'] as String,
    descricao: j['descricao'] as String,
    imagemRefUrl: j['imagemRefUrl'] as String? ?? '',
    email: j['email'] as String?,
    adicionais: [for (final a in listaDe(j['adicionais'])) adicionalDeApi(a)],
  );
}

/// Coluna do kanban (`KanbanResposta.colunas[i]`), com o total e o
/// `temMais` da paginação.
CommissionColumn colunaDeApi(Map<String, dynamic> j) {
  final status = StatusModel.fromJson(mapaDe(j['status']));
  return CommissionColumn(
    id: status.id,
    titulo: status.nome,
    tipo: status.tipo,
    ordem: status.ordem,
    commissions: [for (final c in listaDe(j['cartoes'])) resumoDeApi(c)],
    total: j['total'] as int,
    temMais: j['temMais'] as bool,
  );
}
