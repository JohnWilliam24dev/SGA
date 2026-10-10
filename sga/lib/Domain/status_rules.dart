import 'models/status_model.dart';

/// Uma regra do kanban foi violada (ex.: excluir a última coluna Cancelado).
/// A [mensagem] já está pronta para ser mostrada ao usuário.
///
/// Na API real, o mesmo erro chega como 400/409; aqui nasce das funções
/// abaixo, que o repositório simulado usa e a API vai espelhar.
class StatusRegraException implements Exception {
  const StatusRegraException(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Textos de cada [StatusTipo] para a interface.
extension StatusTipoTexto on StatusTipo {
  String get rotulo => switch (this) {
        StatusTipo.inicial => 'Inicial',
        StatusTipo.emAndamento => 'Em andamento',
        StatusTipo.concluido => 'Concluído',
        StatusTipo.cancelado => 'Cancelado',
      };

  String get descricao => switch (this) {
        StatusTipo.inicial => 'Onde entram os pedidos novos. Só pode haver uma.',
        StatusTipo.emAndamento => 'Etapas de trabalho, quantas você quiser.',
        StatusTipo.concluido => 'Pedidos entregues. Contam nos relatórios.',
        StatusTipo.cancelado => 'Pedidos que não vão seguir adiante.',
      };
}

/// Os 4 status que todo Maker recebe no cadastro (5.2).
List<StatusModel> statusPadrao() => [
      const StatusModel(
        id: 'fila',
        nome: 'Fila',
        ordem: 1,
        tipo: StatusTipo.inicial,
      ),
      const StatusModel(
        id: 'em-andamento',
        nome: 'Em andamento',
        ordem: 2,
        tipo: StatusTipo.emAndamento,
      ),
      const StatusModel(
        id: 'concluido',
        nome: 'Concluído',
        ordem: 3,
        tipo: StatusTipo.concluido,
      ),
      const StatusModel(
        id: 'cancelado',
        nome: 'Cancelado',
        ordem: 4,
        tipo: StatusTipo.cancelado,
      ),
    ];

/// Devolve [status] ordenados por `ordem`, sem alterar a lista original.
List<StatusModel> ordenarPorOrdem(List<StatusModel> status) {
  return [...status]..sort((a, b) => a.ordem.compareTo(b.ordem));
}

/// Confere as invariantes do kanban (5.3): exatamente 1 `INICIAL`, pelo menos
/// 1 `CONCLUIDO` e 1 `CANCELADO`. Devolve o problema, ou `null` se está tudo
/// certo.
String? invarianteViolada(List<StatusModel> status) {
  final iniciais = status.where((s) => s.tipo == StatusTipo.inicial).length;
  if (iniciais != 1) {
    return 'O quadro precisa ter exatamente uma coluna do tipo Inicial.';
  }
  if (!status.any((s) => s.tipo == StatusTipo.concluido)) {
    return 'O quadro precisa ter pelo menos uma coluna do tipo Concluído.';
  }
  if (!status.any((s) => s.tipo == StatusTipo.cancelado)) {
    return 'O quadro precisa ter pelo menos uma coluna do tipo Cancelado.';
  }
  return null;
}

/// Nova coluna no fim do quadro. Colunas extras são sempre `EM_ANDAMENTO`.
List<StatusModel> criarStatus(
  List<StatusModel> atuais, {
  required String id,
  required String nome,
}) {
  final limpo = _nomeValido(nome);
  final ultima = atuais.fold<int>(0, (m, s) => s.ordem > m ? s.ordem : m);
  return [
    ...atuais,
    StatusModel(
      id: id,
      nome: limpo,
      ordem: ultima + 1,
      tipo: StatusTipo.emAndamento,
    ),
  ];
}

/// Renomear é sempre permitido, desde que o nome não fique vazio.
List<StatusModel> renomearStatus(
  List<StatusModel> atuais,
  String id,
  String nome,
) {
  final alvo = _buscar(atuais, id);
  final limpo = _nomeValido(nome);
  return [
    for (final s in atuais)
      if (s.id == alvo.id) s.copyWith(nome: limpo) else s,
  ];
}

/// Troca o `tipo` de uma coluna respeitando as invariantes.
///
/// Marcar outra coluna como `INICIAL` passa a inicial antiga para
/// `EM_ANDAMENTO` na mesma operação (é a única forma de mudar qual coluna
/// recebe os pedidos novos). Tirar o tipo da última coluna `INICIAL`,
/// `CONCLUIDO` ou `CANCELADO` é recusado.
List<StatusModel> trocarTipoDoStatus(
  List<StatusModel> atuais,
  String id,
  StatusTipo novoTipo,
) {
  final alvo = _buscar(atuais, id);
  if (alvo.tipo == novoTipo) return atuais;

  final resultado = [
    for (final s in atuais)
      if (s.id == alvo.id)
        s.copyWith(tipo: novoTipo)
      else if (novoTipo == StatusTipo.inicial && s.tipo == StatusTipo.inicial)
        s.copyWith(tipo: StatusTipo.emAndamento)
      else
        s,
  ];
  if (invarianteViolada(resultado) != null) {
    throw StatusRegraException(_motivoDoUltimo(alvo.tipo, 'mudar o tipo'));
  }
  return resultado;
}

/// Exclui uma coluna. Recusa se ela é a última de um tipo obrigatório ou se
/// ainda tem commissions ([commissionsNoStatus]): mova os cartões antes.
List<StatusModel> excluirStatus(
  List<StatusModel> atuais,
  String id, {
  required int commissionsNoStatus,
}) {
  final alvo = _buscar(atuais, id);
  final restantes = [
    for (final s in atuais)
      if (s.id != alvo.id) s,
  ];
  if (invarianteViolada(restantes) != null) {
    throw StatusRegraException(_motivoDoUltimo(alvo.tipo, 'excluir'));
  }
  if (commissionsNoStatus > 0) {
    final cartoes = commissionsNoStatus == 1
        ? '1 commission'
        : '$commissionsNoStatus commissions';
    throw StatusRegraException(
      'Esta coluna tem $cartoes. Mova os cartões para outra coluna antes de excluir.',
    );
  }
  return _renumerar(restantes);
}

/// Reordena as colunas. [idsNaNovaOrdem] precisa ter todas as colunas, uma
/// vez cada.
List<StatusModel> reordenarStatus(
  List<StatusModel> atuais,
  List<String> idsNaNovaOrdem,
) {
  final porId = {for (final s in atuais) s.id: s};
  final completa = idsNaNovaOrdem.length == atuais.length &&
      idsNaNovaOrdem.toSet().length == atuais.length &&
      idsNaNovaOrdem.every(porId.containsKey);
  if (!completa) {
    throw const StatusRegraException(
      'A nova ordem precisa listar todas as colunas, sem repetir.',
    );
  }
  return _renumerar([for (final id in idsNaNovaOrdem) porId[id]!]);
}

String _motivoDoUltimo(StatusTipo tipo, String acao) {
  if (tipo == StatusTipo.inicial) {
    return 'Esta é a coluna Inicial e o quadro precisa de uma. '
        'Para ${acao == 'excluir' ? 'excluí-la' : 'mudar o tipo dela'}, '
        'marque antes outra coluna como Inicial.';
  }
  return 'Esta é a última coluna do tipo ${tipo.rotulo}; '
      'o quadro precisa de pelo menos uma.';
}

String _nomeValido(String nome) {
  final limpo = nome.trim();
  if (limpo.isEmpty) {
    throw const StatusRegraException('Informe o nome da coluna.');
  }
  return limpo;
}

StatusModel _buscar(List<StatusModel> atuais, String id) {
  for (final s in atuais) {
    if (s.id == id) return s;
  }
  throw const StatusRegraException('Coluna não encontrada.');
}

List<StatusModel> _renumerar(List<StatusModel> lista) {
  return [
    for (var i = 0; i < lista.length; i++) lista[i].copyWith(ordem: i + 1),
  ];
}
