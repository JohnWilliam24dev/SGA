import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';

void main() {
  group('StatusModel', () {
    test('lê o JSON da API e converte o tipo', () {
      final status = StatusModel.fromJson({
        'id': 's1',
        'nome': 'Em andamento',
        'ordem': 2,
        'tipo': 'EM_ANDAMENTO',
      });

      expect(status.tipo, StatusTipo.emAndamento);
      expect(status.ordem, 2);
      expect(status.toJson()['tipo'], 'EM_ANDAMENTO');
    });

    test('tipo desconhecido falha alto', () {
      expect(() => StatusTipo.fromApi('OUTRO'), throwsFormatException);
    });
  });

  group('TipoProdutoModel', () {
    test('aceita preço inteiro vindo do JSON', () {
      final tipo = TipoProdutoModel.fromJson({
        'id': 't1',
        'nome': 'Ilustração',
        'precoBase': 100,
        'habilitado': true,
      });

      expect(tipo.precoBase, 100.0);
      expect(TipoProdutoModel.fromJson(tipo.toJson()), tipo);
    });
  });

  group('AdicionalModel', () {
    test('campos opcionais podem faltar', () {
      final adicional = AdicionalModel.fromJson({
        'id': 'a1',
        'nome': 'Fundo detalhado',
        'habilitado': true,
      });

      expect(adicional.descricao, isNull);
      expect(adicional.precoFixo, isNull);
      expect(adicional.porcentagem, isNull);
    });

    test('lê preço fixo e porcentagem', () {
      final adicional = AdicionalModel.fromJson({
        'id': 'a2',
        'nome': 'Urgência',
        'precoFixo': 20,
        'porcentagem': 15.5,
        'habilitado': false,
      });

      expect(adicional.precoFixo, 20.0);
      expect(adicional.porcentagem, 15.5);
      expect(AdicionalModel.fromJson(adicional.toJson()), adicional);
    });
  });

  group('ProdutoModel', () {
    test('ida e volta pelo JSON', () {
      const produto = ProdutoModel(
        id: 'p1',
        nome: 'Retrato',
        imagemUrl: 'https://exemplo.com/p1.png',
        tipoProdutoId: 't1',
      );

      expect(ProdutoModel.fromJson(produto.toJson()), produto);
    });
  });

  group('Commission', () {
    final resumoJson = {
      'id': 'c1',
      'token': 'abc123',
      'nomeCliente': 'Maria',
      'tipoProdutoNome': 'Ilustração',
      'precoSimulado': 150,
      'orcamentoFinal': null,
      'posicao': 0,
      'criadoEm': '2026-10-05T12:00:00.000Z',
    };

    test('resumo lê datas e orçamento final nulo', () {
      final resumo = CommissionResumoModel.fromJson(resumoJson);

      expect(resumo.precoSimulado, 150.0);
      expect(resumo.orcamentoFinal, isNull);
      expect(resumo.criadoEm, DateTime.utc(2026, 10, 5, 12));
    });

    test('detalhada traz os adicionais e faz ida e volta', () {
      final detalhada = CommissionDetalhadaModel.fromJson({
        ...resumoJson,
        'statusId': 's1',
        'tipoProdutoId': 't1',
        'contato': '@maria',
        'descricao': 'Retrato da minha gata',
        'imagemRefUrl': 'https://exemplo.com/ref.png',
        'adicionais': [
          {
            'adicionalId': 'a1',
            'nome': 'Fundo detalhado',
            'quantidade': 2,
            'descricaoCliente': null,
            'valorUnitario': 30,
          },
        ],
      });

      expect(detalhada.email, isNull);
      expect(detalhada.adicionais.single.subtotal, 60.0);
      expect(CommissionDetalhadaModel.fromJson(detalhada.toJson()), detalhada);
    });

    test('resumo e detalhada não são iguais entre si', () {
      final resumo = CommissionResumoModel.fromJson(resumoJson);
      final detalhada = CommissionDetalhadaModel.fromJson({
        ...resumoJson,
        'statusId': 's1',
        'tipoProdutoId': 't1',
        'contato': '@maria',
        'descricao': 'x',
        'imagemRefUrl': 'u',
        'adicionais': <Map<String, dynamic>>[],
      });

      expect(resumo == detalhada, isFalse);
      expect(detalhada == resumo, isFalse);
    });
  });
}
