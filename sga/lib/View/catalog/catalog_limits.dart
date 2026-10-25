/// Limites do servidor para os campos do catálogo (a API recusa o que passar
/// disso), checados antes de enviar para dar o aviso na hora.
const _nomeMax = 80;
const _descricaoMax = 500;
const _precoMax = 99999999.99;
const _porcentagemMax = 999.99;
const _vinculosMax = 100;

/// Motivo de o tipo não poder ser salvo, ou `null` se está tudo certo.
String? erroDoTipo({
  required String nome,
  required double? preco,
  required int vinculados,
}) {
  if (nome.trim().isEmpty || preco == null || preco < 0) {
    return 'Informe um nome e um preço base válido.';
  }
  if (nome.trim().length > _nomeMax) {
    return 'O nome pode ter no máximo $_nomeMax caracteres.';
  }
  if (preco > _precoMax) return 'O preço base pode ir até R\$ 99.999.999,99.';
  if (vinculados > _vinculosMax) {
    return 'Um tipo pode ter no máximo $_vinculosMax adicionais vinculados.';
  }
  return null;
}

/// Motivo de o adicional não poder ser salvo, ou `null` se está tudo certo.
String? erroDoAdicional({
  required String nome,
  required String descricao,
  required double? valor,
  required bool porcentagem,
}) {
  if (nome.trim().isEmpty || valor == null || valor < 0) {
    return 'Informe nome e valor válido.';
  }
  if (nome.trim().length > _nomeMax) {
    return 'O nome pode ter no máximo $_nomeMax caracteres.';
  }
  if (descricao.trim().length > _descricaoMax) {
    return 'A descrição pode ter no máximo $_descricaoMax caracteres.';
  }
  if (porcentagem && valor > _porcentagemMax) {
    return 'A porcentagem pode ir até 999,99%.';
  }
  if (!porcentagem && valor > _precoMax) {
    return 'O valor pode ir até R\$ 99.999.999,99.';
  }
  return null;
}
