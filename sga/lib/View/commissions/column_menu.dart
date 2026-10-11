import 'package:flutter/material.dart';

import '../../Domain/domain.dart';

enum _Acao { renomear, tipo, esquerda, direita, excluir }

/// Os três pontinhos do cabeçalho de uma coluna do quadro, com as ações:
/// renomear, alterar o tipo, mover para a esquerda/direita e excluir.
///
/// Só avisa o que foi escolhido; quem faz a alteração (e mostra o motivo
/// quando uma regra do quadro a recusa) é a página.
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
    return PopupMenuButton<_Acao>(
      key: ValueKey('column-menu-$columnId'),
      tooltip: 'Opções da coluna',
      padding: EdgeInsets.zero,
      iconSize: 20,
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
      itemBuilder: (_) => [
        const PopupMenuItem(value: _Acao.renomear, child: Text('Renomear')),
        const PopupMenuItem(value: _Acao.tipo, child: Text('Alterar tipo')),
        PopupMenuItem(
          value: _Acao.esquerda,
          enabled: canMoveLeft,
          child: const Text('Mover para a esquerda'),
        ),
        PopupMenuItem(
          value: _Acao.direita,
          enabled: canMoveRight,
          child: const Text('Mover para a direita'),
        ),
        const PopupMenuItem(value: _Acao.excluir, child: Text('Excluir coluna')),
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
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _NomeDialog(titulo: titulo, confirmar: confirmar, inicial: inicial),
  );
}

/// Pergunta o tipo de uma coluna. `null` se cancelou.
Future<StatusTipo?> pedirTipoDaColuna(
  BuildContext context, {
  required StatusTipo atual,
}) {
  return showDialog<StatusTipo>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      title: const Text('Tipo da coluna'),
      children: [
        for (final opcao in StatusTipo.values)
          SimpleDialogOption(
            key: ValueKey('tipo-${opcao.name}'),
            onPressed: () => Navigator.of(dialogContext).pop(opcao),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opcao == atual ? '${opcao.rotulo} (atual)' : opcao.rotulo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(opcao.descricao),
              ],
            ),
          ),
      ],
    ),
  );
}

/// Confirma a exclusão de uma coluna.
Future<bool> confirmarExclusaoDaColuna(BuildContext context, String nome) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Excluir coluna'),
      content: Text('A coluna "$nome" será removida do quadro.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return confirmou == true;
}

class _NomeDialog extends StatefulWidget {
  const _NomeDialog({
    required this.titulo,
    required this.confirmar,
    required this.inicial,
  });

  final String titulo;
  final String confirmar;
  final String inicial;

  @override
  State<_NomeDialog> createState() => _NomeDialogState();
}

class _NomeDialogState extends State<_NomeDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.inicial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        key: const ValueKey('status-nome-campo'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nome da coluna'),
        onSubmitted: (valor) => Navigator.of(context).pop(valor),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmar),
        ),
      ],
    );
  }
}
