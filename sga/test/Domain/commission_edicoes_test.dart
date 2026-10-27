import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

FakeCommissionRepository _novo() =>
    FakeCommissionRepository(latencia: Duration.zero);

const _fundo = CommissionAdicionalModel(
  adicionalId: 'a-fundo',
  nome: 'Fundo simples',
  quantidade: 2,
  descricaoCliente: null,
  valorUnitario: 40,
);

NovaCommission _nova({List<CommissionAdicionalModel> adicionais = const []}) {
  return NovaCommission(
    nomeCliente: 'Ana Souza',
    contato: '@anasouza',
    descricao: 'Arte de capa',
    tipoProdutoId: 'tp-ilustração',
    tipoProdutoNome: 'Ilustração',
    precoBase: 120,
    adicionais: adicionais,
  );
}

CommissionResumoModel _resumo(List<CommissionColumn> quadro, String id) =>
    quadro.expand((c) => c.commissions).firstWhere((c) => c.id == id);

void main() {
  group('criar pedido', () {
    test('entra no fim da coluna inicial com o valor simulado somado', () async {
      final repo = _novo();
      final antes = (await repo.carregarQuadro()).first.commissions.length;

      final criada = await repo.criar(_nova(adicionais: const [_fundo]));

      expect(criada.precoSimulado, 200);
      expect(criada.statusId, 'fila');
      final fila = (await repo.carregarQuadro()).first;
      expect(fila.commissions.length, antes + 1);
      expect(fila.commissions.last.id, criada.id);
      expect((await repo.carregarDetalhe(criada.id)).nomeCliente, 'Ana Souza');
    });

    test('avisa os ouvintes, para o quadro se atualizar sozinho', () async {
      final repo = _novo();
      var avisos = 0;
      repo.addListener(() => avisos++);

      await repo.criar(_nova());

      expect(avisos, 1);
    });

    test('recusa adicional repetido e quantidade fora do limite', () async {
      final repo = _novo();
      expect(
        repo.criar(_nova(adicionais: const [_fundo, _fundo])),
        throwsA(isA<CommissionRegraException>()),
      );
      expect(
        repo.criar(
          _nova(
            adicionais: const [
              CommissionAdicionalModel(
                adicionalId: 'a-pose',
                nome: 'Pose extra',
                quantidade: 21,
                descricaoCliente: null,
                valorUnitario: 60,
              ),
            ],
          ),
        ),
        throwsA(isA<CommissionRegraException>()),
      );
    });
  });

  group('adicionais do pedido', () {
    test('trocar os adicionais acerta o valor simulado no detalhe e no card', () async {
      final repo = _novo();
      // c1: R$ 280 com 1x Fundo simples (R$ 40); passa para 2x.
      await repo.salvarAdicionais('c1', const [_fundo]);

      expect((await repo.carregarDetalhe('c1')).precoSimulado, 320);
      expect(_resumo(await repo.carregarQuadro(), 'c1').precoSimulado, 320);

      await repo.salvarAdicionais('c1', const []);
      expect((await repo.carregarDetalhe('c1')).precoSimulado, 240);
    });

    test('não troca adicionais de pedido encerrado', () async {
      final repo = _novo();
      await repo.mover(commissionId: 'c1', paraColunaId: 'concluido', paraIndice: 0);

      expect(
        repo.salvarAdicionais('c1', const []),
        throwsA(isA<CommissionRegraException>()),
      );
    });
  });

  group('orçamento', () {
    test('fechar grava o valor, avisa o card e trava a edição', () async {
      final repo = _novo();
      expect(await repo.orcamentoEditavel('c1'), isTrue);

      await repo.fecharOrcamento('c1', 300);

      expect(_resumo(await repo.carregarQuadro(), 'c1').orcamentoFinal, 300);
      expect(await repo.orcamentoEditavel('c1'), isFalse);
      expect(
        repo.fecharOrcamento('c1', 350),
        throwsA(isA<CommissionRegraException>()),
      );
    });

    test('pedido que entra em Concluído sem fechar não pode mais ser editado', () async {
      final repo = _novo();
      await repo.mover(commissionId: 'c1', paraColunaId: 'concluido', paraIndice: 0);

      expect(await repo.orcamentoEditavel('c1'), isFalse);
      expect(
        repo.fecharOrcamento('c1', 300),
        throwsA(isA<CommissionRegraException>()),
      );
    });

    test('reabrir devolve a edição e tira o valor final do card', () async {
      final repo = _novo();
      expect(await repo.orcamentoReabrivel('c1'), isFalse);
      await repo.fecharOrcamento('c1', 300);
      expect(await repo.orcamentoReabrivel('c1'), isTrue);

      await repo.reabrirOrcamento('c1');

      expect(_resumo(await repo.carregarQuadro(), 'c1').orcamentoFinal, isNull);
      expect(await repo.orcamentoEditavel('c1'), isTrue);
      expect(await repo.orcamentoReabrivel('c1'), isFalse);
    });

    test('reabrir recusa orçamento já aberto e pedido encerrado', () async {
      final repo = _novo();
      expect(repo.reabrirOrcamento('c1'), throwsA(isA<CommissionRegraException>()));

      await repo.fecharOrcamento('c1', 300);
      await repo.mover(commissionId: 'c1', paraColunaId: 'concluido', paraIndice: 0);
      expect(await repo.orcamentoReabrivel('c1'), isFalse);
      expect(repo.reabrirOrcamento('c1'), throwsA(isA<CommissionRegraException>()));
    });

    test('recusa valor negativo', () async {
      expect(
        _novo().fecharOrcamento('c1', -1),
        throwsA(isA<CommissionRegraException>()),
      );
    });
  });
}
