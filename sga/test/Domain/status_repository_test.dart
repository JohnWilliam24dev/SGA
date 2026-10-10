import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

FakeCommissionRepository _novo() =>
    FakeCommissionRepository(latencia: Duration.zero);

List<String> _ids(List<CommissionColumn> quadro, String coluna) {
  return quadro
      .firstWhere((c) => c.id == coluna)
      .commissions
      .map((c) => c.id)
      .toList();
}

void main() {
  test('o quadro nasce com os 4 status padrão, Cancelado vazio inclusive', () async {
    final quadro = await _novo().carregarQuadro();

    expect(
      [for (final c in quadro) c.titulo],
      ['Fila', 'Em andamento', 'Concluído', 'Cancelado'],
    );
    expect(
      [for (final c in quadro) c.tipo],
      [
        StatusTipo.inicial,
        StatusTipo.emAndamento,
        StatusTipo.concluido,
        StatusTipo.cancelado,
      ],
    );
    expect([for (final c in quadro) c.ordem], [1, 2, 3, 4]);
    expect(quadro.last.commissions, isEmpty);
    expect(_ids(quadro, 'fila'), ['c1', 'c2', 'c3']);
    expect(_ids(quadro, 'em-andamento'), ['c4', 'c5', 'c6', 'c7', 'c8', 'c9']);
    expect(_ids(quadro, 'concluido'), ['c10', 'c11']);
  });

  test('coluna criada aparece no quadro, vazia e como Em andamento', () async {
    final repo = _novo();
    final nova = await repo.statusRepository.criar('Revisão');

    final quadro = await repo.carregarQuadro();
    final coluna = quadro.last;
    expect(coluna.id, nova.id);
    expect(coluna.titulo, 'Revisão');
    expect(coluna.tipo, StatusTipo.emAndamento);
    expect(coluna.ordem, 5);
    expect(coluna.commissions, isEmpty);
  });

  test('renomear muda o título da coluna no quadro', () async {
    final repo = _novo();
    await repo.statusRepository.renomear('fila', 'Entrada');

    final quadro = await repo.carregarQuadro();
    expect(quadro.first.titulo, 'Entrada');
    expect(_ids(quadro, 'fila'), ['c1', 'c2', 'c3']);
  });

  test('reordenar muda a ordem das colunas no quadro', () async {
    final repo = _novo();
    await repo.statusRepository.reordenar(
      ['cancelado', 'concluido', 'em-andamento', 'fila'],
    );

    final quadro = await repo.carregarQuadro();
    expect(
      [for (final c in quadro) c.id],
      ['cancelado', 'concluido', 'em-andamento', 'fila'],
    );
  });

  test('mover para Cancelado vale a partir de qualquer coluna', () async {
    final repo = _novo();
    await repo.mover(commissionId: 'c1', paraColunaId: 'cancelado', paraIndice: 0);

    final quadro = await repo.carregarQuadro();
    expect(_ids(quadro, 'cancelado'), ['c1']);
    final detalhe = await repo.carregarDetalhe('c1');
    expect(detalhe.statusId, 'cancelado');
  });

  test('contarPorStatus conta os cartões da coluna', () async {
    final repo = _novo();
    expect(await repo.contarPorStatus('fila'), 3);
    expect(await repo.contarPorStatus('cancelado'), 0);
    expect(await repo.contarPorStatus('nao-existe'), 0);
  });

  group('excluir', () {
    test('coluna vazia some do quadro', () async {
      final repo = _novo();
      final nova = await repo.statusRepository.criar('Revisão');
      await repo.statusRepository.excluir(nova.id);

      final quadro = await repo.carregarQuadro();
      expect(quadro.any((c) => c.id == nova.id), isFalse);
    });

    test('coluna com commissions é recusada até os cartões saírem', () async {
      final repo = _novo();
      final nova = await repo.statusRepository.criar('Revisão');
      await repo.mover(commissionId: 'c1', paraColunaId: nova.id, paraIndice: 0);

      await expectLater(
        repo.statusRepository.excluir(nova.id),
        throwsA(
          isA<StatusRegraException>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('1 commission'),
          ),
        ),
      );
      expect((await repo.carregarQuadro()).any((c) => c.id == nova.id), isTrue);

      await repo.mover(commissionId: 'c1', paraColunaId: 'fila', paraIndice: 0);
      await repo.statusRepository.excluir(nova.id);
      expect((await repo.carregarQuadro()).any((c) => c.id == nova.id), isFalse);
    });

    test('o último Cancelado e o último Concluído não saem', () async {
      final repo = _novo();
      await expectLater(
        repo.statusRepository.excluir('cancelado'),
        throwsA(isA<StatusRegraException>()),
      );
      await expectLater(
        repo.statusRepository.excluir('concluido'),
        throwsA(isA<StatusRegraException>()),
      );
      expect((await repo.carregarQuadro()).length, 4);
    });
  });

  group('trocar tipo', () {
    test('recusa tirar o tipo do último Cancelado', () async {
      final repo = _novo();
      await expectLater(
        repo.statusRepository.trocarTipo('cancelado', StatusTipo.emAndamento),
        throwsA(isA<StatusRegraException>()),
      );
    });

    test('marcar outra coluna como Inicial passa a Fila para Em andamento', () async {
      final repo = _novo();
      await repo.statusRepository.trocarTipo('em-andamento', StatusTipo.inicial);

      final quadro = await repo.carregarQuadro();
      expect(
        quadro.where((c) => c.tipo == StatusTipo.inicial).map((c) => c.id),
        ['em-andamento'],
      );
      expect(
        quadro.firstWhere((c) => c.id == 'fila').tipo,
        StatusTipo.emAndamento,
      );
    });
  });
}
