import 'commission_repository.dart';
import 'models/models.dart';
import 'relatorio_repository.dart';

/// Relatório simulado: soma o que o repositório de pedidos tem (sem filtrar
/// por período, porque os pedidos simulados não guardam datas de conclusão).
class FakeRelatorioRepository implements RelatorioRepository {
  const FakeRelatorioRepository(this._commissions);

  final CommissionRepository _commissions;

  @override
  Future<RelatorioResumoModel> carregarResumo({
    DateTime? de,
    DateTime? ate,
  }) async {
    final colunas = await _commissions.carregarQuadro();
    int somar(StatusTipo t) => colunas
        .where((c) => c.tipo == t)
        .fold(0, (s, c) => s + c.quantidade);
    final concluidos = somar(StatusTipo.concluido);
    final cancelados = somar(StatusTipo.cancelado);
    final pedidos = colunas.fold(0, (s, c) => s + c.quantidade);

    final tipos = <String, ({int total, double receita})>{};
    var receita = 0.0;
    for (final c in colunas) {
      for (final p in c.commissions) {
        final nome = p.tipoProdutoNome ?? 'Sem tipo';
        final double ganho =
            c.tipo == StatusTipo.concluido ? (p.orcamentoFinal ?? 0) : 0;
        final atual = tipos[nome] ?? (total: 0, receita: 0.0);
        tipos[nome] = (
          total: atual.total + 1,
          receita: atual.receita + ganho,
        );
        receita += ganho;
      }
    }

    final agora = DateTime.now();
    return RelatorioResumoModel(
      de: de ?? DateTime(agora.year, agora.month),
      ate: ate ?? DateTime(agora.year, agora.month + 1, 0),
      pedidos: pedidos,
      concluidos: concluidos,
      cancelados: cancelados,
      emAberto: pedidos - concluidos - cancelados,
      concluidosNoPeriodo: concluidos,
      receita: receita,
      ticketMedio: concluidos == 0 ? 0 : receita / concluidos,
      porStatus: [
        for (final c in colunas)
          RelatorioPorStatus(nome: c.titulo, tipo: c.tipo, total: c.quantidade),
      ],
      porTipo: [
        for (final e in tipos.entries)
          RelatorioPorTipo(
            nome: e.key,
            total: e.value.total,
            receita: e.value.receita,
          ),
      ],
    );
  }
}
