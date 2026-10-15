import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/formatters.dart';
import '../../Shared/widgets/glass/glass_panel.dart';
import 'detail_parts.dart';

/// Um bloco do detalhe: painel de vidro na página (celular) e caixa
/// levemente tingida na nota (desktop).
class DetailSection extends StatelessWidget {
  const DetailSection({
    super.key,
    required this.title,
    required this.children,
    required this.compact,
  });

  final String title;
  final List<Widget> children;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Label(type: LabelType.subtitle, text: title),
        for (final child in children) ...[
          SizedBox(height: compact ? 6 : 10),
          child,
        ],
      ],
    );
    if (!compact) {
      return GlassPanel(padding: const EdgeInsets.all(18), child: content);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x14336E99),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: content),
    );
  }
}

/// Todos os blocos do detalhe. Na nota (compact) ficam em duas colunas; na
/// página, empilhados.
class DetailBody extends StatelessWidget {
  const DetailBody({super.key, required this.detalhe, required this.compact});

  final CommissionDetalhadaModel detalhe;
  final bool compact;

  DetailSection _s(String titulo, List<Widget> filhos) =>
      DetailSection(title: titulo, compact: compact, children: filhos);

  @override
  Widget build(BuildContext context) {
    final d = detalhe;
    final orcamento = _s('Orçamento', [
      DetailField('Valor simulado', formatarMoeda(d.precoSimulado)),
      DetailField(
        'Orçamento final',
        d.orcamentoFinal == null
            ? 'Ainda não fechado'
            : formatarMoeda(d.orcamentoFinal!),
      ),
    ]);
    final pedido = _s('Pedido', [
      DetailField('Descrição', d.descricao),
      ReferenceImage(url: d.imagemRefUrl, height: compact ? 88 : 200),
    ]);
    final adicionais = _s('Adicionais', adicionaisDoPedido(d.adicionais));
    final contato = _s('Contato', [
      DetailField('Contato', d.contato),
      DetailField('E-mail', d.email ?? 'Não informado'),
    ]);
    final acompanhamento = _s('Acompanhamento', [
      DetailField('Código', d.token),
      DetailField('Criada em', formatarDataHora(d.criadoEm)),
    ]);

    final blocos = compact
        ? [
            TwoColumns(orcamento, contato),
            pedido,
            TwoColumns(adicionais, acompanhamento),
          ]
        : [orcamento, pedido, adicionais, contato, acompanhamento];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blocos.length; i++) ...[
          if (i > 0) SizedBox(height: compact ? 12 : 16),
          blocos[i],
        ],
      ],
    );
  }
}
