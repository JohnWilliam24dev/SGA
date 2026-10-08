import 'package:flutter_test/flutter_test.dart';
import 'package:sga/Shared/shared.dart';

void main() {
  group('formatarMoeda', () {
    test('agrupa milhares e usa vírgula nos centavos', () {
      expect(formatarMoeda(1234.5), 'R\$ 1.234,50');
      expect(formatarMoeda(1234567.89), 'R\$ 1.234.567,89');
    });

    test('zero, valor pequeno e negativo', () {
      expect(formatarMoeda(0), 'R\$ 0,00');
      expect(formatarMoeda(7.05), 'R\$ 7,05');
      expect(formatarMoeda(-5), '-R\$ 5,00');
    });
  });

  test('formatarData e formatarDataHora usam dois dígitos', () {
    final data = DateTime(2026, 3, 5, 9, 7);
    expect(formatarData(data), '05/03/2026');
    expect(formatarDataHora(data), '05/03/2026 às 09:07');
  });
}
