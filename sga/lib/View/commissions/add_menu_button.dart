import 'package:flutter/material.dart'
    show Icon, Icons, PopupMenuButton, PopupMenuItem, PopupMenuPosition;
import 'package:flutter/widgets.dart';

enum _Acao { coluna, pedido }

/// Botão flutuante "+" do quadro. Abre um menu, no mesmo estilo do menu do
/// perfil, com Adicionar Coluna e Adicionar Pedido (cabe bem no celular).
class AddMenuButton extends StatelessWidget {
  const AddMenuButton({
    super.key,
    required this.onAddColumn,
    required this.onAddOrder,
  });

  final VoidCallback onAddColumn;
  final VoidCallback onAddOrder;

  @override
  Widget build(BuildContext context) {
    // Bola branca com "+" preto nos dois temas: destaca do quadro azul e
    // do painel.
    return PopupMenuButton<_Acao>(
      tooltip: 'Adicionar',
      position: PopupMenuPosition.over,
      // Abre para cima, sem cobrir o próprio botão.
      offset: const Offset(0, -112),
      constraints: const BoxConstraints(minWidth: 190),
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      onSelected: (acao) =>
          acao == _Acao.coluna ? onAddColumn() : onAddOrder(),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _Acao.coluna,
          child: _Item(Icons.view_column_outlined, 'Adicionar Coluna'),
        ),
        PopupMenuItem(
          value: _Acao.pedido,
          child: _Item(Icons.note_add_outlined, 'Adicionar Pedido'),
        ),
      ],
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Color(0x40003A70),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add_rounded, color: Color(0xFF000000), size: 30),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.icone, this.texto);

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icone, size: 20),
      const SizedBox(width: 10),
      Text(texto),
    ],
  );
}
