import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Domain/domain.dart';
import 'package:sga/View/commissions/commission_card.dart';

CommissionResumoModel _cartao({double? simulado, double? final_}) =>
    CommissionResumoModel(
      id: 'c1',
      token: 'T',
      nomeCliente: 'Ana',
      precoSimulado: simulado,
      orcamentoFinal: final_,
      posicao: 0,
      criadoEm: DateTime(2026, 10, 26),
    );

void main() {
  test('orçamento fechado vence o simulado', () {
    expect(valorDoCard(_cartao(simulado: 100, final_: 150)), contains('150'));
  });

  test('só simulado: aparece marcado como simulado', () {
    expect(valorDoCard(_cartao(simulado: 100)), contains('(simulado)'));
  });

  test('sem simulado e sem orçamento fechado: Orçamento Pendente', () {
    expect(valorDoCard(_cartao()), 'Orçamento Pendente');
  });
}
