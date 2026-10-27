import 'package:flutter_test/flutter_test.dart';
import 'package:sga/View/reports/periodo_relatorio.dart';

void main() {
  final hoje = DateTime(2026, 1, 15);

  test('este mês deixa o servidor escolher (sem datas)', () {
    expect(PeriodoRelatorio.esteMes.intervalo(hoje), (de: null, ate: null));
  });

  test('mês passado atravessa a virada do ano', () {
    final i = PeriodoRelatorio.mesPassado.intervalo(hoje);
    expect((i.de, i.ate), (DateTime(2025, 12), DateTime(2025, 12, 31)));
  });

  test('últimos 30 dias inclui hoje e cabe no teto de 366 dias', () {
    final i = PeriodoRelatorio.ultimos30.intervalo(hoje);
    expect(i.ate!.difference(i.de!).inDays, 29);
    final ano = PeriodoRelatorio.esteAno.intervalo(hoje);
    expect(ano.ate!.difference(ano.de!).inDays + 1 <= 366, isTrue);
  });

  test('próximo percorre a lista e volta ao começo', () {
    expect(PeriodoRelatorio.esteAno.proximo, PeriodoRelatorio.esteMes);
  });
}
