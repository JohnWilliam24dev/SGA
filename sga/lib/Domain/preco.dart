import 'models/models.dart';

/// Arredonda para centavos (meio para cima), como a API faz antes de
/// multiplicar pela quantidade.
double arredondarCentavos(double valor) => (valor * 100).round() / 100;

/// Quanto custa uma unidade do [adicional] num tipo de [precoBase]: o valor
/// fixo, ou a porcentagem do preço base.
double valorUnitarioDoAdicional(AdicionalModel adicional, double precoBase) {
  final fixo = adicional.precoFixo;
  if (fixo != null) return arredondarCentavos(fixo);
  return arredondarCentavos(precoBase * (adicional.porcentagem ?? 0) / 100);
}

/// Soma dos subtotais dos adicionais de um pedido.
double somaDosAdicionais(Iterable<CommissionAdicionalModel> adicionais) =>
    adicionais.fold<double>(0, (soma, a) => soma + a.subtotal);

/// Maior quantidade permitida de um mesmo adicional num pedido.
const int quantidadeMaximaDeAdicional = 20;
