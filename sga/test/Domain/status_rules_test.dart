import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

/// Os 4 status padrão mais uma coluna extra "Revisão" (EM_ANDAMENTO).
List<StatusModel> _comExtra() => [
      ...statusPadrao(),
      const StatusModel(
        id: 'revisao',
        nome: 'Revisão',
        ordem: 5,
        tipo: StatusTipo.emAndamento,
      ),
    ];

Matcher _recusaCom(String trecho) => throwsA(
      isA<StatusRegraException>().having(
        (e) => e.mensagem,
        'mensagem',
        contains(trecho),
      ),
    );

List<String> _ids(List<StatusModel> status) => [for (final s in status) s.id];

void main() {
  group('statusPadrao', () {
    test('traz os 4 status do cadastro, nesta ordem e com estes tipos', () {
      final padrao = statusPadrao();
      expect(
        [for (final s in padrao) s.nome],
        ['Fila', 'Em andamento', 'Concluído', 'Cancelado'],
      );
      expect(
        [for (final s in padrao) s.tipo],
        [
          StatusTipo.inicial,
          StatusTipo.emAndamento,
          StatusTipo.concluido,
          StatusTipo.cancelado,
        ],
      );
      expect([for (final s in padrao) s.ordem], [1, 2, 3, 4]);
    });

    test('já respeita as invariantes', () {
      expect(invarianteViolada(statusPadrao()), isNull);
    });
  });

  group('invarianteViolada', () {
    test('exige exatamente uma coluna Inicial', () {
      final semInicial = [
        for (final s in statusPadrao())
          if (s.tipo != StatusTipo.inicial) s,
      ];
      expect(invarianteViolada(semInicial), contains('Inicial'));

      final duasIniciais = [
        ...statusPadrao(),
        const StatusModel(
          id: 'outra',
          nome: 'Outra',
          ordem: 5,
          tipo: StatusTipo.inicial,
        ),
      ];
      expect(invarianteViolada(duasIniciais), contains('Inicial'));
    });

    test('exige pelo menos uma coluna Concluído e uma Cancelado', () {
      final semConcluido = [
        for (final s in statusPadrao())
          if (s.tipo != StatusTipo.concluido) s,
      ];
      expect(invarianteViolada(semConcluido), contains('Concluído'));

      final semCancelado = [
        for (final s in statusPadrao())
          if (s.tipo != StatusTipo.cancelado) s,
      ];
      expect(invarianteViolada(semCancelado), contains('Cancelado'));
    });
  });

  group('criarStatus', () {
    test('nasce EM_ANDAMENTO, no fim, com a ordem seguinte', () {
      final depois = criarStatus(statusPadrao(), id: 'x', nome: '  Modelando ');
      final nova = depois.last;
      expect(nova.id, 'x');
      expect(nova.nome, 'Modelando');
      expect(nova.tipo, StatusTipo.emAndamento);
      expect(nova.ordem, 5);
      expect(depois.length, 5);
    });

    test('recusa nome vazio', () {
      expect(
        () => criarStatus(statusPadrao(), id: 'x', nome: '   '),
        _recusaCom('nome'),
      );
    });

    test('não altera a lista original', () {
      final original = statusPadrao();
      criarStatus(original, id: 'x', nome: 'Nova');
      expect(original.length, 4);
    });
  });

  group('renomearStatus', () {
    test('muda só o nome', () {
      final depois = renomearStatus(statusPadrao(), 'fila', ' Entrada ');
      final fila = depois.firstWhere((s) => s.id == 'fila');
      expect(fila.nome, 'Entrada');
      expect(fila.tipo, StatusTipo.inicial);
      expect(fila.ordem, 1);
    });

    test('recusa nome vazio e coluna inexistente', () {
      expect(() => renomearStatus(statusPadrao(), 'fila', ''), _recusaCom('nome'));
      expect(
        () => renomearStatus(statusPadrao(), 'nao-existe', 'X'),
        _recusaCom('não encontrada'),
      );
    });
  });

  group('trocarTipoDoStatus', () {
    test('coluna extra pode virar Concluído', () {
      final depois = trocarTipoDoStatus(
        _comExtra(),
        'revisao',
        StatusTipo.concluido,
      );
      expect(
        depois.firstWhere((s) => s.id == 'revisao').tipo,
        StatusTipo.concluido,
      );
    });

    test('mesmo tipo não muda nada', () {
      final base = _comExtra();
      expect(
        identical(trocarTipoDoStatus(base, 'revisao', StatusTipo.emAndamento), base),
        isTrue,
      );
    });

    test('recusa tirar o tipo do único Concluído e do único Cancelado', () {
      expect(
        () => trocarTipoDoStatus(statusPadrao(), 'concluido', StatusTipo.emAndamento),
        _recusaCom('Concluído'),
      );
      expect(
        () => trocarTipoDoStatus(statusPadrao(), 'cancelado', StatusTipo.emAndamento),
        _recusaCom('Cancelado'),
      );
    });

    test('com dois Concluído, um deles pode mudar de tipo', () {
      final base = trocarTipoDoStatus(
        _comExtra(),
        'revisao',
        StatusTipo.concluido,
      );
      final depois = trocarTipoDoStatus(base, 'concluido', StatusTipo.emAndamento);
      expect(
        depois.where((s) => s.tipo == StatusTipo.concluido).map((s) => s.id),
        ['revisao'],
      );
    });

    test('marcar outra coluna como Inicial rebaixa a antiga', () {
      final depois = trocarTipoDoStatus(_comExtra(), 'revisao', StatusTipo.inicial);
      expect(
        depois.where((s) => s.tipo == StatusTipo.inicial).map((s) => s.id),
        ['revisao'],
      );
      expect(
        depois.firstWhere((s) => s.id == 'fila').tipo,
        StatusTipo.emAndamento,
      );
      expect(invarianteViolada(depois), isNull);
    });

    test('recusa tirar o tipo Inicial sem outra coluna para assumir', () {
      expect(
        () => trocarTipoDoStatus(statusPadrao(), 'fila', StatusTipo.emAndamento),
        _recusaCom('Inicial'),
      );
    });
  });

  group('excluirStatus', () {
    test('coluna extra vazia sai e a ordem é renumerada', () {
      final depois = excluirStatus(_comExtra(), 'em-andamento', commissionsNoStatus: 0);
      expect(_ids(depois), ['fila', 'concluido', 'cancelado', 'revisao']);
      expect([for (final s in depois) s.ordem], [1, 2, 3, 4]);
    });

    test('recusa coluna com commissions e diz quantas', () {
      expect(
        () => excluirStatus(_comExtra(), 'revisao', commissionsNoStatus: 2),
        _recusaCom('2 commissions'),
      );
      expect(
        () => excluirStatus(_comExtra(), 'revisao', commissionsNoStatus: 1),
        _recusaCom('1 commission.'),
      );
    });

    test('recusa excluir a coluna Inicial e o último Concluído/Cancelado', () {
      expect(
        () => excluirStatus(statusPadrao(), 'fila', commissionsNoStatus: 0),
        _recusaCom('Inicial'),
      );
      expect(
        () => excluirStatus(statusPadrao(), 'concluido', commissionsNoStatus: 0),
        _recusaCom('Concluído'),
      );
      expect(
        () => excluirStatus(statusPadrao(), 'cancelado', commissionsNoStatus: 0),
        _recusaCom('Cancelado'),
      );
    });

    test('com dois Cancelado, um deles pode ser excluído', () {
      final base = trocarTipoDoStatus(_comExtra(), 'revisao', StatusTipo.cancelado);
      final depois = excluirStatus(base, 'cancelado', commissionsNoStatus: 0);
      expect(depois.where((s) => s.tipo == StatusTipo.cancelado).length, 1);
    });
  });

  group('reordenarStatus', () {
    test('aplica a nova ordem e renumera de 1 em diante', () {
      final depois = reordenarStatus(
        statusPadrao(),
        ['cancelado', 'concluido', 'em-andamento', 'fila'],
      );
      expect(_ids(depois), ['cancelado', 'concluido', 'em-andamento', 'fila']);
      expect([for (final s in depois) s.ordem], [1, 2, 3, 4]);
    });

    test('recusa lista incompleta, repetida ou com coluna desconhecida', () {
      expect(
        () => reordenarStatus(statusPadrao(), ['fila', 'concluido']),
        _recusaCom('todas as colunas'),
      );
      expect(
        () => reordenarStatus(
          statusPadrao(),
          ['fila', 'fila', 'concluido', 'cancelado'],
        ),
        _recusaCom('todas as colunas'),
      );
      expect(
        () => reordenarStatus(
          statusPadrao(),
          ['fila', 'em-andamento', 'concluido', 'outra'],
        ),
        _recusaCom('todas as colunas'),
      );
    });
  });

  test('ordenarPorOrdem não altera a lista original', () {
    final embaralhada = [
      statusPadrao()[2],
      statusPadrao()[0],
      statusPadrao()[3],
      statusPadrao()[1],
    ];
    expect(_ids(ordenarPorOrdem(embaralhada)),
        ['fila', 'em-andamento', 'concluido', 'cancelado']);
    expect(embaralhada.first.id, 'concluido');
  });
}
