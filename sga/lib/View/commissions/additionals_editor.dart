import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/material.dart'
    show IconButton, Icons, PopupMenuButton, PopupMenuItem;
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/formatters.dart';

/// Lista editável dos adicionais de um pedido: ajusta a quantidade, remove e
/// adiciona outro entre os [disponiveis] do tipo. Não guarda estado: quem
/// usa recebe a nova lista por [onChanged].
class AdditionalsEditor extends StatelessWidget {
  const AdditionalsEditor({
    super.key,
    required this.itens,
    required this.disponiveis,
    required this.precoBase,
    required this.onChanged,
  });

  final List<CommissionAdicionalModel> itens;
  final List<AdicionalModel> disponiveis;
  final double precoBase;
  final ValueChanged<List<CommissionAdicionalModel>> onChanged;

  void _quantidade(CommissionAdicionalModel item, int delta) {
    final nova = item.quantidade + delta;
    if (nova < 1 || nova > quantidadeMaximaDeAdicional) return;
    onChanged([
      for (final i in itens)
        if (i.adicionalId == item.adicionalId) _comQuantidade(i, nova) else i,
    ]);
  }

  CommissionAdicionalModel _comQuantidade(CommissionAdicionalModel i, int q) =>
      CommissionAdicionalModel(
        adicionalId: i.adicionalId,
        nome: i.nome,
        quantidade: q,
        descricaoCliente: i.descricaoCliente,
        valorUnitario: i.valorUnitario,
      );

  void _adicionar(AdicionalModel a) => onChanged([
    ...itens,
    CommissionAdicionalModel(
      adicionalId: a.id,
      nome: a.nome,
      quantidade: 1,
      valorUnitario: valorUnitarioDoAdicional(a, precoBase),
    ),
  ]);

  Widget _linha(CommissionAdicionalModel item) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label(type: LabelType.subtitle, text: '${item.quantidade}x ${item.nome}'),
              Label(
                type: LabelType.caption,
                text:
                    '${formatarMoeda(item.valorUnitario)} cada · '
                    'subtotal ${formatarMoeda(item.subtotal)}',
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Diminuir quantidade',
          onPressed: item.quantidade > 1 ? () => _quantidade(item, -1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        IconButton(
          tooltip: 'Aumentar quantidade',
          onPressed: () => _quantidade(item, 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
        IconButton(
          tooltip: 'Remover adicional',
          onPressed: () => onChanged([
            for (final i in itens)
              if (i.adicionalId != item.adicionalId) i,
          ]),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final usados = {for (final i in itens) i.adicionalId};
    final restantes = [
      for (final a in disponiveis)
        if (a.habilitado && !usados.contains(a.id)) a,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (itens.isEmpty)
          const Label(type: LabelType.caption, text: 'Nenhum adicional neste pedido.'),
        for (final item in itens) _linha(item),
        PopupMenuButton<AdicionalModel>(
          tooltip: 'Adicionar adicional',
          enabled: restantes.isNotEmpty,
          onSelected: _adicionar,
          itemBuilder: (_) => [
            for (final a in restantes)
              PopupMenuItem(
                value: a,
                child: Text(
                  '${a.nome} · '
                  '${formatarMoeda(valorUnitarioDoAdicional(a, precoBase))}',
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded),
                const SizedBox(width: 6),
                Label(
                  text: restantes.isEmpty
                      ? 'Nenhum outro adicional disponível'
                      : 'Adicionar adicional',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
