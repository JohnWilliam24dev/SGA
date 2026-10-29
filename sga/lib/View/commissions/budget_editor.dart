import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Shared/formatters.dart';
import 'budget_dialogs.dart';
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
    this.reabrivel = false,
    this.onReabrir,
    this.onFecharEConcluir,
    this.simuladoVisivel = true,
  });

  /// Nulo quando o pedido não tem valor simulado (orçado à mão).
  final double? simulado;
  final double? orcamentoFinal;
  final bool editavel;
  final Future<void> Function(double valor) onFechar;

  /// Orçamento fechado que o Maker pode reabrir.
  final bool reabrivel;
  final Future<void> Function()? onReabrir;

  /// Fecha o orçamento com o valor e já move o pedido para Concluído.
  /// Sem ele, o botão "Fechar e concluir" não aparece.
  final Future<void> Function(double valor)? onFecharEConcluir;

  /// `false` quando o cliente não vê o valor simulado (só o orçamento fechado).
  final bool simuladoVisivel;

  @override
  State<BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<BudgetEditor> {
  late final _valor = TextEditingController(
    text: widget.simulado == null ? '' : _texto(widget.simulado!),
  );
  bool _digitou = false;

  static String _texto(double v) => v.toStringAsFixed(2).replaceAll('.', ',');

  @override
  void didUpdateWidget(BudgetEditor old) {
    super.didUpdateWidget(old);
    // Enquanto a pessoa não mexeu no campo, ele acompanha o valor simulado.
    if (!_digitou && old.simulado != widget.simulado) {
      _valor.text = widget.simulado == null ? '' : _texto(widget.simulado!);
    }
  }

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _fechar({bool concluir = false}) async {
    final valor = parseDecimal(_valor.text);
    if (valor == null || valor < 0) {
      Toast.show(context, text: 'Informe um valor válido.', type: ToastType.warning);
      return;
    }
    if (!await confirmarFechamento(context, valor, concluir: concluir)) return;
    await (concluir ? widget.onFecharEConcluir! : widget.onFechar)(valor);
  }

  Future<void> _reabrir() async {
    if (await confirmarReabertura(context)) await widget.onReabrir!();
  }

  @override
  Widget build(BuildContext context) {
    final fechado = widget.orcamentoFinal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailField(
          'Valor simulado',
          widget.simulado == null
              ? 'Orçamento Pendente'
              : formatarMoeda(widget.simulado!),
        ),
        if (widget.simulado != null && !widget.simuladoVisivel)
          const Label(
            type: LabelType.caption,
            text: 'O cliente não vê o valor simulado, só o orçamento fechado.',
          ),
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
          if (widget.onFecharEConcluir != null)
            Button(
              text: 'Fechar e concluir',
              variant: ButtonVariant.outline,
              onPressed: () => _fechar(concluir: true),
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
          if (widget.reabrivel && widget.onReabrir != null)
            Button(
              text: 'Reabrir Orçamento',
              variant: ButtonVariant.outline,
              onPressed: _reabrir,
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
