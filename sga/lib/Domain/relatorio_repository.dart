import 'models/relatorio_resumo_model.dart';

/// Os números do relatório. Sem [de] e [ate], vale o mês corrente.
abstract class RelatorioRepository {
  Future<RelatorioResumoModel> carregarResumo({DateTime? de, DateTime? ate});
}
