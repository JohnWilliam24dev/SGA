/// Formata um valor em reais: `1234.5` vira `R$ 1.234,50`.
String formatarMoeda(double valor) {
  final centavosTotais = (valor.abs() * 100).round();
  final reais = (centavosTotais ~/ 100).toString();
  final centavos = (centavosTotais % 100).toString().padLeft(2, '0');

  final comPontos = StringBuffer();
  for (var i = 0; i < reais.length; i++) {
    if (i > 0 && (reais.length - i) % 3 == 0) comPontos.write('.');
    comPontos.write(reais[i]);
  }

  final sinal = valor < 0 ? '-' : '';
  return '${sinal}R\$ $comPontos,$centavos';
}

/// Formata uma data no horário local: `05/10/2026`.
String formatarData(DateTime data) {
  final d = data.toLocal();
  return '${_dois(d.day)}/${_dois(d.month)}/${d.year}';
}

/// Formata data e hora no horário local: `05/10/2026 às 14:30`.
String formatarDataHora(DateTime data) {
  final d = data.toLocal();
  return '${formatarData(d)} às ${_dois(d.hour)}:${_dois(d.minute)}';
}

String _dois(int n) => n.toString().padLeft(2, '0');
