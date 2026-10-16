/// Regra de negócio violada ao mexer numa commission (ex.: orçamento já
/// fechado). Na API real chega como 400/409; aqui nasce no repositório
/// simulado e a tela mostra a [mensagem] como está.
class CommissionRegraException implements Exception {
  const CommissionRegraException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}
