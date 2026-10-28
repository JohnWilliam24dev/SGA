import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon;

import '../../Domain/domain.dart';
import '../../Shared/formatters.dart';
import 'additionals_editor.dart';
import 'budget_editor.dart';
import 'detail_concluir.dart';
import 'detail_data.dart';
import 'detail_parts.dart';
import 'detail_sections.dart';

/// Todos os blocos do detalhe, com o controle do Maker sobre o pedido: fechar
/// o orçamento e trocar os adicionais. Na nota (compact) ficam em duas
/// colunas; na página, empilhados.
///
/// A alteração aparece na hora; o repositório confirma e a tela recarrega
/// os dados salvos (se ele recusar, o motivo aparece num aviso).
class DetailBody extends StatefulWidget {
  const DetailBody({
    super.key,
    required this.data,
    required this.compact,
    required this.repository,
    required this.catalogo,
  });

  final DetailData data;
  final bool compact;
  final CommissionRepository repository;
  final CatalogoRepository catalogo;

  @override
  State<DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  late DetailData _data = widget.data;
  int _pendentes = 0;

  String get _id => _data.detalhe.id;

  Future<void> _executar(Future<void> Function() acao) async {
    _pendentes++;
    try {
      await acao();
    } on CommissionRegraException catch (e) {
      _avisar(e.mensagem);
    } catch (_) {
      _avisar('Não foi possível salvar a alteração.');
    }
    _pendentes--;
    if (_pendentes == 0) await _recarregar();
  }

  void _avisar(String texto) {
    if (mounted) Toast.show(context, text: texto, type: ToastType.error);
  }

  Future<void> _recarregar() async {
    try {
      final novo = await DetailData.carregar(
        widget.repository,
        widget.catalogo,
        _id,
      );
      if (mounted) setState(() => _data = novo);
    } catch (_) {
      // Fica com o que já está na tela.
    }
  }

  void _trocarAdicionais(List<CommissionAdicionalModel> novos) {
    setState(() => _data = _data.comAdicionais(novos));
    _executar(() => widget.repository.salvarAdicionais(_id, novos));
  }

  DetailSection _s(String titulo, List<Widget> filhos) =>
      DetailSection(title: titulo, compact: widget.compact, children: filhos);

  @override
  Widget build(BuildContext context) {
    final d = _data.detalhe;
    final compact = widget.compact;
    final orcamento = _s('Orçamento', [
      BudgetEditor(
        simulado: d.precoSimulado,
        orcamentoFinal: d.orcamentoFinal,
        editavel: _data.editavel,
        reabrivel: _data.reabrivel,
        onReabrir: () => _executar(() => widget.repository.reabrirOrcamento(_id)),
        onFechar: (valor) =>
            _executar(() => widget.repository.fecharOrcamento(_id, valor)),
        onFecharEConcluir: (valor) => _executar(
          () => fecharEConcluir(widget.repository, _id, valor),
        ),
      ),
    ]);
    final pedido = _s('Pedido', [
      DetailField('Descrição', d.descricao),
      ReferenceImage(url: d.imagemRefUrl, height: compact ? 88 : 200),
    ]);
    final adicionais = _s('Adicionais', [
      if (_data.editavel)
        AdditionalsEditor(
          itens: d.adicionais,
          disponiveis: _data.opcao?.adicionais ?? const [],
          precoBase: _data.opcao?.tipo.precoBase ?? 0,
          onChanged: _trocarAdicionais,
        )
      else
        ...adicionaisDoPedido(d.adicionais),
    ]);
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
            if (d.tipoProdutoId != null)
              TwoColumns(adicionais, acompanhamento)
            else
              acompanhamento,
          ]
        : [
            orcamento,
            pedido,
            if (d.tipoProdutoId != null) adicionais,
            contato,
            acompanhamento,
          ];
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
