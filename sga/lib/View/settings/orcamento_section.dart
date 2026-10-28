import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/erros.dart';

/// Orçamento dos pedidos: duas chaves (`/config-maker`). Valem só para os
/// pedidos criados depois da mudança; os já criados não mudam.
class OrcamentoSection extends StatefulWidget {
  const OrcamentoSection({super.key, required this.repository});

  final ConfigMakerRepository repository;

  @override
  State<OrcamentoSection> createState() => _OrcamentoSectionState();
}

class _OrcamentoSectionState extends State<OrcamentoSection> {
  ConfigMakerModel? _config;
  bool _falhou = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final c = await widget.repository.carregar();
      if (mounted) setState(() => _config = c);
    } catch (_) {
      if (mounted) setState(() => _falhou = true);
    }
  }

  /// Muda na hora e volta ao valor anterior se o servidor recusar.
  Future<void> _alterar(ConfigMakerModel novo) async {
    final antes = _config!;
    setState(() => _config = novo);
    try {
      final salvo = await widget.repository.salvar(
        usaCatalogo: novo.usaCatalogo != antes.usaCatalogo
            ? novo.usaCatalogo
            : null,
        exibirValorSimulado: novo.exibirValorSimulado != antes.exibirValorSimulado
            ? novo.exibirValorSimulado
            : null,
      );
      if (mounted) setState(() => _config = salvo);
    } catch (e) {
      if (!mounted) return;
      setState(() => _config = antes);
      Toast.error(
        context,
        text: mensagemDeErro(e, 'Não foi possível salvar a configuração.'),
      );
    }
  }

  Widget _linha(String titulo, String detalhe, bool valor, ValueChanged<bool> mudou) =>
      Div(
        direction: ResponsiveDirection(mobile: LayoutDirection.horizontal),
        align: Alignment.centerLeft,
        children: [
          LayoutItem(
            size: 1.fr,
            child: Div(
              gap: 0.px,
              children: [
                Label(text: titulo),
                Label(type: LabelType.caption, text: detalhe),
              ],
            ),
          ),
          Toggle(value: valor, onChanged: mudou),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final c = _config;
    return Div(
      width: 100.pct,
      children: [
        const Label(type: LabelType.title, text: 'Orçamento dos pedidos'),
        if (_falhou)
          const Label(
            type: LabelType.caption,
            text: 'Não foi possível carregar a configuração.',
          )
        else if (c == null)
          const Label(type: LabelType.caption, text: 'Carregando...')
        else ...[
          const Label(
            type: LabelType.caption,
            text: 'Vale só para os pedidos novos. Os que já existem não mudam.',
          ),
          _linha(
            'Usar o catálogo para precificar',
            c.usaCatalogo
                ? 'Os pedidos usam tipo de produto, adicionais e valor simulado.'
                : 'Você orça cada pedido à mão: sem tipo nem valor simulado.',
            c.usaCatalogo,
            (v) => _alterar(c.copyWith(usaCatalogo: v)),
          ),
          Opacity(
            opacity: c.usaCatalogo ? 1 : 0.5,
            child: IgnorePointer(
              ignoring: !c.usaCatalogo,
              child: _linha(
                'Mostrar valores ao cliente',
                c.usaCatalogo
                    ? 'Preços e valor simulado aparecem no formulário. '
                          'Desligado, o cliente só vê o orçamento fechado.'
                    : 'Sem catálogo, o cliente só vê o orçamento fechado.',
                c.exibirValorSimulado,
                (v) => _alterar(c.copyWith(exibirValorSimulado: v)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
