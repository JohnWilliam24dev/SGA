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
      child: const Icon(Icons.more_vert),
      items: [
        const MenuItem(id: _Acao.renomear, text: 'Renomear'),
        const MenuItem(id: _Acao.tipo, text: 'Alterar tipo'),
        MenuItem(
          id: _Acao.esquerda,
          enabled: canMoveLeft,
          text: 'Mover para a esquerda',
        ),
        MenuItem(
          id: _Acao.direita,
          enabled: canMoveRight,
          text: 'Mover para a direita',
        ),
        const MenuItem(id: _Acao.excluir, text: 'Excluir coluna'),
      ],
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
    titulo,
    initialValue: inicial,
    validation: [isRequired()],
  );
}

/// Pergunta o tipo de uma coluna. `null` se cancelou.
Future<StatusTipo?> pedirTipoDaColuna(
  BuildContext context, {
  required StatusTipo atual,
}) {
  return Modal.choice<StatusTipo>(
    choices: StatusTipo.values
        .map((t) => Choice(
              id: t,
              label: t.rotulo,
              description: t.descricao,
            ))
        .toList(),
    selectedId: atual,
  );
}

/// Confirma a exclusão de uma coluna.
Future<bool> confirmarExclusaoDaColuna(BuildContext context, String nome) async {
  return await Modal.confirm(
    'Excluir coluna',
    description: 'A coluna "$nome" será removida do quadro.',
  ) ?? false;
}
