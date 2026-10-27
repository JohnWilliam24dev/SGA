/// Períodos prontos do relatório. `intervalo` devolve `null` no mês corrente,
/// para o servidor usar o mês no fuso do Maker.
enum PeriodoRelatorio {
  esteMes('Este mês'),
  mesPassado('Mês passado'),
  ultimos30('Últimos 30 dias'),
  esteAno('Este ano');

  const PeriodoRelatorio(this.rotulo);

  final String rotulo;

  /// Próximo da lista, voltando ao começo no fim.
  PeriodoRelatorio get proximo =>
      values[(index + 1) % values.length];

  ({DateTime? de, DateTime? ate}) intervalo(DateTime hoje) => switch (this) {
    esteMes => (de: null, ate: null),
    mesPassado => (
      de: DateTime(hoje.year, hoje.month - 1),
      ate: DateTime(hoje.year, hoje.month, 0),
    ),
    ultimos30 => (
      de: DateTime(hoje.year, hoje.month, hoje.day - 29),
      ate: DateTime(hoje.year, hoje.month, hoje.day),
    ),
    esteAno => (
      de: DateTime(hoje.year),
      ate: DateTime(hoje.year, 12, 31),
    ),
  };
}
