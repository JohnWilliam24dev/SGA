import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/formatters.dart';
import 'additionals_editor.dart';

/// Abre o formulário de novo pedido (folha que sobe de baixo) e devolve o
/// pedido montado, ou `null` se o Maker cancelar.
Future<NovaCommission?> pedirNovoPedido(
  BuildContext context,
  List<OpcaoDeTipo> opcoes, {
  bool manual = false,
}) {
  return Modal.sheet<NovaCommission>(
    context,
    builder: (_) => NewOrderSheet(opcoes: opcoes, manual: manual),
  );
}

/// Formulário completo do pedido: cliente, contato, tipo, adicionais e
/// descrição. Só devolve o pedido quando todos os campos estão válidos.
/// No modo [manual] (Maker que orça à mão) não há tipo nem adicionais.
class NewOrderSheet extends StatefulWidget {
  const NewOrderSheet({super.key, required this.opcoes, this.manual = false});

  final List<OpcaoDeTipo> opcoes;
  final bool manual;

  @override
  State<NewOrderSheet> createState() => _NewOrderSheetState();
}

class _NewOrderSheetState extends State<NewOrderSheet> {
  OpcaoDeTipo? _opcao;
  List<CommissionAdicionalModel> _itens = const [];

  double get _total =>
      (_opcao?.tipo.precoBase ?? 0) + somaDosAdicionais(_itens);

  void _escolherTipo(String? id) => setState(() {
    _opcao = widget.opcoes.where((o) => o.tipo.id == id).firstOrNull;
    _itens = const [];
  });

  void _enviar(FormValues values) {
    final opcao = _opcao;
    if (opcao == null && !widget.manual) return;
    final email = values['email']?.trim() ?? '';
    Navigator.of(context).pop(
      NovaCommission(
        nomeCliente: values['cliente']!.trim(),
        contato: values['contato']!.trim(),
        email: email.isEmpty ? null : email,
        descricao: values['descricao']!.trim(),
        tipoProdutoId: opcao?.tipo.id,
        tipoProdutoNome: opcao?.tipo.nome,
        precoBase: opcao?.tipo.precoBase,
        adicionais: opcao == null ? const [] : _itens,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opcao = _opcao;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Label(type: LabelType.title, text: 'Novo pedido'),
              const SizedBox(height: 16),
              FormGroup(
                onSubmit: _enviar,
                children: [
                  InputField(
                    name: 'cliente',
                    label: 'Nome do cliente',
                    validation: [isRequired(), maxLength(nomeMaximo)],
                  ),
                  InputField(
                    name: 'contato',
                    label: 'Contato',
                    hint: 'WhatsApp, Discord, @...',
                    validation: [isRequired(), maxLength(contatoMaximo)],
                  ),
                  InputField(
                    name: 'email',
                    label: 'E-mail (opcional)',
                    type: InputType.email,
                    validation: [isEmail(), maxLength(emailMaximo)],
                  ),
                  if (!widget.manual)
                  Select<String>.single(
                    name: 'tipo',
                    label: 'Tipo do produto',
                    hint: 'Escolha o tipo',
                    // O Select volta ao `value` a cada rebuild: ele é controlado.
                    value: opcao?.tipo.id,
                    options: [
                      for (final o in widget.opcoes)
                        SelectOption(o.tipo.id, o.tipo.nome),
                    ],
                    onChanged: _escolherTipo,
                    validation: [isRequired()],
                  ),
                  if (!widget.manual && opcao != null) ...[
                    const Label(type: LabelType.subtitle, text: 'Adicionais'),
                    AdditionalsEditor(
                      itens: _itens,
                      disponiveis: opcao.adicionais,
                      precoBase: opcao.tipo.precoBase,
                      onChanged: (novos) => setState(() => _itens = novos),
                    ),
                    Label(
                      type: LabelType.caption,
                      text: 'Valor simulado: ${formatarMoeda(_total)}',
                    ),
                  ],
                  InputField(
                    name: 'descricao',
                    label: 'Descrição do pedido',
                    minLines: 3,
                    maxLines: 3,
                    validation: [isRequired(), maxLength(descricaoPedidoMaximo)],
                  ),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    children: [
                      Button(
                        text: 'Cancelar',
                        variant: ButtonVariant.ghost,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Button(text: 'Criar pedido'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
