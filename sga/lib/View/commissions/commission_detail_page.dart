import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';

/// Detalhe de uma commission, aberto ao tocar no card do quadro.
class CommissionDetailPage extends StatefulWidget {
  const CommissionDetailPage({
    super.key,
    required this.repository,
    required this.commission,
    required this.statusNome,
    required this.onBack,
  });

  final CommissionRepository repository;
  final CommissionResumoModel commission;
  final String statusNome;
  final VoidCallback onBack;

  @override
  State<CommissionDetailPage> createState() => _CommissionDetailPageState();
}

class _CommissionDetailPageState extends State<CommissionDetailPage> {
  Future<CommissionDetalhadaModel>? _loading;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _loading = widget.repository.carregarDetalhe(widget.commission.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tela(
      title: 'Detalhes da Commission',
      onBack: widget.onBack,
      scrollable: true,
      background: const Backdrop.bubbles(child: SizedBox.shrink()),
      child: Div(
        maxWidth: 720.px,
        align: Alignment.topCenter,
        children: [
          _cabecalho(),
          AsyncView(
            load: () => _loading!,
            builder: (context, detalhe) => Div(
              width: 100.pct,
              children: [
                _secaoCliente(detalhe),
                _secaoPedido(detalhe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho() {
    return Card(
      variant: CardVariant.glass,
      child: Div(
        direction: LayoutDirection.horizontal,
        align: Alignment.centerLeft,
        children: [
          Avatar(initials: widget.commission.nomeCliente[0], diameter: 56),
          LayoutItem(
            size: 1.fr,
            child: Div(
              gap: 4.px,
              children: [
                Label(type: LabelType.title, text: widget.commission.nomeCliente),
                Div(
                  direction: LayoutDirection.horizontal,
                  gap: 8.px,
                  children: [
                    Badge(text: widget.statusNome, variant: BadgeVariant.soft),
                    Label(
                      type: LabelType.caption,
                      text: 'Criado em ${formatDate(widget.commission.criadoEm)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Label(
            type: LabelType.title,
            text: formatMoney(widget.commission.orcamentoFinal ?? widget.commission.precoSimulado),
          ),
        ],
      ),
    );
  }

  Widget _secaoCliente(CommissionDetalhadaModel detalhe) {
    return Section(
      title: 'Cliente',
      child: Card(
        child: Div(
          children: [
            DataField(label: 'Nome', value: detalhe.nomeCliente),
            DataField(label: 'E-mail', value: detalhe.email ?? 'Não informado'),
            DataField(label: 'Rede Social', value: detalhe.contato),
          ],
        ),
      ),
    );
  }

  Widget _secaoPedido(CommissionDetalhadaModel detalhe) {
    return Section(
      title: 'Pedido',
      child: Card(
        child: Div(
          children: [
            DataField(label: 'Tipo', value: detalhe.tipoProdutoNome),
            if (detalhe.adicionais.isNotEmpty)
              DataField(
                label: 'Adicionais',
                value: detalhe.adicionais.map((a) => a.nome).join(', '),
              ),
            const Divider(),
            const Label(text: 'Descrição do pedido', type: LabelType.caption),
            Label(text: detalhe.descricao),
            if (detalhe.imagemRefUrl.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Label(text: 'Referências', type: LabelType.caption),
              Grid.fit(
                minCellWidth: 140,
                children: [
                  Picture(url: detalhe.imagemRefUrl),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
