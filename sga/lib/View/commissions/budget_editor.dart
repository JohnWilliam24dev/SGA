import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/formatters.dart';
import 'detail_parts.dart';

/// Orçamento do pedido: o valor simulado e, enquanto a edição está aberta,
/// o campo do orçamento ao lado do botão Fechar Orçamento. Depois de fechado
/// (ou com o pedido encerrado) o valor só é exibido.
class BudgetEditor extends StatefulWidget {
  const BudgetEditor({
    super.key,
    required this.simulado,
    required this.orcamentoFinal,
    required this.editavel,
    required this.onFechar,
  });

  final double simulado;
  final double? orcamentoFinal;
  final bool editavel;
  final Future<void> Function(double valor) onFechar;

  @override
  State<BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<BudgetEditor> {
  late final _valor = TextEditingController(text: _texto(widget.simulado));
  bool _digitou = false;

  static String _texto(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void didUpdateWidget(BudgetEditor old) {
    super.didUpdateWidget(old);
    // Enquanto a pessoa não mexeu no campo, ele acompanha o valor simulado.
    if (!_digitou && old.simulado != widget.simulado) {
      _valor.text = _texto(widget.simulado);
    }
  }

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _fechar() async {
    final valor = parseDecimal(_valor.text);
    if (valor == null || valor < 0) {
      Toast.show(context, text: 'Informe um valor válido.', type: ToastType.warning);
      return;
    }
    final ok = await Modal.confirm(
      context,
      title: 'Fechar orçamento?',
      message:
          'O valor de ${formatarMoeda(valor)} não poderá mais ser editado e '
          'passa a valer no lugar do valor simulado.',
      confirmText: 'Fechar orçamento',
    );
    if (ok == true) await widget.onFechar(valor);
  }

  @override
  Widget build(BuildContext context) {
    final fechado = widget.orcamentoFinal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailField('Valor simulado', formatarMoeda(widget.simulado)),
        const SizedBox(height: 8),
        if (widget.editavel) ...[
          const Label(type: LabelType.caption, text: 'Orçamento final'),
          Row(
            children: [
              Expanded(
                child: InputField(
                  controller: _valor,
                  type: InputType.decimal,
                  // Centralizado na vertical e colado ao valor.
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 14, right: 2),
                    child: Center(widthFactor: 1, child: Label(text: 'R\$')),
                  ),
                  onChanged: (_) => _digitou = true,
                ),
              ),
              const SizedBox(width: 8),
              Button(text: 'Fechar Orçamento', onPressed: _fechar),
            ],
          ),
          const Label(
            type: LabelType.caption,
            text: 'Você pode editar o valor até fechar o orçamento.',
          ),
        ] else ...[
          DetailField(
            'Orçamento final',
            fechado == null ? 'Ainda não fechado' : formatarMoeda(fechado),
          ),
          if (fechado == null)
            const Label(
              type: LabelType.caption,
              text: 'Pedido encerrado: o orçamento não pode mais ser editado.',
            ),
        ],
      ],
    );
  }
}
