import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/formatters.dart';

/// Rótulo pequeno em cima, valor embaixo.
class DetailField extends StatelessWidget {
  const DetailField(this.rotulo, this.valor, {super.key});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(type: LabelType.caption, text: rotulo),
        Label(text: valor),
      ],
    );
  }
}

/// Duas seções lado a lado; numa largura estreita, uma embaixo da outra.
class TwoColumns extends StatelessWidget {
  const TwoColumns(this.left, this.right, {super.key});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 12), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

/// Imagem de referência do cliente, ou um aviso quando não carrega.
class ReferenceImage extends StatelessWidget {
  const ReferenceImage({super.key, required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    // O aviso tem a mesma altura da imagem: se a imagem falhar depois de
    // carregar, a nota não encolhe.
    final aviso = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x14336E99),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: const Center(
          child: Label(
            type: LabelType.caption,
            text: 'Imagem de referência indisponível',
          ),
        ),
      ),
    );
    if (url.isEmpty) return aviso;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => aviso,
      ),
    );
  }
}

/// Os adicionais do pedido, ou o aviso de que não há nenhum.
List<Widget> adicionaisDoPedido(List<CommissionAdicionalModel> adicionais) {
  if (adicionais.isEmpty) {
    return const [
      Label(type: LabelType.caption, text: 'Nenhum adicional neste pedido.'),
    ];
  }
  return [
    for (final a in adicionais)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(type: LabelType.subtitle, text: '${a.quantidade}x ${a.nome}'),
          Label(
            type: LabelType.caption,
            text:
                '${formatarMoeda(a.valorUnitario)} cada · '
                'subtotal ${formatarMoeda(a.subtotal)}',
          ),
          if (a.descricaoCliente != null)
            Label(type: LabelType.caption, text: a.descricaoCliente!),
        ],
      ),
  ];
}
