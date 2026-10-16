import 'commission_board.dart';
import 'commission_column.dart';
import 'mock/commission_samples.dart';
import 'models/models.dart';
import 'status_repository.dart';

/// De onde vem o quadro de commissions. Hoje é simulado em memória; quando o
/// banco entrar, basta uma nova implementação desta interface.
abstract interface class CommissionRepository {
  /// Colunas do quadro, cada uma com seus resumos, na ordem de exibição.
  Future<List<CommissionColumn>> carregarQuadro();

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
}

/// Repositório de teste: dados fixos em memória, com uma latência simulada.
///
/// As colunas do quadro vêm do [StatusRepository] (os status do Maker); aqui
/// ficam só as commissions de cada status. O quadro e o detalhe vêm da mesma
/// fonte: o detalhe de uma commission sempre reflete a coluna e a posição em
/// que ela está no quadro.
class FakeCommissionRepository implements CommissionRepository {
  FakeCommissionRepository({
    this.latencia = const Duration(milliseconds: 400),
    StatusRepository? statusRepository,
    Map<String, CommissionDetalhadaModel>? detalhes,
  }) : _detalhes = detalhes ?? {for (final d in detalhesDeExemplo()) d.id: d} {
    _status = statusRepository ??
        FakeStatusRepository(
          latencia: latencia,
          contarCommissions: contarPorStatus,
        );
    _porStatus = _agrupar(_detalhes.values);
  }

  final Duration latencia;
  final Map<String, CommissionDetalhadaModel> _detalhes;
  late final StatusRepository _status;
  late Map<String, List<CommissionResumoModel>> _porStatus;

  /// Os status que montam as colunas deste quadro.
  StatusRepository get statusRepository => _status;

  @override
  Future<List<CommissionColumn>> carregarQuadro() async {
    await Future<void>.delayed(latencia);
    return List<CommissionColumn>.unmodifiable(
      _montarQuadro(await _status.listar()),
    );
  }

  @override
  Future<CommissionDetalhadaModel> carregarDetalhe(String commissionId) async {
    await Future<void>.delayed(latencia);
    final base = _detalhes[commissionId];
    if (base == null) {
      throw StateError('Commission $commissionId não encontrada');
    }
    for (final coluna in _montarQuadro(await _status.listar())) {
      final indice = coluna.commissions.indexWhere((c) => c.id == commissionId);
      if (indice != -1) {
        return base.copyWith(statusId: coluna.id, posicao: indice);
      }
    }
    return base;
  }

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) async {
    await Future<void>.delayed(latencia);
    final colunas = moverCommission(
      _montarQuadro(await _status.listar()),
      commissionId: commissionId,
      paraColunaId: paraColunaId,
      paraIndice: paraIndice,
    );
    _porStatus = {
      for (final coluna in colunas) coluna.id: [...coluna.commissions],
    };
  }

  @override
  Future<int> contarPorStatus(String statusId) async {
    return _porStatus[statusId]?.length ?? 0;
  }

  List<CommissionColumn> _montarQuadro(List<StatusModel> status) {
    return [
      for (final s in status)
        CommissionColumn(
          id: s.id,
          titulo: s.nome,
          tipo: s.tipo,
          ordem: s.ordem,
          commissions: [...?_porStatus[s.id]],
        ),
    ];
  }

  /// Agrupa por status e ordena cada grupo por `posicao`; `criadoEm` e o id
  /// desempatam (a posição pode repetir).
  static Map<String, List<CommissionResumoModel>> _agrupar(
    Iterable<CommissionDetalhadaModel> detalhes,
  ) {
    final ordenados = detalhes.toList()
      ..sort((a, b) {
        final porPosicao = a.posicao.compareTo(b.posicao);
        if (porPosicao != 0) return porPosicao;
        final porData = a.criadoEm.compareTo(b.criadoEm);
        return porData != 0 ? porData : a.id.compareTo(b.id);
      });
    final mapa = <String, List<CommissionResumoModel>>{};
    for (final d in ordenados) {
      mapa.putIfAbsent(d.statusId, () => <CommissionResumoModel>[]).add(d.resumo);
    }
    return mapa;
  }
}
