import '../../Core/network/network.dart';
import '../../Domain/domain.dart';
import '../mappers/api_mappers.dart';
import '../mappers/relatorio_mapper.dart';

/// Relatório na API: `GET /relatorios/resumo?de=&ate=` (datas `YYYY-MM-DD`,
/// período de até 366 dias). Os números são do servidor: o app não recalcula
/// em cima do quadro, que é paginado.
class HttpRelatorioRepository implements RelatorioRepository {
  HttpRelatorioRepository(this._client);

  final ApiClient _client;

  static String _dia(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  @override
  Future<RelatorioResumoModel> carregarResumo({
    DateTime? de,
    DateTime? ate,
  }) async {
    final json = await _client.get(
      '/relatorios/resumo',
      query: {
        if (de != null) 'de': _dia(de),
        if (ate != null) 'ate': _dia(ate),
      },
    );
    return relatorioDeApi(mapaDe(json));
  }
}
