import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/detail_concluir.dart';

/// Registra a ordem das chamadas ao repositório simulado.
class _Ordem extends FakeCommissionRepository {
  _Ordem({this.semConcluido = false}) : super(latencia: Duration.zero);

  final bool semConcluido;
  final log = <String>[];

  @override
  Future<List<CommissionColumn>> carregarQuadro() async {
    final colunas = await super.carregarQuadro();
    return semConcluido
        ? colunas.where((c) => c.tipo != StatusTipo.concluido).toList()
        : colunas;
  }

  @override
  Future<void> fecharOrcamento(String commissionId, double valor) {
    log.add('fechar');
    return super.fecharOrcamento(commissionId, valor);
  }

  @override
  Future<void> mover({
    required String commissionId,
    required String paraColunaId,
    required int paraIndice,
  }) {
    log.add('mover');
    return super.mover(
      commissionId: commissionId,
      paraColunaId: paraColunaId,
      paraIndice: paraIndice,
    );
  }
}

void main() {
  test('fecha o orçamento ANTES de mover (o servidor exige nessa ordem)', () async {
    final repo = _Ordem();
    await fecharEConcluir(repo, 'c1', 350);
    expect(repo.log, ['fechar', 'mover']);
  });

  test('sem coluna de Concluído, avisa e não fecha nada', () async {
    final repo = _Ordem(semConcluido: true);
    await expectLater(
      fecharEConcluir(repo, 'c1', 350),
      throwsA(isA<CommissionRegraException>()),
    );
    expect(repo.log, isEmpty);
  });
}
