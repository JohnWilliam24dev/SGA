import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

CommissionAdicionalModel _adicional(int i) => CommissionAdicionalModel(
      adicionalId: 'a$i',
      nome: 'Adicional $i',
      quantidade: 1,
      descricaoCliente: null,
      valorUnitario: 10,
    );

void main() {
  group('colunas', () {
    test('o limite é de $statusPorMakerMaximo por Maker', () {
      var status = statusPadrao();
      while (status.length < statusPorMakerMaximo) {
        status = criarStatus(status, id: 'x${status.length}', nome: 'Coluna ${status.length}');
      }
      expect(status.length, statusPorMakerMaximo);
      expect(
        () => criarStatus(status, id: 'extra', nome: 'Mais uma'),
        throwsA(isA<StatusRegraException>().having(
          (e) => e.mensagem, 'mensagem', contains('$statusPorMakerMaximo'),
        )),
      );
    });

    test('nome com mais de $nomeMaximo caracteres é recusado ao criar e renomear', () {
      final longo = 'a' * (nomeMaximo + 1);
      expect(
        () => criarStatus(statusPadrao(), id: 'x', nome: longo),
        throwsA(isA<StatusRegraException>()),
      );
      expect(
        () => renomearStatus(statusPadrao(), statusPadrao().first.id, longo),
        throwsA(isA<StatusRegraException>()),
      );
      expect(
        criarStatus(statusPadrao(), id: 'x', nome: 'a' * nomeMaximo).last.nome.length,
        nomeMaximo,
      );
    });

    test('coluna nova nunca nasce como INICIAL', () {
      final nova = criarStatus(statusPadrao(), id: 'x', nome: 'Nova').last;
      expect(nova.tipo, StatusTipo.emAndamento);
    });
  });

  group('adicionais do pedido', () {
    test('até $adicionaisPorPedidoMaximo diferentes passam; o 21º é recusado', () async {
      final repo = FakeCommissionRepository(latencia: Duration.zero);

      await repo.salvarAdicionais('c1', [
        for (var i = 0; i < adicionaisPorPedidoMaximo; i++) _adicional(i),
      ]);

      await expectLater(
        repo.salvarAdicionais('c1', [
          for (var i = 0; i <= adicionaisPorPedidoMaximo; i++) _adicional(i),
        ]),
        throwsA(isA<CommissionRegraException>()),
      );
    });
  });
}
