import 'package:flutter/material.dart'
    show Icon, Icons, PopupMenuButton, PopupMenuItem, PopupMenuPosition;
import 'package:flutter/widgets.dart';

import '../../Core/theme/sga_theme.dart';

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
    final colors = SgaColors.of(context);
    // Azul-marinho (branco no escuro): o quadro é azul e o painel é branco,
    // então só um tom bem diferente dos dois se destaca nos dois fundos.
    final fundo = colors.heading;
    final icone = colors.dark ? const Color(0xFF09243A) : const Color(0xFFFFFFFF);
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fundo,
          border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
          boxShadow: const [
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
          child: Icon(Icons.add_rounded, color: icone, size: 30),
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
