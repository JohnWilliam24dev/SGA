import '../models/models.dart';
import 'samples_concluidas.dart';
import 'samples_em_andamento.dart';
import 'samples_fila.dart';

/// Os dados completos das onze commissions de exemplo, nos status padrão
/// (Fila, Em andamento e Concluído; Cancelado começa vazio).
List<CommissionDetalhadaModel> detalhesDeExemplo() => [
  ...amostrasNaFila(),
  ...amostrasEmAndamento(),
  ...amostrasConcluidas(),
];
