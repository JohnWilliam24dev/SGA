import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

enum _Acao { renomear, tipo, esquerda, direita, excluir }

/// Os três pontinhos do cabeçalho de uma coluna do quadro, com as ações:
/// renomear, alterar o tipo, mover para a esquerda/direita e excluir.
class ColumnMenuButton extends StatelessWidget {
  const ColumnMenuButton({
    super.key,
    required this.columnId,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.onRename,
    required this.onChangeType,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onDelete,
  });

  final String columnId;
  final bool canMoveLeft;
  final bool canMoveRight;
  final VoidCallback onRename;
  final VoidCallback onChangeType;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Menu<_Acao>(
      onSelected: (acao) {
        switch (acao) {
          case _Acao.renomear:
            onRename();
          case _Acao.tipo:
            onChangeType();
          case _Acao.esquerda:
            onMoveLeft();
          case _Acao.direita:
            onMoveRight();
          case _Acao.excluir:
            onDelete();
        }
      },
      // O Menu do Easy UI não desabilita itens: os movimentos que não cabem
      // (primeira/última coluna) simplesmente não aparecem.
      items: [
        const SelectOption(_Acao.renomear, 'Renomear'),
        const SelectOption(_Acao.tipo, 'Alterar tipo'),
        if (canMoveLeft)
          const SelectOption(_Acao.esquerda, 'Mover para a esquerda'),
        if (canMoveRight)
          const SelectOption(_Acao.direita, 'Mover para a direita'),
        const SelectOption(_Acao.excluir, 'Excluir coluna'),
      ],
      child: const Icon(Icons.more_vert),
    );
  }
}

/// Pergunta o nome de uma coluna (nova ou renomeada). `null` se cancelou.
Future<String?> pedirNomeDaColuna(
  BuildContext context, {
  required String titulo,
  required String confirmar,
  String inicial = '',
}) {
  return Modal.prompt(
    context,
    title: titulo,
    label: 'Nome da coluna',
    initialValue: inicial,
    confirmText: confirmar,
    validation: [isRequired()],
  );
}

/// Pergunta o tipo de uma coluna. `null` se cancelou.
Future<StatusTipo?> pedirTipoDaColuna(
  BuildContext context, {
  required StatusTipo atual,
}) {
  return Modal.choice<StatusTipo>(
    context,
    title: 'Tipo da coluna',
    selected: atual,
    choices: [
      for (final tipo in StatusTipo.values)
        ModalChoice(tipo, tipo.rotulo, description: tipo.descricao),
    ],
  );
}

/// Confirma a exclusão de uma coluna.
Future<bool> confirmarExclusaoDaColuna(BuildContext context, String nome) async {
  final confirmou = await Modal.confirm(
    context,
    title: 'Excluir coluna',
    message: 'A coluna "$nome" será removida do quadro.',
    confirmText: 'Excluir',
    destructive: true,
  );
  return confirmou == true;
}
